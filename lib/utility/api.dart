import 'dart:convert';

import 'package:http/http.dart';
import 'package:infinity_scrolling_image_gallery/types/image.dart';

class Api {
  final Client client;

  Api() : client = Client();

  Future<List<Image>> getImages() async {
    final response =
        await client.get(Uri.parse("https://picsum.photos/v2/list"));

    final decodedBody = jsonDecode(response.body) as List;

    return decodedBody.map((entry) => Image.fromJson(entry)).toList();
  }
}
