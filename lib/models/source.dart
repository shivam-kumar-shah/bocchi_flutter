class Source {
  final String url;
  final String resolution;
  final String? audio;
  final String? fansubGroup;

  const Source({
    required this.resolution,
    required this.url,
    this.audio,
    this.fansubGroup,
  });

  factory Source.fromJSON({required Map<String, dynamic> dataMap}) {
    return Source(
      url: dataMap["url"].toString().replaceFirst("cache", "files"),
      resolution: dataMap["resolution"].toString(),
      audio: dataMap["audio"],
      fansubGroup: dataMap["group"],
    );
  }
}
