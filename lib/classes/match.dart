import 'package:lol_competitive/classes/game.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/live.dart';
import 'package:lol_competitive/classes/result.dart';
import 'package:lol_competitive/classes/serie.dart';
import 'package:lol_competitive/classes/team.dart';
import 'package:lol_competitive/classes/tournament.dart';

class Match {
  Match({
    required this.beginAt,
    required this.detailedStats,
    required this.draw,
    required this.endAt,
    required this.forfeit,
    required this.gameAdvantage,
    required this.games,
    required this.id,
    required this.league,
    required this.leagueId,
    required this.live,
    required this.matchType,
    required this.modifiedAt,
    required this.name,
    required this.numberOfGames,
    required this.opponents,
    required this.originalScheduledAt,
    required this.rescheduled,
    required this.results,
    required this.scheduledAt,
    required this.serie,
    required this.serieId,
    required this.slug,
    required this.status,
    required this.streamsList,
    required this.tournament,
    required this.tournamentId,
    required this.videogame,
    required this.videogameTitle,
    required this.videogameVersion,
    required this.winner,
    required this.winnerId,
    required this.winnerType,
  });

  final DateTime? beginAt;
  final bool? detailedStats;
  final bool? draw;
  final dynamic endAt;
  final bool? forfeit;
  final dynamic gameAdvantage;
  final List<Game> games;
  final int? id;
  final League? league;
  final int? leagueId;
  final Live? live;
  final String? matchType;
  final DateTime? modifiedAt;
  final String? name;
  final int? numberOfGames;
  final List<Team> opponents;
  final DateTime? originalScheduledAt;
  final bool? rescheduled;
  final List<Result> results;
  final DateTime? scheduledAt;
  final Serie? serie;
  final int? serieId;
  final String? slug;
  final String? status;
  final List<dynamic> streamsList;
  final Tournament? tournament;
  final int? tournamentId;
  final Videogame? videogame;
  final dynamic videogameTitle;
  final dynamic videogameVersion;
  final dynamic winner;
  final dynamic winnerId;
  final String? winnerType;

  Match copyWith({
    DateTime? beginAt,
    bool? detailedStats,
    bool? draw,
    dynamic? endAt,
    bool? forfeit,
    dynamic? gameAdvantage,
    List<Game>? games,
    int? id,
    League? league,
    int? leagueId,
    Live? live,
    String? matchType,
    DateTime? modifiedAt,
    String? name,
    int? numberOfGames,
    List<Team>? opponents,
    DateTime? originalScheduledAt,
    bool? rescheduled,
    List<Result>? results,
    DateTime? scheduledAt,
    Serie? serie,
    int? serieId,
    String? slug,
    String? status,
    List<dynamic>? streamsList,
    Tournament? tournament,
    int? tournamentId,
    Videogame? videogame,
    dynamic? videogameTitle,
    dynamic? videogameVersion,
    dynamic? winner,
    dynamic? winnerId,
    String? winnerType,
  }) {
    return Match(
      beginAt: beginAt ?? this.beginAt,
      detailedStats: detailedStats ?? this.detailedStats,
      draw: draw ?? this.draw,
      endAt: endAt ?? this.endAt,
      forfeit: forfeit ?? this.forfeit,
      gameAdvantage: gameAdvantage ?? this.gameAdvantage,
      games: games ?? this.games,
      id: id ?? this.id,
      league: league ?? this.league,
      leagueId: leagueId ?? this.leagueId,
      live: live ?? this.live,
      matchType: matchType ?? this.matchType,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      name: name ?? this.name,
      numberOfGames: numberOfGames ?? this.numberOfGames,
      opponents: opponents ?? this.opponents,
      originalScheduledAt: originalScheduledAt ?? this.originalScheduledAt,
      rescheduled: rescheduled ?? this.rescheduled,
      results: results ?? this.results,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      serie: serie ?? this.serie,
      serieId: serieId ?? this.serieId,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      streamsList: streamsList ?? this.streamsList,
      tournament: tournament ?? this.tournament,
      tournamentId: tournamentId ?? this.tournamentId,
      videogame: videogame ?? this.videogame,
      videogameTitle: videogameTitle ?? this.videogameTitle,
      videogameVersion: videogameVersion ?? this.videogameVersion,
      winner: winner ?? this.winner,
      winnerId: winnerId ?? this.winnerId,
      winnerType: winnerType ?? this.winnerType,
    );
  }

