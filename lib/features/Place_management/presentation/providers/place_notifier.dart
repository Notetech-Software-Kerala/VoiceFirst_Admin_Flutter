import 'dart:math' show min;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/place_model.dart';
import '../../data/models/place_requests.dart';
import '../../data/place_service/place_service.dart';
import 'place_state.dart';


class PlaceNotifier extends Notifier<PlaceState> {
  late final PlaceService _service;

  @override
  PlaceState build() {
    _service = ref.read(placeServiceProvider);
    return const PlaceState();
  }

  Future<void> loadPlaces({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final effectiveSearch = search ?? state.search;

    // Combined guard: avoid loading when already loading or requesting pages beyond known totalPages
    if (state.isLoading || (state.totalPages > 0 && page > state.totalPages))
      return;

    // Prevent duplicate calls when page/search unchanged (allow first load)
    if (page == state.currentPage &&
        effectiveSearch == state.search &&
        state.places.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.getPlaces(
        page: page,
        pageSize: pageSize,
        search: effectiveSearch, // ✅ FIXED
      );

      final safePage = min(response.currentPage, response.totalPages);

      state = state.copyWith(
        places: response.items,
        isLoading: false,
        currentPage: safePage,
        totalPages: response.totalPages,
        totalCount: response.totalCount,
        search: effectiveSearch,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectPlace(int id) async {
    PlaceModel? cached;
    for (final p in state.places) {
      if (p.placeId == id) {
        cached = p;
        break;
      }
    }

    if (cached != null && cached.postOffices.isNotEmpty) {
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
      state = state.copyWith(selectedPlace: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deletePlace(int id) async {
    // ⭐ OPTIMISTIC UI UPDATE (instant delete feel)
    final index = state.places.indexWhere((p) => p.placeId == id);

    if (index != -1) {
      final tempList = [...state.places];

      tempList[index] = tempList[index].copyWith(
        deleted: true, // VERY IMPORTANT
      );

      state = state.copyWith(
        places: tempList,
        selectedPlace: tempList[index],
        error: null,
      );
    }

    try {
      final updated = await _service.deletePlace(id);

      // Sync with real backend response
      _sync(updated);

      return true;
    } catch (e) {
      // ❗ Optional: revert UI if API fails
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
    final newPlaces = state.places
        .map((p) => p.placeId == updated.placeId ? updated : p)
        .toList();

    state = state.copyWith(places: newPlaces, selectedPlace: updated);
  }
}
