// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
      id: json['id'] as String,
      author: json['author'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      url: json['url'] as String,
      downloadUrl: json['download_url'] as String,
    );

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
      'download_url': instance.downloadUrl,
    };
