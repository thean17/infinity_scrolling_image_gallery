import 'dart:convert';

import 'package:http/http.dart';
import 'package:infinity_scrolling_image_gallery/types/image.dart';

class ImageApi {
  final Client client;

  ImageApi() : client = Client();

  Future<List<Image>> getImages({int page = 1, int limit = 30}) async {
    final response = await client.get(
        Uri.parse("https://picsum.photos/v2/list?page=${page}&limit=${limit}"));

    final decodedBody = jsonDecode(response.body) as List;

    return decodedBody.map((entry) => Image.fromJson(entry)).toList();
  }
}
