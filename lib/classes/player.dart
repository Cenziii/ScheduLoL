class Player {
  Player({
    required this.active,
    required this.id,
    required this.name,
    required this.role,
    required this.slug,
    required this.modifiedAt,
    required this.age,
    required this.birthday,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.imageUrl,
  });

  final bool? active;
  final int? id;
  final String? name;
  final String? role;
  final String? slug;
  final DateTime? modifiedAt;
  final int? age;
  final DateTime? birthday;
  final String? firstName;
  final String? lastName;
  final String? nationality;
  final String? imageUrl;

  Player copyWith({
    bool? active,
    int? id,
    String? name,
    String? role,
    String? slug,
    DateTime? modifiedAt,
    int? age,
    DateTime? birthday,
    String? firstName,
    String? lastName,
    String? nationality,
    String? imageUrl,
  }) {
    return Player(
      active: active ?? this.active,
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      slug: slug ?? this.slug,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      age: age ?? this.age,
      birthday: birthday ?? this.birthday,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nationality: nationality ?? this.nationality,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      active: json["active"],
      id: json["id"],
      name: json["name"],
      role: json["role"],
      slug: json["slug"],
      modifiedAt: DateTime.tryParse(json["modified_at"] ?? ""),
      age: json["age"],
      birthday: DateTime.tryParse(json["birthday"] ?? ""),
      firstName: json["first_name"],
      lastName: json["last_name"],
      nationality: json["nationality"],
      imageUrl: json["image_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "active": active,
    "id": id,
    "name": name,
    "role": role,
    "slug": slug,
    "modified_at": modifiedAt?.toIso8601String(),
    "age": age,
    "birthday":
        "${birthday?.year.toString().padLeft(4, '0')}-${birthday?.month.toString().padLeft(2, '0')}-${birthday?.day.toString().padLeft(2, '0')}",
    "first_name": firstName,
    "last_name": lastName,
    "nationality": nationality,
    "image_url": imageUrl,
  };

  @override
  String toString() {
    return "$active, $id, $name, $role, $slug, $modifiedAt, $age, $birthday, $firstName, $lastName, $nationality, $imageUrl, ";
  }
}
