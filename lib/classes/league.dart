class League {
  League({
    required this.id,
    required this.name,
    required this.url,
    required this.slug,
    required this.videogame,
    required this.modifiedAt,
    required this.series,
    required this.imageUrl,
  });

  final int id;
  final String? name;
  final String? url;
  final String? slug;
  final Videogame? videogame;
  final DateTime? modifiedAt;
  final List<Series> series;
  String? imageUrl;

  League copyWith({
    required int id,
    String? name,
    String? url,
    String? slug,
    Videogame? videogame,
    DateTime? modifiedAt,
    List<Series>? series,
    String? imageUrl,
  }) {
    return League(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      slug: slug ?? this.slug,
      videogame: videogame ?? this.videogame,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      series: series ?? this.series,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json["id"],
      name: json["name"],
      url: json["url"],
      slug: json["slug"],
      videogame: json["videogame"] == null
          ? null
          : Videogame.fromJson(json["videogame"]),
      modifiedAt: DateTime.tryParse(json["modified_at"] ?? ""),
      series: json["series"] == null
          ? []
          : List<Series>.from(json["series"]!.map((x) => Series.fromJson(x))),
      imageUrl: json["image_url"],
    );
  }

  static List<League> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => League.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "url": url,
    "slug": slug,
    "videogame": videogame?.toJson(),
    "modified_at": modifiedAt?.toIso8601String(),
    "series": series.map((x) => x?.toJson()).toList(),
    "image_url": imageUrl,
  };

  @override
  String toString() {
    return "$id, $name, $url, $slug, $videogame, $modifiedAt, $series, $imageUrl, ";
  }
}

class Series {
  Series({
    required this.id,
    required this.name,
    required this.year,
    required this.beginAt,
    required this.endAt,
    required this.winnerId,
    required this.winnerType,
    required this.slug,
    required this.modifiedAt,
    required this.leagueId,
    required this.season,
    required this.fullName,
  });

  final int? id;
  final String? name;
  final int? year;
  final DateTime? beginAt;
  final DateTime? endAt;
  final int? winnerId;
  final String? winnerType;
  final String? slug;
  final DateTime? modifiedAt;
  final int? leagueId;
  final String? season;
  final String? fullName;

  Series copyWith({
    int? id,
    String? name,
    int? year,
    DateTime? beginAt,
    DateTime? endAt,
    int? winnerId,
    String? winnerType,
    String? slug,
    DateTime? modifiedAt,
    int? leagueId,
    String? season,
    String? fullName,
  }) {
    return Series(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      beginAt: beginAt ?? this.beginAt,
      endAt: endAt ?? this.endAt,
      winnerId: winnerId ?? this.winnerId,
      winnerType: winnerType ?? this.winnerType,
      slug: slug ?? this.slug,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      leagueId: leagueId ?? this.leagueId,
      season: season ?? this.season,
      fullName: fullName ?? this.fullName,
    );
  }

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json["id"],
      name: json["name"],
      year: json["year"],
      beginAt: DateTime.tryParse(json["begin_at"] ?? ""),
      endAt: DateTime.tryParse(json["end_at"] ?? ""),
      winnerId: json["winner_id"],
      winnerType: json["winner_type"],
      slug: json["slug"],
      modifiedAt: DateTime.tryParse(json["modified_at"] ?? ""),
      leagueId: json["league_id"],
      season: json["season"],
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
    "league_id": leagueId,
    "season": season,
    "full_name": fullName,
  };

  @override
  String toString() {
    return "$id, $name, $year, $beginAt, $endAt, $winnerId, $winnerType, $slug, $modifiedAt, $leagueId, $season, $fullName, ";
  }
}

class Videogame {
  Videogame({
    required this.id,
    required this.name,
    required this.currentVersion,
    required this.slug,
  });

  final int? id;
  final String? name;
  final String? currentVersion;
  final String? slug;

  Videogame copyWith({
    int? id,
    String? name,
    String? currentVersion,
    String? slug,
  }) {
    return Videogame(
      id: id ?? this.id,
      name: name ?? this.name,
      currentVersion: currentVersion ?? this.currentVersion,
      slug: slug ?? this.slug,
    );
  }

  factory Videogame.fromJson(Map<String, dynamic> json) {
    return Videogame(
      id: json["id"],
      name: json["name"],
      currentVersion: json["current_version"],
      slug: json["slug"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "current_version": currentVersion,
    "slug": slug,
  };

  @override
  String toString() {
    return "$id, $name, $currentVersion, $slug, ";
  }
}
