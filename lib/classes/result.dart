class Result {
  Result({required this.teamId, required this.score});

  final int? teamId;
  final int? score;

  Result copyWith({int? teamId, int? score}) {
    return Result(teamId: teamId ?? this.teamId, score: score ?? this.score);
  }

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(teamId: json["team_id"], score: json["score"]);
  }

  Map<String, dynamic> toJson() => {"team_id": teamId, "score": score};

  @override
  String toString() {
    return "$teamId, $score, ";
  }
}
