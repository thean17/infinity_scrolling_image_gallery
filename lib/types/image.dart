import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable()
class Image {
  final String id;
  final String author;
  final int width;
  final int height;
  final String url;

  @JsonKey(name: "download_url")
  final String downloadUrl;

  Image(
      {required this.id,
      required this.author,
      required this.width,
      required this.height,
      required this.url,
      required this.downloadUrl});

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
