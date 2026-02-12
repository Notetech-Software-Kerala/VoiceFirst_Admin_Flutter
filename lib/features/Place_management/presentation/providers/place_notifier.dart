import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpoints.dart';

import '../../data/models/place_model.dart';
import '../../data/models/place_requests.dart';
import '../../data/place_service/place_service.dart';
import 'place_state.dart';

class PlaceNotifier extends Notifier<PlaceState> {
  late final PlaceService _service;

  @override
  PlaceState build() {
    _service = PlaceService(baseUrl: ApiEndpoints.baseUrl);
    return const PlaceState();
  }

  Future<void> loadPlaces({
    int page = 1,
    int pageSize = 10,
    String? search, 
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.getPlaces(
        page: page,
        pageSize: pageSize,
        search: search,
      );

      state = state.copyWith(
        places: response.items,
        isLoading: false,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalCount: response.totalCount,
        search: search ?? '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectPlace(int id) async {
    final cached = state.places.cast<PlaceModel?>().firstWhere(
      (p) => p?.placeId == id,
      orElse: () => null,
    );

    if (cached?.postOffices.isNotEmpty == true) {
      state = state.copyWith(selectedPlace: cached);
      return;
    }

    state = state.copyWith(isDetailLoading: true, error: null);
    try {
      final detail = await _service.getPlaceById(id);
      state = state.copyWith(
        selectedPlace: detail,
        isDetailLoading: false,
        places: state.places.map((p) => p.placeId == id ? detail : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(isDetailLoading: false, error: e.toString());
    }
  }

  Future<PlaceModel> createPlace(CreatePlaceRequest request) async {
    try {
      final created = await _service.createPlace(request);
      state = state.copyWith(places: [created, ...state.places]);
      return created;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<bool> updatePlace(int id, UpdatePlaceRequest request) async {
    final payload = request.toJson();
    if (payload.isEmpty) {
      return false;
    }

    try {
      final updated = await _service.updatePlace(id, request);
      _sync(updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deletePlace(int id) async {
    try {
      final updated = await _service.deletePlace(id);
      _sync(updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> recoverPlace(int id) async {
    try {
      final updated = await _service.recoverPlace(id);
      _sync(updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void _sync(PlaceModel updated) {
    state = state.copyWith(
      selectedPlace: state.selectedPlace?.placeId == updated.placeId
          ? updated
          : state.selectedPlace,
      places: state.places
          .map((p) => p.placeId == updated.placeId ? updated : p)
          .toList(),
    );
  }
}
