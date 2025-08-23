import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/classes/serie.dart';
import 'package:lol_competitive/classes/tournament.dart';
import 'package:lol_competitive/services/shared_prefs.dart';

class PandaService {
  PandaService._privateConstructor();

  static final PandaService _instance = PandaService._privateConstructor();
  final apiKey = dotenv.env['PANDA_API_KEY'];
  final baseUrl = 'https://api.pandascore.co/lol/';

  factory PandaService() {
    return _instance;
  }

  Future<bool> checkConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  Future<List<League>?> loadTournaments() async {
    List<League>? leagues = await PandaService().getLeagues();

    if (leagues != null && leagues.isNotEmpty) {
      
      var strIds = await  SharedPreferencesService().getSharedPreferences('league_ids');

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
    return null;
  }

  Future<List<League>?> getLeagues() async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      debugPrint('No network connection');
      return null;
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
        final response = await http
            .get(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          current_result = League.fromJsonList(data);
          total_responses = List.from(total_responses)..addAll(current_result);
        } else if (response.statusCode == 400 ||
            response.statusCode == 401 ||
            response.statusCode == 403 ||
            response.statusCode == 404 ||
            response.statusCode == 422) {
          debugPrint('Response code ${response.body}');
          return null;
        } else {
          debugPrint('Response code ${response.statusCode}');
          return null;
        }
      } on TimeoutException catch (_) {
        debugPrint('Tournament Request timed out');
        return null;
      } on SocketException catch (e) {
        debugPrint('Network error while fetching $e');
        return null;
      } on FormatException catch (_) {
        debugPrint('Invalid JSON format in BuildingInsights response');
        return null;
      } catch (e) {
        debugPrint('Unexpected error in tournament: $e');
        return null;
      }
    }
    // Remove useless league
    DateTime dateToTest = DateTime.now();

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
      new_ordered_leagues.add(total_responses[lck_index]);
      new_ordered_leagues.add(total_responses[lpl_index]);
      new_ordered_leagues.add(total_responses[lec_index]);
      new_ordered_leagues.add(total_responses[lta_index]);
      for (int i = 0; i < total_responses.length; i++) {
        if (total_responses[i].imageUrl != null) {
          final urlThumb = total_responses[i].imageUrl!.split("/");
          var addThumb = "thumb_${urlThumb.last}";
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

  Future<Serie?> getSerie(int idLeague) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      debugPrint('No network connection');
      return null;
    }

    final url = Uri.parse(
      '${baseUrl}series/running?filter[league_id]=$idLeague',
    );

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get Current Serie for that league
        Serie serie = Serie.fromJson(data);
        return serie;
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        debugPrint('Response code ${response.body}');
        return null;
      } else {
        debugPrint('Response code ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (_) {
      debugPrint('Tournament Request timed out');
      return null;
    } on SocketException catch (_) {
      debugPrint('Network error while fetching past match');
      return null;
    } on FormatException catch (_) {
      debugPrint('Invalid JSON format in past match response');
      return null;
    } catch (e) {
      debugPrint('Unexpected error in past match: $e');
      return null;
    }
  }

  Future<List<Tournament>?> getCurrentTournament(int idLeague) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      debugPrint('No network connection');
      return null;
    }

    final url = Uri.parse(
      '${baseUrl}series/running?filter[league_id]=$idLeague',
    );

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get Current Serie for that league
        var serieList = Serie.fromJsonList(data);
        if (serieList.isNotEmpty) {
          Serie serie = serieList.first;

          List<Tournament> tournaments = serie.tournaments;
          var current_tournament = tournaments
              .where(
                (element) =>
                    element.beginAt!.isBefore(DateTime.now()) &&
                    element.endAt!.isAfter(DateTime.now()),
              )
              .toList();
          return current_tournament;
        } else {
          return null;
        }
        // Get current tournament for that league's serie
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        debugPrint('Response code ${response.body}');
        return null;
      } else {
        debugPrint('Response code ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (_) {
      debugPrint('Tournament Request timed out');
      return null;
    } on SocketException catch (_) {
      debugPrint('Network error while fetching past match');
      return null;
    } on FormatException catch (_) {
      debugPrint('Invalid JSON format in past match response');
      return null;
    } catch (e) {
      debugPrint('Unexpected error in past match: $e');
      return null;
    }
  }

  Future<List<Match>> getMatches(String period, int idTournament) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      debugPrint('No network connection');
      return [];
    }

    final url = Uri.parse(
      '${baseUrl}matches/$period?filter[tournament_id]=$idTournament',
    );
    try {
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Match.fromJsonList(data);
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        debugPrint('Response code ${response.body}');
        return [];
      } else {
        debugPrint('Response code ${response.statusCode}');
        return [];
      }
    } on TimeoutException catch (_) {
      debugPrint('Tournament Request timed out');
      return [];
    } on SocketException catch (_) {
      debugPrint('Network error while fetching matches');
      return [];
    } on FormatException catch (_) {
      debugPrint('Invalid JSON format in matches response');
      return [];
    } catch (e) {
      debugPrint('Unexpected error in tournament: $e');
      return [];
    }
  }
}
