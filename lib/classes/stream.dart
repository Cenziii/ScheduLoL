class StreamsList {
  StreamsList({
    required this.main,
    required this.language,
    required this.embedUrl,
    required this.official,
    required this.rawUrl,
  });

  final bool? main;
  final String? language;
  final String? embedUrl;
  final bool? official;
  final String? rawUrl;

  StreamsList copyWith({
    bool? main,
    String? language,
    String? embedUrl,
    bool? official,
    String? rawUrl,
  }) {
    return StreamsList(
      main: main ?? this.main,
      language: language ?? this.language,
      embedUrl: embedUrl ?? this.embedUrl,
      official: official ?? this.official,
      rawUrl: rawUrl ?? this.rawUrl,
    );
  }

  factory StreamsList.fromJson(Map<String, dynamic> json) {
    return StreamsList(
      main: json["main"],
      language: json["language"],
      embedUrl: json["embed_url"],
      official: json["official"],
      rawUrl: json["raw_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "main": main,
    "language": language,
    "embed_url": embedUrl,
    "official": official,
    "raw_url": rawUrl,
  };

  @override
  String toString() {
    return "$main, $language, $embedUrl, $official, $rawUrl, ";
  }
}
