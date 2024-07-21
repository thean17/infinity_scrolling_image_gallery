import 'package:infinity_scrolling_image_gallery/reducers/images_reducer.dart';
import 'package:infinity_scrolling_image_gallery/reducers/loading_reducer.dart';

class RootState {
  final ImagesState images;

  final bool loading;

  RootState({required this.loading, required this.images});

  factory RootState.empty() {
    return RootState(loading: false, images: ImagesState.empty());
  }
}

RootState rootReducer(RootState state, action) {
  return RootState(
    images: imagesReducer(state.images, action),
    loading: loadingReducer(state.loading, action),
  );
}
