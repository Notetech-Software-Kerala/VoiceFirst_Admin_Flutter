import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/place/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/place/data/models/place_model.dart';
import 'package:voice_first_admin/features/place/data/models/post_office_lookup_filter.dart';

/// ================= DIFF MODEL =================

class UpdateZipDiff {
  final List<ZipCodeLinkUpdate> updateZipCodes;
  final List<int> insertZipIds;

  const UpdateZipDiff({
    required this.updateZipCodes,
    required this.insertZipIds,
  });
}

/// ================= EDIT FORM STATE =================
class EditPlaceFormState extends Equatable {
  final int? countryId;
  final int? divOneId;
  final int? divTwoId;
  final int? divThreeId;

  final List<EditZipCodeItem> zipCodeItems;
  final Set<int> selectedZipIds;

  const EditPlaceFormState({
    this.countryId,
    this.divOneId,
    this.divTwoId,
    this.divThreeId,
    this.zipCodeItems = const [],
    this.selectedZipIds = const {},
  });

  EditPlaceFormState copyWith({
    int? countryId,
    int? divOneId,
    int? divTwoId,
    int? divThreeId,
    List<EditZipCodeItem>? zipCodeItems,
    Set<int>? selectedZipIds,
  }) {
    return EditPlaceFormState(
      countryId: countryId ?? this.countryId,
      divOneId: divOneId ?? this.divOneId,
      divTwoId: divTwoId ?? this.divTwoId,
      divThreeId: divThreeId ?? this.divThreeId,
      zipCodeItems: zipCodeItems ?? this.zipCodeItems,
      selectedZipIds: selectedZipIds ?? this.selectedZipIds,
    );
  }

  @override
  List<Object?> get props => [
    countryId,
    divOneId,
    divTwoId,
    divThreeId,
    zipCodeItems,
    selectedZipIds,
  ];
}

class EditZipCodeItem {
  final int postOfficeId;
  final int zipCodeLinkId;
  final String zipCode;
  final String postOfficeName;
  final bool isNew;
  final bool isActive;

  const EditZipCodeItem({
    required this.postOfficeId,
    required this.zipCodeLinkId,
    required this.zipCode,
    required this.postOfficeName,
    required this.isNew,
    required this.isActive,
  });

