import 'package:lol_competitive/classes/expected_roster.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/serie.dart';
import 'package:lol_competitive/classes/team.dart';
import 'package:lol_competitive/classes/match.dart';

class Tournament {
  Tournament({
    required this.id,
    required this.name,
    required this.type,
    required this.matches,
    required this.country,
    required this.beginAt,
    required this.detailedStats,
    required this.endAt,
    required this.winnerId,
    required this.winnerType,
    required this.teams,
    required this.slug,
    required this.modifiedAt,
    required this.videogame,
    required this.serieId,
    required this.serie,
    required this.leagueId,
    required this.league,
    required this.prizepool,
    required this.tier,
    required this.videogameTitle,
    required this.hasBracket,
    required this.region,
    required this.liveSupported,
    required this.expectedRoster,
  });

  final int? id;
  final String? name;
  final String? type;
  final List<Match> matches;
  final String? country;
  final DateTime? beginAt;
  final bool? detailedStats;
  final DateTime? endAt;
  final int? winnerId;
  final String? winnerType;
  final List<Team> teams;
  final String? slug;
  final DateTime? modifiedAt;
  final Videogame? videogame;
  final int? serieId;
  final Serie? serie;
  final int? leagueId;
  final League? league;
  final String? prizepool;
  final String? tier;
  final dynamic videogameTitle;
  final bool? hasBracket;
  final String? region;
  final bool? liveSupported;
  final List<ExpectedRoster> expectedRoster;

  Tournament copyWith({
    int? id,
    String? name,
    String? type,
    List<Match>? matches,
    String? country,
    DateTime? beginAt,
    bool? detailedStats,
    DateTime? endAt,
    int? winnerId,
    String? winnerType,
    List<Team>? teams,
    String? slug,
    DateTime? modifiedAt,
    Videogame? videogame,
    int? serieId,
    Serie? serie,
    int? leagueId,
    League? league,
    String? prizepool,
    String? tier,
    dynamic? videogameTitle,
    bool? hasBracket,
    String? region,
    bool? liveSupported,
    List<ExpectedRoster>? expectedRoster,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      matches: matches ?? this.matches,
      country: country ?? this.country,
      beginAt: beginAt ?? this.beginAt,
      detailedStats: detailedStats ?? this.detailedStats,
      endAt: endAt ?? this.endAt,
      winnerId: winnerId ?? this.winnerId,
      winnerType: winnerType ?? this.winnerType,
      teams: teams ?? this.teams,
      slug: slug ?? this.slug,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      videogame: videogame ?? this.videogame,
      serieId: serieId ?? this.serieId,
      serie: serie ?? this.serie,
      leagueId: leagueId ?? this.leagueId,
      league: league ?? this.league,
      prizepool: prizepool ?? this.prizepool,
      tier: tier ?? this.tier,
      videogameTitle: videogameTitle ?? this.videogameTitle,
      hasBracket: hasBracket ?? this.hasBracket,
      region: region ?? this.region,
      liveSupported: liveSupported ?? this.liveSupported,
      expectedRoster: expectedRoster ?? this.expectedRoster,
    );
  }

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json["id"],
      name: json["name"],
      type: json["type"],
      matches: json["matches"] == null
          ? []
          : List<Match>.from(json["matches"]!.map((x) => Match.fromJson(x))),
      country: json["country"],
      beginAt: DateTime.tryParse(json["begin_at"] ?? ""),
      detailedStats: json["detailed_stats"],
      endAt: DateTime.tryParse(json["end_at"] ?? ""),
      winnerId: json["winner_id"],
      winnerType: json["winner_type"],
      teams: json["teams"] == null
          ? []
          : List<Team>.from(json["teams"]!.map((x) => Team.fromJson(x))),
      slug: json["slug"],
      modifiedAt: DateTime.tryParse(json["modified_at"] ?? ""),
      videogame: json["videogame"] == null
          ? null
          : Videogame.fromJson(json["videogame"]),
      serieId: json["serie_id"],
      serie: json["serie"] == null ? null : Serie.fromJson(json["serie"]),
      leagueId: json["league_id"],
      league: json["league"] == null ? null : League.fromJson(json["league"]),
      prizepool: json["prizepool"],
      tier: json["tier"],
      videogameTitle: json["videogame_title"],
      hasBracket: json["has_bracket"],
      region: json["region"],
      liveSupported: json["live_supported"],
      expectedRoster: json["expected_roster"] == null
          ? []
          : List<ExpectedRoster>.from(
              json["expected_roster"]!.map((x) => ExpectedRoster.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
    "matches": matches.map((x) => x?.toJson()).toList(),
    "country": country,
    "begin_at": beginAt?.toIso8601String(),
    "detailed_stats": detailedStats,
    "end_at": endAt?.toIso8601String(),
    "winner_id": winnerId,
    "winner_type": winnerType,
    "teams": teams.map((x) => x?.toJson()).toList(),
    "slug": slug,
    "modified_at": modifiedAt?.toIso8601String(),
    "videogame": videogame?.toJson(),
    "serie_id": serieId,
    "serie": serie?.toJson(),
    "league_id": leagueId,
    "league": league?.toJson(),
    "prizepool": prizepool,
    "tier": tier,
    "videogame_title": videogameTitle,
    "has_bracket": hasBracket,
    "region": region,
    "live_supported": liveSupported,
    "expected_roster": expectedRoster.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $name, $type, $matches, $country, $beginAt, $detailedStats, $endAt, $winnerId, $winnerType, $teams, $slug, $modifiedAt, $videogame, $serieId, $serie, $leagueId, $league, $prizepool, $tier, $videogameTitle, $hasBracket, $region, $liveSupported, $expectedRoster, ";
  }
}
