import 'package:lol_competitive/classes/player.dart';
import 'package:lol_competitive/classes/team.dart';

class ExpectedRoster {
  ExpectedRoster({required this.players, required this.team});

  final List<Player> players;
  final Team? team;

  ExpectedRoster copyWith({List<Player>? players, Team? team}) {
    return ExpectedRoster(
      players: players ?? this.players,
      team: team ?? this.team,
    );
  }

  factory ExpectedRoster.fromJson(Map<String, dynamic> json) {
    return ExpectedRoster(
      players: json["players"] == null
          ? []
          : List<Player>.from(json["players"]!.map((x) => Player.fromJson(x))),
      team: json["team"] == null ? null : Team.fromJson(json["team"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "players": players.map((x) => x?.toJson()).toList(),
    "team": team?.toJson(),
  };

  @override
  String toString() {
    return "$players, $team, ";
  }
}
