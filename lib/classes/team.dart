class Team {
  Team({
    required this.id,
    required this.name,
    required this.location,
    required this.slug,
    required this.modifiedAt,
    required this.acronym,
    required this.imageUrl,
  });

  final int? id;
  final String? name;
  final String? location;
  final String? slug;
  final DateTime? modifiedAt;
  final String? acronym;
  final String? imageUrl;

  Team copyWith({
    int? id,
    String? name,
    String? location,
    String? slug,
    DateTime? modifiedAt,
    String? acronym,
    String? imageUrl,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      slug: slug ?? this.slug,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      acronym: acronym ?? this.acronym,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json["id"],
      name: json["name"],
      location: json["location"],
      slug: json["slug"],
      modifiedAt: DateTime.tryParse(json["modified_at"] ?? ""),
      acronym: json["acronym"],
      imageUrl: json["image_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "location": location,
    "slug": slug,
    "modified_at": modifiedAt?.toIso8601String(),
    "acronym": acronym,
    "image_url": imageUrl,
  };

  @override
  String toString() {
    return "$id, $name, $location, $slug, $modifiedAt, $acronym, $imageUrl, ";
  }
}