  static List<Match> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Match.fromJson(json)).toList();
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      beginAt: DateTime.tryParse(json["begin_at"] ?? ""),
      detailedStats: json["detailed_stats"],
      draw: json["draw"],
      endAt: json["end_at"],
      forfeit: json["forfeit"],
      gameAdvantage: json["game_advantage"],
      games: json["games"] == null
          ? []
          : List<Game>.from(json["games"]!.map((x) => Game.fromJson(x))),
      id: json["id"],
      league: json["league"] == null ? null : League.fromJson(json["league"]),
      leagueId: json["league_id"],
      live: json["live"] == null ? null : Live.fromJson(json["live"]),
      matchType: json["match_type"],
      modifiedAt: DateTime.tryParse(json["modified_at"] ?? ""),
      name: json["name"],
      numberOfGames: json["number_of_games"],
      opponents: json["opponents"] == null
          ? []
          : List<Team>.from(
              json["opponents"]!.map((x) => Team.fromJson(x["opponent"])),
            ),
      originalScheduledAt: DateTime.tryParse(
        json["original_scheduled_at"] ?? "",
      ),
      rescheduled: json["rescheduled"],
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => Result.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      scheduledAt: DateTime.tryParse(json["scheduled_at"] ?? ""),
      serie: json["serie"] == null ? null : Serie.fromJson(json["serie"]),
      serieId: json["serie_id"],
      slug: json["slug"],
      status: json["status"],
      streamsList: json["streams_list"] == null
          ? []
          : List<dynamic>.from(json["streams_list"]!.map((x) => x)),
      tournament: json["tournament"] == null
          ? null
          : Tournament.fromJson(json["tournament"]),
      tournamentId: json["tournament_id"],
      videogame: json["videogame"] == null
          ? null
          : Videogame.fromJson(json["videogame"]),
      videogameTitle: json["videogame_title"],
      videogameVersion: json["videogame_version"],
      winner: json["winner"],
      winnerId: json["winner_id"],
      winnerType: json["winner_type"],
    );
  }

  Map<String, dynamic> toJson() => {
    "begin_at": beginAt?.toIso8601String(),
    "detailed_stats": detailedStats,
    "draw": draw,
    "end_at": endAt,
    "forfeit": forfeit,
    "game_advantage": gameAdvantage,
    "games": games.map((x) => x?.toJson()).toList(),
    "id": id,
    "league": league?.toJson(),
    "league_id": leagueId,
    "live": live?.toJson(),
    "match_type": matchType,
    "modified_at": modifiedAt?.toIso8601String(),
    "name": name,
    "number_of_games": numberOfGames,
    "opponents": opponents.map((x) => x).toList(),
    "original_scheduled_at": originalScheduledAt?.toIso8601String(),
    "rescheduled": rescheduled,
    "results": results.map((x) => x).toList(),
    "scheduled_at": scheduledAt?.toIso8601String(),
    "serie": serie?.toJson(),
    "serie_id": serieId,
    "slug": slug,
    "status": status,
    "streams_list": streamsList.map((x) => x).toList(),
    "tournament": tournament?.toJson(),
    "tournament_id": tournamentId,
    "videogame": videogame?.toJson(),
    "videogame_title": videogameTitle,
    "videogame_version": videogameVersion,
    "winner": winner,
    "winner_id": winnerId,
    "winner_type": winnerType,
  };

  @override
  String toString() {
    return "$beginAt, $detailedStats, $draw, $endAt, $forfeit, $gameAdvantage, $games, $id, $league, $leagueId, $live, $matchType, $modifiedAt, $name, $numberOfGames, $opponents, $originalScheduledAt, $rescheduled, $results, $scheduledAt, $serie, $serieId, $slug, $status, $streamsList, $tournament, $tournamentId, $videogame, $videogameTitle, $videogameVersion, $winner, $winnerId, $winnerType, ";
  }
}
