import 'package:infinity_scrolling_image_gallery/actions/actions.dart';
import 'package:redux/redux.dart';

class LoadingState {
  final bool loading;
  final Exception? error;

  LoadingState({required this.loading, required this.error});

  factory LoadingState.empty() {
    return LoadingState(
      loading: false,
      error: null,
    );
  }
}

final loadingReducer = combineReducers<LoadingState>([
  TypedReducer<LoadingState, LoadImagesAction>(_setLoad).call,
  TypedReducer<LoadingState, ImagesLoadedAction>(_setLoaded).call,
  TypedReducer<LoadingState, LoadMoreImagesAction>(_setLoadMoreFinished).call,
  TypedReducer<LoadingState, LoadImagesErrorAction>(_setLoadError).call,
  TypedReducer<LoadingState, RefreshImagesErrorAction>(_setRefreshError).call,
  TypedReducer<LoadingState, RefreshImagesAction>(_setRefreshImage).call,
]);

LoadingState _setLoad(LoadingState state, LoadImagesAction action) {
  return LoadingState(error: state.error, loading: true);
}

LoadingState _setLoaded(LoadingState state, ImagesLoadedAction action) {
  return LoadingState(error: state.error, loading: false);
}

LoadingState _setLoadMoreFinished(
    LoadingState state, LoadMoreImagesAction action) {
  return LoadingState(error: state.error, loading: false);
}

LoadingState _setLoadError(LoadingState state, LoadImagesErrorAction action) {
  return LoadingState(error: state.error, loading: false);
}

LoadingState _setRefreshImage(LoadingState state, RefreshImagesAction action) {
  return LoadingState(error: null, loading: true);
}

LoadingState _setRefreshError(
    LoadingState state, RefreshImagesErrorAction action) {
  return LoadingState(error: action.error, loading: false);
}
