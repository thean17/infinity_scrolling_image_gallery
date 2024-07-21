import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gal/gal.dart';
import 'package:infinity_scrolling_image_gallery/actions/actions.dart';
import 'package:infinity_scrolling_image_gallery/reducers/images_reducer.dart';
import 'package:infinity_scrolling_image_gallery/reducers/root_reducer.dart';
import 'package:infinity_scrolling_image_gallery/utility/image_api.dart';
import 'package:infinity_scrolling_image_gallery/types/image.dart'
    as infinity_scrolling_image_gallery;
import 'package:infinity_scrolling_image_gallery/widget/infinity_list.dart';
import 'package:infinity_scrolling_image_gallery/widget/pull_to_refresh.dart';
import 'package:redux/redux.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(StoreProvider(
      store: Store<RootState>(
        rootReducer,
        initialState: RootState.empty(),
      ),
      child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _api = ImageApi();

  bool _downloadingImage = false;

  int _page = 1;

  Future<void> _refreshImages() async {
    try {
      StoreProvider.of<RootState>(context).dispatch(LoadImagesAction());

      final images = await _api.getImages();

      StoreProvider.of<RootState>(context).dispatch(ImagesLoadedAction(images));
    } catch (error) {
      debugPrint(error.toString());

      StoreProvider.of<RootState>(context).dispatch(LoadImagesErrorAction());
    }
  }

  Future<void> _loadMoreImages() async {
    try {
      StoreProvider.of<RootState>(context).dispatch(LoadImagesAction());

      final images = await _api.getImages(page: _page);

      StoreProvider.of<RootState>(context)
          .dispatch(LoadMoreImagesAction(images));
    } catch (error) {
      debugPrint(error.toString());

      StoreProvider.of<RootState>(context).dispatch(LoadImagesErrorAction());
    }
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

      Gal.open();
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
      child: StoreConnector<RootState, ImagesState>(
        converter: (store) => store.state.images,
        builder: (context, state) => AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          color: state.image == null ? Colors.transparent : Colors.black,
          width: MediaQuery.of(context).size.width,
          height: state.image == null ? 0 : MediaQuery.of(context).size.height,
          child: GestureDetector(
            onPanEnd: (_) => StoreProvider.of<RootState>(context)
                .dispatch(CollapseImageAction()),
            child: state.image != null
                ? Stack(
                    children: [
                      Center(
                        child: _buildImage(state.image!),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: _buildImageActionButton(context, state.image!),
                        ),
                      )
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<RootState, RootState>(
      converter: (store) => store.state,
      onInit: (store) => _refreshImages(),
      builder: (_, __) => MaterialApp(
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                shadowColor: Colors.black, scrolledUnderElevation: 10),
            colorSchemeSeed: const Color.fromARGB(255, 0, 132, 255),
            useMaterial3: true),
        home: Scaffold(
          appBar: AppBar(
            shadowColor: Colors.black,
            title: Title(
              color: Colors.black,
              child: const Text("Infinity Scroll Image Gallery"),
            ),
          ),
          body: Builder(builder: (context) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: StoreConnector<RootState, RootState>(
                        converter: (store) => store.state,
                        builder: (context, state) => PullToRefresh(
                          disabled: state.loading,
                          triggerThreshold: 300.0,
                          onRefresh: () {
                            StoreProvider.of<RootState>(context)
                                .dispatch(RefreshImagesAction());

                            _refreshImages();
                          },
                          child: InfinityList(
                            load: () {
                              _page += 1;
                              _loadMoreImages();
                            },
                            triggerLoadThreshold: 0.8,
                            loading: state.loading,
                            itemCount: state.images.images.length,
                            itemBuilder: (context, index) => Stack(
                              children: [
                                InkWell(
                                    onTap: () =>
                                        StoreProvider.of<RootState>(context)
                                            .dispatch(ExpandImageAction(index)),
                                    child: _buildImage(
                                        state.images.images[index])),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: _buildImageActionButton(
                                      context, state.images.images[index]),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
      ),
    );
  }
}
