import 'package:infinity_scrolling_image_gallery/types/image.dart';

class LoadImagesAction {}

class LoadImagesErrorAction {}

class RefreshImagesAction {}

class ExpandImageAction {
  final int index;

  ExpandImageAction(this.index);

  @override
  String toString() {
    return 'ExpandImageAction{index: $index}';
  }
}

class CollapseImageAction {}

class ImagesLoadedAction {
  final List<Image> images;

  ImagesLoadedAction(this.images);

  @override
  String toString() {
    return 'ImagesLoadedAction{images: $images}';
  }
}

class LoadMoreImagesAction {
  final List<Image> images;

  LoadMoreImagesAction(this.images);

  @override
  String toString() {
    return 'LoadMoreImagesAction{images: $images}';
  }
}
