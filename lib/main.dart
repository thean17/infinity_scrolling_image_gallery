import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:infinity_scrolling_image_gallery/utility/image_api.dart';
import 'package:infinity_scrolling_image_gallery/types/image.dart'
    as infinity_scrolling_image_gallery;
import 'package:share_plus/share_plus.dart';

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

  bool _downloadingImage = false;

  int _expandImageIndex = -1;

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

  void shareImageUrl(String imageUrl) {
    Share.shareUri(Uri.parse(imageUrl));
  }

  Future<void> downloadImage(String imageUrl) async {
    try {
      setState(() {
        _downloadingImage = true;
      });

      final bytes = await _api.downloadImage(imageUrl);

      await Gal.putImageBytes(bytes, album: "Download", name: "download");
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      setState(() {
        _downloadingImage = false;
      });
    }
  }

  Widget _buildImage(infinity_scrolling_image_gallery.Image image) {
    return CachedNetworkImage(
        imageUrl: image.downloadUrl,
        progressIndicatorBuilder: (context, child, downloadProgress) =>
            AspectRatio(
              aspectRatio: image.width / image.height,
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
            aspectRatio: image.width / image.height,
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
        });
  }

  Widget _buildImageActionButton(
      BuildContext context, infinity_scrolling_image_gallery.Image image) {
    return IconButton(
      onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => BottomSheet(
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Colors.black45,
                      ))),
                      child: TextButton(
                        onPressed: () {
                          shareImageUrl(image.downloadUrl);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Share Link"),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          downloadImage(image.downloadUrl);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Save Image"))
                  ],
                ),
                onClosing: () {},
              )),
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
    );
  }

  Widget _buildExpandedImage(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: _expandImageIndex == -1 ? Colors.transparent : Colors.black,
        width: MediaQuery.of(context).size.width,
        height:
            _expandImageIndex == -1 ? 0 : MediaQuery.of(context).size.height,
        child: GestureDetector(
          onPanEnd: (_) => setState(() {
            _expandImageIndex = -1;
          }),
          child: _expandImageIndex != -1
              ? Stack(
                  children: [
                    Center(
                      child: _buildImage(_images[_expandImageIndex]),
                    ),
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: _buildImageActionButton(
                            context, _images[_expandImageIndex]),
                      ),
                    )
                  ],
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: _images.length,
                      itemBuilder: (context, index) => Stack(
                        children: [
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _expandImageIndex = index;
                                });
                              },
                              child: _buildImage(_images[index])),
                          Align(
                            alignment: Alignment.topRight,
                            child: _buildImageActionButton(
                                context, _images[index]),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (_loading)
                    const LinearProgressIndicator(
                      backgroundColor: Colors.black,
                    )
                ],
              ),
              _buildExpandedImage(context),
              if (_downloadingImage)
                Positioned.fill(
                    child: Container(
                  color: Colors.black.withAlpha(192),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )),
            ],
          );
        }),
      ),
    );
  }
}
