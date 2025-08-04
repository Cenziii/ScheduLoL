class Videogame {
  Videogame({required this.id, required this.name, required this.slug});

  final int? id;
  final String? name;
  final String? slug;

  Videogame copyWith({int? id, String? name, String? slug}) {
    return Videogame(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }

  factory Videogame.fromJson(Map<String, dynamic> json) {
    return Videogame(id: json["id"], name: json["name"], slug: json["slug"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "slug": slug};

  @override
  String toString() {
    return "$id, $name, $slug, ";
  }
}
