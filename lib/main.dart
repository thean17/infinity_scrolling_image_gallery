import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinity_scrolling_image_gallery/utility/image_api.dart';
import 'package:infinity_scrolling_image_gallery/types/image.dart'
    as infinity_scrolling_image_gallery;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _api = ImageApi();

  final _images =
      List<infinity_scrolling_image_gallery.Image>.empty(growable: true);

  bool _loading = false;

  bool _debounce = false;

  int _page = 1;

  final double _triggerFetchScrollThreshold = 0.8;

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _fetchImages();

    _registerScrollListener();
  }

  Future<void> _fetchImages() async {
    try {
      _loading = true;
      setState(() {});

      final images = await _api.getImages(page: _page);

      _images.addAll(images);
      _loading = false;

      setState(() {});
    } catch (error) {
      debugPrint(error.toString());
      _loading = false;
      setState(() {});
    }
  }

  void _debounceScrollHandler() {
    _debounce = true;
    setState(() {});

    Timer(const Duration(milliseconds: 250), () {
      _debounce = false;
      setState(() {});
    });
  }

  void _registerScrollListener() {
    _controller.addListener(() {
      var nextPageTrigger =
          _triggerFetchScrollThreshold * _controller.position.maxScrollExtent;

      if (_controller.position.pixels > nextPageTrigger &&
          !_loading &&
          !_debounce) {
        _page += 1;
        _fetchImages().then((_) {
          _debounceScrollHandler();
        }).catchError((_) {
          _debounceScrollHandler();
        });
      }
    });
  }

  Color randomColor() {
    return Color.fromRGBO(Random().nextInt(255), Random().nextInt(255),
        Random().nextInt(255), 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text("Page: $_page"),
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemCount: _images.length,
                itemBuilder: (context, index) => CachedNetworkImage(
                    imageUrl: _images[index].downloadUrl,
                    progressIndicatorBuilder:
                        (context, child, downloadProgress) => AspectRatio(
                              aspectRatio:
                                  _images[index].width / _images[index].height,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: downloadProgress.progress == null
                                      ? const CircularProgressIndicator()
                                      : CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                        ),
                                ),
                              ),
                            ),
                    errorWidget: (context, url, error) {
                      debugPrint("fetch image error for $url");
                      debugPrint(error.toString());

                      return AspectRatio(
                        aspectRatio:
                            _images[index].width / _images[index].height,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                                Text("Unable to load image")
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
      ),
    );
  }
}
