import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/classes/serie.dart';
import 'package:lol_competitive/classes/tournament.dart';
import 'package:lol_competitive/services/shared_prefs.dart';

class PandaService {
  // Private constructor to prevent instantiation from outside
  PandaService._privateConstructor();

  // Singleton instance of the class
  static final PandaService _instance = PandaService._privateConstructor();

  // API key for authentication with the Pandascore API
  final apiKey = dotenv.env['PANDA_API_KEY'];

  // Base URL for the Pandascore API
  final baseUrl = 'https://api.pandascore.co/lol/';

  // Factory method to get the singleton instance of PandaService
  factory PandaService() {
    return _instance;
  }

  // Global options
  final options = CacheOptions(
    // A default store is required for interceptor.
    store: MemCacheStore(),
    // Default.
    policy: CachePolicy.request,
    // Returns a cached response on error for given status codes.
    // Defaults to `[]`.
    hitCacheOnErrorCodes: const [400, 401, 403, 404, 422, 500],
    // Allows to return a cached response on network errors (e.g. offline usage).
    // Defaults to `false`.
    hitCacheOnNetworkFailure: true,
    // Overrides any HTTP directive to delete entry past this duration.
    // Useful only when origin server has no cache config or custom behaviour is desired.
    // Defaults to `null`.
    maxStale: const Duration(minutes: 10),
    // Default. Allows 3 cache sets and ease cleanup.
    priority: CachePriority.normal,
    // Default. Body and headers encryption with your own algorithm.
    cipher: null,
    // Default. Key builder to retrieve requests.
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    // Default. Allows to cache POST requests.
    // Assigning a [keyBuilder] is strongly recommended when `true`.
    allowPostMethod: false,
  );

  late final Dio dio = Dio()
    ..interceptors.add(DioCacheInterceptor(options: options))
    ..options.headers['Content-Type'] = 'application/json'
    ..options.headers['Accept'] = 'application/json'
    ..options.headers['Authorization'] = 'Bearer ${PandaService().apiKey}';

  // Method to check if there is a network connection
  Future<bool> checkConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  // Method to load a list of leagues from the Pandascore API
  Future<List<League>?> loadListOfLeagues() async {
    try {
      List<League>? leagues = await PandaService().getLeagues();

      if (leagues != null && leagues.isNotEmpty) {
        var strIds = await SharedPreferencesService().getSharedPreferences(
          'league_ids',
        );

        if (strIds != null && strIds.isNotEmpty) {
          List<int> orderIds = strIds.map(int.parse).toList();

          Map<int, int> positionMap = {
            for (int i = 0; i < orderIds.length; i++) orderIds[i]: i,
          };

          leagues.sort(
            (a, b) => (positionMap[a.id] ?? orderIds.length).compareTo(
              positionMap[b.id] ?? orderIds.length,
            ),
          );
        } else {
          List<String> temp = [];
          SharedPreferencesService().setSharedPreferences('league_ids', temp);
        }
        return leagues;
      }
    } catch (ex) {
      throw Exception('Error $ex');
    }
    return null;
  }

