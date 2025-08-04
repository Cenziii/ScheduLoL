class Winner {
  Winner({required this.id, required this.type});

  final dynamic id;
  final String? type;

  Winner copyWith({dynamic? id, String? type}) {
    return Winner(id: id ?? this.id, type: type ?? this.type);
  }

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(id: json["id"], type: json["type"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "type": type};

  @override
  String toString() {
    return "$id, $type, ";
  }
}
