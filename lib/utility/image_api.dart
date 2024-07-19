import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:infinity_scrolling_image_gallery/types/image.dart';

class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() {
    return message;
  }
}

class ImageApi {
  final Client client;

  ImageApi() : client = Client();

  Future<List<Image>> getImages({int page = 1, int limit = 30}) async {
    assert(page >= 1);

    final response = await client.get(
        Uri.parse("https://picsum.photos/v2/list?page=$page&limit=$limit"));

    if (response.statusCode != HttpStatus.ok) {
      throw AppException("HTTP response is not ok");
    }

    final decodedBody = jsonDecode(response.body) as List;

    return decodedBody.map((entry) => Image.fromJson(entry)).toList();
  }

  Future<Uint8List> downloadImage(String url) async {
    final response = await client.get(Uri.parse(url));

    if (response.statusCode != HttpStatus.ok) {
      throw AppException("HTTP response is not ok");
    }

    return response.bodyBytes;
  }
}
