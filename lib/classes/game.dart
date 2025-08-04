import 'package:lol_competitive/classes/winner.dart';

class Game {
  Game({
    required this.beginAt,
    required this.complete,
    required this.detailedStats,
    required this.endAt,
    required this.finished,
    required this.forfeit,
    required this.id,
    required this.length,
    required this.matchId,
    required this.position,
    required this.status,
    required this.winner,
    required this.winnerType,
  });

  final dynamic beginAt;
  final bool? complete;
  final bool? detailedStats;
  final dynamic endAt;
  final bool? finished;
  final bool? forfeit;
  final int? id;
  final dynamic length;
  final int? matchId;
  final int? position;
  final String? status;
  final Winner? winner;
  final String? winnerType;

  Game copyWith({
    dynamic? beginAt,
    bool? complete,
    bool? detailedStats,
    dynamic? endAt,
    bool? finished,
    bool? forfeit,
    int? id,
    dynamic? length,
    int? matchId,
    int? position,
    String? status,
    Winner? winner,
    String? winnerType,
  }) {
    return Game(
      beginAt: beginAt ?? this.beginAt,
      complete: complete ?? this.complete,
      detailedStats: detailedStats ?? this.detailedStats,
      endAt: endAt ?? this.endAt,
      finished: finished ?? this.finished,
      forfeit: forfeit ?? this.forfeit,
      id: id ?? this.id,
      length: length ?? this.length,
      matchId: matchId ?? this.matchId,
      position: position ?? this.position,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      winnerType: winnerType ?? this.winnerType,
    );
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      beginAt: json["begin_at"],
      complete: json["complete"],
      detailedStats: json["detailed_stats"],
      endAt: json["end_at"],
      finished: json["finished"],
      forfeit: json["forfeit"],
      id: json["id"],
      length: json["length"],
      matchId: json["match_id"],
      position: json["position"],
      status: json["status"],
      winner: json["winner"] == null ? null : Winner.fromJson(json["winner"]),
      winnerType: json["winner_type"],
    );
  }

  Map<String, dynamic> toJson() => {
    "begin_at": beginAt,
    "complete": complete,
    "detailed_stats": detailedStats,
    "end_at": endAt,
    "finished": finished,
    "forfeit": forfeit,
    "id": id,
    "length": length,
    "match_id": matchId,
    "position": position,
    "status": status,
    "winner": winner?.toJson(),
    "winner_type": winnerType,
  };

  @override
  String toString() {
    return "$beginAt, $complete, $detailedStats, $endAt, $finished, $forfeit, $id, $length, $matchId, $position, $status, $winner, $winnerType, ";
  }
}
