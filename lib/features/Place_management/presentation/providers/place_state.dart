import '../../data/models/place_model.dart';

class PlaceState {
  final List<PlaceModel> places;
  final PlaceModel? selectedPlace;
  final bool isLoading;
  final bool isDetailLoading;
  final String search;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? error;

  const PlaceState({
    this.places = const [],
    this.selectedPlace,
    this.isLoading = false,
    this.isDetailLoading = false,
    this.search = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.error,
  });

  PlaceState copyWith({
    List<PlaceModel>? places,
    PlaceModel? selectedPlace,
    bool? isLoading,
    bool? isDetailLoading,
    String? search,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? error,
    bool clearSelectedPlace = false,
  }) {
    return PlaceState(
      places: places ?? this.places,
      selectedPlace: clearSelectedPlace
          ? null
          : selectedPlace ?? this.selectedPlace,
      isLoading: isLoading ?? this.isLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      search: search ?? this.search,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      error: error ?? this.error,
    );
  }
}
