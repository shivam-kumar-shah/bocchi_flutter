class Source {
  final String url;
  final int resolution;
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
      url: dataMap["url"],
      resolution: dataMap["resolution"],
      audio: dataMap["audio"],
      fansubGroup: dataMap["group"],
    );
  }
}
