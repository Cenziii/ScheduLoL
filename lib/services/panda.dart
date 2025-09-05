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
          throw Exception('Error -> Response code ${response.body}');
        } else {
          throw Exception('Error -> Response code ${response.body}');
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
          final urlThumb = total_responses[i].imageUrl!.split("/"); // Split URL to get the last part
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

  // Method to fetch a specific series from the Pandascore API
  Future<Serie?> getSerie(int idLeague) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      throw (Exception('No network connection'));
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
        throw Exception('Error -> Response code ${response.body}');
      } else {
        throw Exception('Error -> Response code ${response.body}');
      }
    } on TimeoutException catch (_) {
      throw TimeoutException('Tournament Request timed out');
    } on SocketException catch (e) {
      throw SocketException('Network error while fetching $e');
    } on FormatException catch (e) {
      throw FormatException('Format exception error $e');
    } catch (e) {
      throw Exception('Unexpected error in series: $e');
    }
  }

  // Method to fetch the current tournament from the Pandascore API
  Future<List<Tournament>?> getCurrentTournament(int idLeague) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      throw (Exception('No network connection'));
    }

    // Constructing the URL to fetch the current tournament for a specific league
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
        // Decoding the JSON response
        final data = jsonDecode(response.body);

        // Getting the current tournament from the list of tournaments
        var serieList = Serie.fromJsonList(data);
        if (serieList.isNotEmpty) {
          Serie serie = serieList.first;

          List<Tournament> tournaments = serie.tournaments;
          DateTime now = DateTime.now();

          // Calcolo inizio settimana (lunedì alle 00:00)
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          startOfWeek = DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
          );

          // Calcolo fine settimana (domenica alle 23:59:59)
          DateTime endOfWeek = startOfWeek.add(
            Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
          );

          // Filtra i tornei che hanno partite in questa settimana
          var current_tournaments = tournaments
              .where(
                (element) =>
                    element.endAt!.isAfter(
                      startOfWeek,
                    ) && // torneo non finito prima dell'inizio settimana
                    element.beginAt!.isBefore(
                      endOfWeek,
                    ), // torneo iniziato prima della fine settimana
              )
              .toList();
          return current_tournaments;
        } else {
          return null;
        }
        // Get current tournament for that league's serie
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        throw Exception('Error -> Response code ${response.body}');
      } else {
        throw Exception('Error -> Response code ${response.body}');
      }
    } on TimeoutException catch (_) {
      throw TimeoutException('Tournament Request timed out');
    } on SocketException catch (e) {
      throw SocketException('Network error while fetching $e');
    } on FormatException catch (e) {
      throw FormatException('Format exception error $e');
    } catch (e) {
      throw Exception('Unexpected error in current tournament: $e');
    }
  }

  // Method to fetch the current tournament from the Pandascore API
  Future<List<Match>> getMatches(String period, int idTournament) async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      throw (Exception('No network connection'));
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
        throw Exception('Error -> Response code ${response.body}');
      } else {
        throw Exception('Error -> Response code ${response.body}');
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