import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/tournament.dart';

class Serie {
  Serie({
    required this.id,
    required this.name,
    required this.year,
    required this.beginAt,
    required this.endAt,
    required this.winnerId,
    required this.winnerType,
    required this.slug,
    required this.modifiedAt,
    required this.videogame,
    required this.leagueId,
    required this.league,
    required this.tournaments,
    required this.season,
    required this.videogameTitle,
    required this.fullName,
  });

  final int? id;
  final String? name;
  final int? year;
  final DateTime? beginAt;
  final DateTime? endAt;
  final dynamic winnerId;
  final String? winnerType;
  final String? slug;
  final DateTime? modifiedAt;
  final Videogame? videogame;
  final int? leagueId;
  final League? league;
  final List<Tournament> tournaments;
  final String? season;
  final dynamic videogameTitle;
  final String? fullName;

  Serie copyWith({
    int? id,
    String? name,
    int? year,
    DateTime? beginAt,
    DateTime? endAt,
    int? winnerId,
    String? winnerType,
    String? slug,
    DateTime? modifiedAt,
    Videogame? videogame,
    int? leagueId,
    League? league,
    List<Tournament>? tournaments,
    String? season,
    dynamic? videogameTitle,
    String? fullName,
  }) {
    return Serie(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      beginAt: beginAt ?? this.beginAt,
      endAt: endAt ?? this.endAt,
      winnerId: winnerId ?? this.winnerId,
      winnerType: winnerType ?? this.winnerType,
      slug: slug ?? this.slug,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      videogame: videogame ?? this.videogame,
      leagueId: leagueId ?? this.leagueId,
      league: league ?? this.league,
      tournaments: tournaments ?? this.tournaments,
      season: season ?? this.season,
      videogameTitle: videogameTitle ?? this.videogameTitle,
      fullName: fullName ?? this.fullName,
    );
  }

  static List<Serie> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Serie.fromJson(json)).toList();
  }

  factory Serie.fromJson(Map<String, dynamic> json) {
    return Serie(
      id: json["id"],
      name: json["name"],
      year: json["year"],
      beginAt: DateTime.tryParse(json["begin_at"] ?? ""),
      endAt: DateTime.tryParse(json["end_at"] ?? ""),
      winnerId: json["winner_id"],
      winnerType: json["winner_type"],
      slug: json["slug"],
      modifiedAt: DateTime.tryParse(json["modified_at"] ?? ""),
      videogame: json["videogame"] == null
          ? null
          : Videogame.fromJson(json["videogame"]),
      leagueId: json["league_id"],
      league: json["league"] == null ? null : League.fromJson(json["league"]),
      tournaments: json["tournaments"] == null
          ? []
          : List<Tournament>.from(
              json["tournaments"]!.map((x) => Tournament.fromJson(x)),
            ),
      season: json["season"],
      videogameTitle: json["videogame_title"],
      fullName: json["full_name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "year": year,
    "begin_at": beginAt?.toIso8601String(),
    "end_at": endAt?.toIso8601String(),
    "winner_id": winnerId,
    "winner_type": winnerType,
    "slug": slug,
    "modified_at": modifiedAt?.toIso8601String(),
    "videogame": videogame?.toJson(),
    "league_id": leagueId,
    "league": league?.toJson(),
    "tournaments": tournaments.map((x) => x?.toJson()).toList(),
    "season": season,
    "videogame_title": videogameTitle,
    "full_name": fullName,
  };

  @override
  String toString() {
    return "$id, $name, $year, $beginAt, $endAt, $winnerId, $winnerType, $slug, $modifiedAt, $videogame, $leagueId, $league, $tournaments, $season, $videogameTitle, $fullName, ";
  }
}