  EditZipCodeItem copyWith({
    int? postOfficeId,
    int? zipCodeLinkId,
    String? zipCode,
    String? postOfficeName,
    bool? isNew,
    bool? isActive,
  }) {
    return EditZipCodeItem(
      postOfficeId: postOfficeId ?? this.postOfficeId,
      zipCodeLinkId: zipCodeLinkId ?? this.zipCodeLinkId,
      zipCode: zipCode ?? this.zipCode,
      postOfficeName: postOfficeName ?? this.postOfficeName,
      isNew: isNew ?? this.isNew,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Edit form state for place management
///
class EditPlaceFormNotifier extends Notifier<EditPlaceFormState> {
  @override
  EditPlaceFormState build() {
    return const EditPlaceFormState();
  }

  void reset() {
    state = const EditPlaceFormState();
  }

  /// Initialize edit form from existing place
  void initializeFromPlace(PlaceModel place) {
    final items = <EditZipCodeItem>[];
    final selectedIds = <int>{};

    for (final office in place.postOffices) {
      for (final zip in office.zipCodes) {
        final item = EditZipCodeItem(
          postOfficeId: office.postOfficeId,
          zipCodeLinkId: zip.zipCodeLinkId,
          zipCode: zip.zipCode,
          postOfficeName: office.postOfficeName,
          isActive: zip.active,
          isNew: false,
        );
        items.add(item);
        selectedIds.add(zip.zipCodeLinkId);
      }
    }

    state = state.copyWith(zipCodeItems: items, selectedZipIds: selectedIds);
  }

  void setCountry(int id) {
    state = state.copyWith(
      countryId: id,
      divOneId: null,
      divTwoId: null,
      divThreeId: null,
    );
  }

  void setDivOne(int id) {
    state = state.copyWith(divOneId: id, divTwoId: null, divThreeId: null);
  }

  void setDivTwo(int id) {
    state = state.copyWith(divTwoId: id, divThreeId: null);
  }

  void setDivThree(int id) {
    state = state.copyWith(divThreeId: id);
  }

  void clearHierarchy() {
    state = state.copyWith(
      countryId: null,
      divOneId: null,
      divTwoId: null,
      divThreeId: null,
    );
  }

  /// Toggle individual zip code active state
  void toggleZip(int zipCodeLinkId) {
    final items = <EditZipCodeItem>[];
    final selectedIds = Set<int>.from(state.selectedZipIds);

    for (final item in state.zipCodeItems) {
      if (item.zipCodeLinkId == zipCodeLinkId) {
        final newActiveState = !item.isActive;

        if (item.isNew && !newActiveState) {
          // NEW item unchecked → remove completely
          selectedIds.remove(zipCodeLinkId);
          continue; // skip adding to items
        } else {
          // Toggle active state
          items.add(item.copyWith(isActive: newActiveState));
        }
      } else {
        items.add(item);
      }
    }

    state = state.copyWith(zipCodeItems: items, selectedZipIds: selectedIds);
  }

  /// Add a new zip code to the place
  void addNewZip({
    required int postOfficeId,
    required int zipCodeLinkId,
    required String zipCode,
    required String postOfficeName,
  }) {
    // Check if already exists
    if (state.selectedZipIds.contains(zipCodeLinkId)) {
      return;
    }

    final newItem = EditZipCodeItem(
      postOfficeId: postOfficeId,
      zipCodeLinkId: zipCodeLinkId,
      zipCode: zipCode,
      postOfficeName: postOfficeName,
      isActive: true,
      isNew: true,
    );

    final items = List<EditZipCodeItem>.from(state.zipCodeItems)..add(newItem);
    final selectedIds = Set<int>.from(state.selectedZipIds)..add(zipCodeLinkId);

    state = state.copyWith(zipCodeItems: items, selectedZipIds: selectedIds);
  }

  /// Remove a new zip code (only works for isNew = true)
  void removeNewZip(int zipCodeLinkId) {
    final items = state.zipCodeItems
        .where((item) => item.zipCodeLinkId != zipCodeLinkId || !item.isNew)
        .toList();

    final selectedIds = Set<int>.from(state.selectedZipIds)
      ..remove(zipCodeLinkId);

    state = state.copyWith(zipCodeItems: items, selectedZipIds: selectedIds);
  }

  /// Get items for a specific office
  // ignore: unused_element
  List<EditZipCodeItem> _itemsForOffice(int officeId) {
    return state.zipCodeItems
        .where((item) => item.postOfficeId == officeId)
        .toList();
  }

  /// Select all zip codes for an office
  void selectAllOffice(
    int officeId,
    String officeName,
    List<ZipCodeLookup> unlinkedZips,
  ) {
    final items = List<EditZipCodeItem>.from(state.zipCodeItems);
    final selectedIds = Set<int>.from(state.selectedZipIds);

    // Activate existing items for this office
    for (var i = 0; i < items.length; i++) {
      if (items[i].postOfficeId == officeId) {
        items[i] = items[i].copyWith(isActive: true);
      }
    }

    // Add all unlinked zips as new items
    for (final zip in unlinkedZips) {
      if (!selectedIds.contains(zip.zipCodeLinkId)) {
        items.add(
          EditZipCodeItem(
            postOfficeId: officeId,
            zipCodeLinkId: zip.zipCodeLinkId,
            zipCode: zip.zipCode,
            postOfficeName: officeName,
            isActive: true,
            isNew: true,
          ),
        );
        selectedIds.add(zip.zipCodeLinkId);
      }
    }

    state = state.copyWith(zipCodeItems: items, selectedZipIds: selectedIds);
  }

  /// Deselect all zip codes for an office
  void deselectOffice(int officeId) {
    final items = <EditZipCodeItem>[];
    final selectedIds = Set<int>.from(state.selectedZipIds);

    for (final item in state.zipCodeItems) {
      if (item.postOfficeId == officeId) {
        if (item.isNew) {
          // Remove new items completely
          selectedIds.remove(item.zipCodeLinkId);
          continue; // skip adding
        } else {
          // Deactivate existing items
          items.add(item.copyWith(isActive: false));
        }
      } else {
        items.add(item);
      }
    }

    state = state.copyWith(zipCodeItems: items, selectedZipIds: selectedIds);
  }

  /// Check if all zip codes for an office are selected and active
  bool isOfficeFullyLinked(
    int officeId,
    int backendLinkedCount,
    int unlinkedCount,
  ) {
    final totalAvailable = backendLinkedCount + unlinkedCount;

    if (totalAvailable == 0) return false;

    // Count only ACTIVE items for this office
    final activeCount = state.zipCodeItems
        .where((item) => item.postOfficeId == officeId && item.isActive)
        .length;

    return activeCount == totalAvailable;
  }

  /// Build diff for update request
  UpdateZipDiff buildZipDiff(PlaceModel originalPlace) {
    final updateZipCodes = <ZipCodeLinkUpdate>[];
    final insertZipIds = <int>[];

    // Build original state map for comparison
    final originalZips = <int, bool>{};
    for (final office in originalPlace.postOffices) {
      for (final zip in office.zipCodes) {
        originalZips[zip.zipCodeLinkId] = zip.active;
      }
    }

    for (final item in state.zipCodeItems) {
      if (item.isNew) {
        // New zip codes
        if (item.isActive) {
          insertZipIds.add(item.zipCodeLinkId);
        }
      } else {
        // Existing zip codes - track if status changed
        final originalActive = originalZips[item.zipCodeLinkId];
        if (originalActive != null && originalActive != item.isActive) {
          updateZipCodes.add(
            ZipCodeLinkUpdate(
              zipCodeLinkId: item.zipCodeLinkId,
              active: item.isActive,
            ),
          );
        }
      }
    }

    return UpdateZipDiff(
      updateZipCodes: updateZipCodes,
      insertZipIds: insertZipIds,
    );
  }
}

/// Simple form provider (one edit form at a time)
final editPlaceFormProvider =
    NotifierProvider<EditPlaceFormNotifier, EditPlaceFormState>(
      EditPlaceFormNotifier.new,
    );

/// ✅ FILTER

final postOfficeFilterForEditProvider =
    Provider.family<PostOfficeLookupFilter, int>((ref, placeId) {
      final form = ref.watch(editPlaceFormProvider);

      return PostOfficeLookupFilter(
        countryId: form.countryId,
        divOneId: form.divOneId,
        divTwoId: form.divTwoId,
        divThreeId: form.divThreeId,
        placeId: placeId,
      );
    });
