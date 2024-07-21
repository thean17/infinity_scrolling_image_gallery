import 'package:infinity_scrolling_image_gallery/actions/actions.dart';
import 'package:infinity_scrolling_image_gallery/types/image.dart';
import 'package:redux/redux.dart';

class ImagesState {
  final List<Image> images;

  final int selectedImage;

  Image? get image {
    return selectedImage >= 0 ? images[selectedImage] : null;
  }

  ImagesState({required this.selectedImage, required this.images});

  factory ImagesState.empty() {
    return ImagesState(
      selectedImage: -1,
      images: [],
    );
  }
}

final imagesReducer = combineReducers<ImagesState>([
  TypedReducer<ImagesState, ImagesLoadedAction>(_setLoadedImages).call,
  TypedReducer<ImagesState, LoadMoreImagesAction>(_loadMoreImages).call,
  TypedReducer<ImagesState, RefreshImagesAction>(_refreshImages).call,
  TypedReducer<ImagesState, ExpandImageAction>(_expandImage).call,
  TypedReducer<ImagesState, CollapseImageAction>(_collapseImage).call,
]);

ImagesState _setLoadedImages(ImagesState state, ImagesLoadedAction action) {
  return ImagesState(selectedImage: state.selectedImage, images: action.images);
}

ImagesState _loadMoreImages(ImagesState state, LoadMoreImagesAction action) {
  return ImagesState(
      selectedImage: state.selectedImage, images: state.images + action.images);
}

ImagesState _refreshImages(ImagesState state, RefreshImagesAction action) {
  return ImagesState(selectedImage: state.selectedImage, images: []);
}

ImagesState _expandImage(ImagesState state, ExpandImageAction action) {
  return ImagesState(
    selectedImage: action.index,
    images: state.images,
  );
}

ImagesState _collapseImage(ImagesState state, CollapseImageAction action) {
  return ImagesState(
    selectedImage: -1,
    images: state.images,
  );
}
