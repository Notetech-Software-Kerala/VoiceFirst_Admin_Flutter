import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/place_model.dart';
import '../../data/models/place_requests.dart';
import 'place_provider.dart';

class SelectedZipCodeLink {
  final int zipCodeLinkId;
  final String label;

  const SelectedZipCodeLink({required this.zipCodeLinkId, required this.label});
}

class AddPlaceState {
  final String placeName;
  final List<SelectedZipCodeLink> selectedZipCodes;
  final bool isSubmitting;
  final String? error;
  final PlaceModel? created;

  const AddPlaceState({
    this.placeName = '',
    this.selectedZipCodes = const [],
    this.isSubmitting = false,
    this.error,
    this.created,
  });

  AddPlaceState copyWith({
    String? placeName,
    List<SelectedZipCodeLink>? selectedZipCodes,
    bool? isSubmitting,
    String? error,
    PlaceModel? created,
  }) {
    return AddPlaceState(
      placeName: placeName ?? this.placeName,
      selectedZipCodes: selectedZipCodes ?? this.selectedZipCodes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      created: created ?? this.created,
    );
  }
}

class AddPlaceNotifier extends Notifier<AddPlaceState> {
  @override
  AddPlaceState build() {
    return const AddPlaceState();
  }

  void setName(String value) {
    state = state.copyWith(placeName: value, error: null);
  }

  bool isZipSelected(int id) {
    return state.selectedZipCodes.any((zip) => zip.zipCodeLinkId == id);
  }

  void addZip(SelectedZipCodeLink zip) {
    if (isZipSelected(zip.zipCodeLinkId)) {
      return;
    }

    state = state.copyWith(
      selectedZipCodes: [...state.selectedZipCodes, zip],
      error: null,
    );
  }

  void clearZips() {
    state = state.copyWith(selectedZipCodes: []);
  }

  void removeZip(int id) {
    state = state.copyWith(
      selectedZipCodes: state.selectedZipCodes
          .where((zip) => zip.zipCodeLinkId != id)
          .toList(),
      error: null,
    );
  }

  Future<PlaceModel?> submit() async {
    if (state.isSubmitting) return null;

    final trimmedName = state.placeName.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(error: 'Place name is required');
      return null;
    }

    if (state.selectedZipCodes.isEmpty) {
      state = state.copyWith(error: 'Select at least one zip code');
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final request = CreatePlaceRequest(
        placeName: trimmedName,
        zipCodeLinkIds: state.selectedZipCodes
            .map((zip) => zip.zipCodeLinkId)
            .toList(),
      );

      final created = await ref
          .read(placeProvider.notifier)
          .createPlace(request);
      state = const AddPlaceState();

      state = state.copyWith(isSubmitting: false, created: created);
      return created;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}

final addPlaceProvider = NotifierProvider<AddPlaceNotifier, AddPlaceState>(
  AddPlaceNotifier.new,
);