  // Method to fetch a list of leagues from the Pandascore API
  Future<List<League>?> getLeagues() async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      throw (Exception('No network connection'));
    }
    List<League> total_responses = [];
    List<League> current_result = [];
    for (
      int page_number = 1;
      page_number == 1 || current_result.isNotEmpty;
      page_number++
    ) {
      final url = Uri.parse(
        '${baseUrl}leagues?page[size]=100&page[number]=$page_number',
      );

      try {
        final response = await dio
            .getUri(
              url,
              options: options
                  .copyWith(policy: CachePolicy.forceCache)
                  .toOptions(),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = response.data;
          current_result = League.fromJsonList(data);
          total_responses = List.from(total_responses)..addAll(current_result);
        } else if (response.statusCode == 400 ||
            response.statusCode == 401 ||
            response.statusCode == 403 ||
            response.statusCode == 404 ||
            response.statusCode == 422) {
          throw Exception('Error -> Response code ${response.data}');
        } else {
          throw Exception('Error -> Response code ${response.data}');
        }
      } on TimeoutException catch (_) {
        throw TimeoutException('Tournament Request timed out');
      } on SocketException catch (e) {
        throw SocketException('Network error while fetching $e');
      } on FormatException catch (e) {
        throw FormatException('Format exception error $e');
      } catch (e) {
        throw Exception('Unexpected error in leagues: $e');
      }
    }

    // Remove useless league
    DateTime dateToTest = DateTime.now().add(Duration(days: -7));

    total_responses = total_responses.where((league) {
      return league.series.any((s) => s.endAt!.isAfter(dateToTest));
    }).toList();

    if (total_responses.isNotEmpty) {
      // Sorting to have main event LCK,LPL,LEC,LTA
      int lck_index = total_responses.indexWhere(
        (league) => league.name == "LCK",
      );
      int lpl_index = total_responses.indexWhere(
        (league) => league.name == "LPL",
      );
      int lec_index = total_responses.indexWhere(
        (league) => league.name == "LEC",
      );
      int lta_index = total_responses.indexWhere(
        (league) => league.name == "LTA North",
      );
      List<League> new_ordered_leagues = [];
      if (lck_index != -1) new_ordered_leagues.add(total_responses[lck_index]);
      if (lpl_index != -1) new_ordered_leagues.add(total_responses[lpl_index]);
      if (lec_index != -1) new_ordered_leagues.add(total_responses[lec_index]);
      if (lta_index != -1) new_ordered_leagues.add(total_responses[lta_index]);
      for (int i = 0; i < total_responses.length; i++) {
        if (total_responses[i].imageUrl != null) {
          final urlThumb = total_responses[i].imageUrl!.split(
            "/",
          ); // Split URL to get the last part
          var addThumb = "thumb_${urlThumb.last}"; // Create new thumbnail name
          total_responses[i].imageUrl = total_responses[i].imageUrl!.replaceAll(
            urlThumb.last,
            addThumb,
          );
        }

        if (i != lck_index &&
            i != lpl_index &&
            i != lec_index &&
            i != lta_index) {
          new_ordered_leagues.add(total_responses[i]);
        }
      }
      return new_ordered_leagues;
    } else {
      return total_responses;
    }
  }

  // Method to fetch all series for a league from the Pandascore API
  Future<List<Serie>> getSeries(int idLeague) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      throw Exception('No network connection');
    }

    final url = Uri.parse('${baseUrl}series?filter[league_id]=$idLeague');

    try {
      final response = await dio
          .getUri(
            url,
            options: options.copyWith(policy: CachePolicy.refresh).toOptions(),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = response.data;
        return Serie.fromJsonList(data);
      } else {
        throw Exception('Error -> Response code ${response.data}');
      }
    } on TimeoutException catch (_) {
      throw TimeoutException('Series request timed out');
    } on SocketException catch (e) {
      throw SocketException('Network error while fetching series: $e');
    } on FormatException catch (e) {
      throw FormatException('Format exception error $e');
    } catch (e) {
      throw Exception('Unexpected error in series: $e');
    }
  }

  // Method to fetch the current or last relevant tournaments from the Pandascore API
  Future<List<Tournament>> getCurrentTournament(int idLeague) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      throw Exception('No network connection');
    }

    DateTime now = DateTime.now();
    DateTime tenDaysBefore = DateTime.now().add(Duration(days: -7));

    try {
      List<Serie> serieList = await getSeries(idLeague);

      if (serieList.isEmpty) return [];

      // Filter currently series
      List<Serie> currentSeries = serieList
          .where((s) => s.endAt!.isAfter(now))
          .toList();

      // If currentSeries is empty, take last
      if (currentSeries.isEmpty) {
        serieList.sort((a, b) => b.endAt!.compareTo(a.endAt!));
        currentSeries.add(serieList.first);
      }

      List<Tournament> tournamentsToShow = [];

      // For each series, take tournaments
      for (var serie in currentSeries) {
        var activeTournaments = serie.tournaments
            .where(
              (t) =>
                  t.endAt!.isAfter(tenDaysBefore) &&
                  t.beginAt!.isBefore(serie.endAt!),
            )
            .toList();

        if (activeTournaments.isNotEmpty) {
          tournamentsToShow.addAll(activeTournaments);
        } else if (serie.tournaments.isNotEmpty) {
          // Take last tournaments
          serie.tournaments.sort((a, b) => b.endAt!.compareTo(a.endAt!));
          tournamentsToShow.add(serie.tournaments.first);
        }
      }

      tournamentsToShow.sort((a, b) => b.endAt!.compareTo(a.endAt!));

      return tournamentsToShow;
    } catch (e) {
      throw Exception('Unexpected error in fetching tournaments: $e');
    }
  }

  // Method to fetch the current tournament from the Pandascore API
  Future<List<Match>> getMatches(String period, int idTournament) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      throw (Exception('No network connection'));
    }

    Options tempOpt;
    if (period == 'past') {
      tempOpt = options.copyWith(policy: CachePolicy.forceCache).toOptions();
    } else {
      tempOpt = options.toOptions();
    }

    final url = Uri.parse(
      '${baseUrl}matches/$period?filter[tournament_id]=$idTournament',
    );
    try {
      final response = await dio
          .getUri(url, options: tempOpt)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = response.data;
        return Match.fromJsonList(data);
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        throw Exception('Error -> Response code ${response.data}');
      } else {
        throw Exception('Error -> Response code ${response.data}');
      }
    } on TimeoutException catch (_) {
      throw TimeoutException('Tournament Request timed out');
    } on SocketException catch (e) {
      throw SocketException('Network error while fetching $e');
    } on FormatException catch (e) {
      throw FormatException('Format exception error $e');
    } catch (e) {
      throw Exception('Unexpected error in matches: $e');
    }
  }
}
