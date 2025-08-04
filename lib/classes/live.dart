class Live {
  Live({required this.supported, required this.url, required this.opensAt});

  final bool? supported;
  final String? url;
  final DateTime? opensAt;

  Live copyWith({bool? supported, String? url, DateTime? opensAt}) {
    return Live(
      supported: supported ?? this.supported,
      url: url ?? this.url,
      opensAt: opensAt ?? this.opensAt,
    );
  }

  factory Live.fromJson(Map<String, dynamic> json) {
    return Live(
      supported: json["supported"],
      url: json["url"],
      opensAt: DateTime.tryParse(json["opens_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "supported": supported,
    "url": url,
    "opens_at": opensAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$supported, $url, $opensAt, ";
  }
}
