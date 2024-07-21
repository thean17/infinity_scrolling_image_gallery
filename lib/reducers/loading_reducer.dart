import 'package:infinity_scrolling_image_gallery/actions/actions.dart';
import 'package:redux/redux.dart';

final loadingReducer = combineReducers<bool>([
  TypedReducer<bool, LoadImagesAction>(_setLoad).call,
  TypedReducer<bool, ImagesLoadedAction>(_setLoaded).call,
  TypedReducer<bool, LoadMoreImagesAction>(_setLoadMoreFinished).call,
  TypedReducer<bool, LoadImagesErrorAction>(_setLoadError).call,
]);

bool _setLoad(bool loading, LoadImagesAction action) {
  return true;
}

bool _setLoaded(bool loading, ImagesLoadedAction action) {
  return false;
}

bool _setLoadMoreFinished(bool loading, LoadMoreImagesAction action) {
  return false;
}

bool _setLoadError(bool loading, LoadImagesErrorAction action) {
  return false;
}
