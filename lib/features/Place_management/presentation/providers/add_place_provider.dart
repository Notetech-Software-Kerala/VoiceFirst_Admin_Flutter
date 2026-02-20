import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/models/post_office_lookup_filter.dart';

/// ================= STATE =================

class AddPlaceFormState {
  final int? countryId;
  final int? divOneId;
  final int? divTwoId;
  final int? divThreeId;

  /// selected zipcodes from ANY post office (for add place)
  final Set<int> zipCodeIds;

  /// Edit-specific: full zip code items with state
  // final List<EditZipCodeItem> zipCodeItems;
  // final Set<int> selectedZipIds;

  const AddPlaceFormState({
    this.countryId,
    this.divOneId,
    this.divTwoId,
    this.divThreeId,
    this.zipCodeIds = const {},
    // this.zipCodeItems = const [],
    // this.selectedZipIds = const {},
  });

  AddPlaceFormState copyWith({
    int? countryId,
    int? divOneId,
    int? divTwoId,
    int? divThreeId,
    Set<int>? zipCodeIds,
    // List<EditZipCodeItem>? zipCodeItems,
    // Set<int>? selectedZipIds,
  }) {
    return AddPlaceFormState(
      countryId: countryId ?? this.countryId,
      divOneId: divOneId ?? this.divOneId,
      divTwoId: divTwoId ?? this.divTwoId,
      divThreeId: divThreeId ?? this.divThreeId,
      zipCodeIds: zipCodeIds ?? this.zipCodeIds,
      // zipCodeItems: zipCodeItems ?? this.zipCodeItems,
      // selectedZipIds: selectedZipIds ?? this.selectedZipIds,
    );
  }
}

class AddPlaceFormNotifier extends Notifier<AddPlaceFormState> {
  @override
  AddPlaceFormState build() {
    return const AddPlaceFormState();
  }

  // ✅ Change country → clear only divisions
  void setCountry(int id) {
    state = state.copyWith(
      countryId: id,
      divOneId: null,
      divTwoId: null,
      divThreeId: null,
    );
  }

  // ✅ Change division 1 → clear lower only
  void setDivOne(int id) {
    state = state.copyWith(divOneId: id, divTwoId: null, divThreeId: null);
  }

  // ✅ Change division 2 → clear lower only
  void setDivTwo(int id) {
    state = state.copyWith(divTwoId: id, divThreeId: null);
  }

  void setDivThree(int id) {
    state = state.copyWith(divThreeId: id);
  }

  // Selection logic unchanged
  void toggleZip(int id) {
    final updated = Set<int>.from(state.zipCodeIds);

    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    state = state.copyWith(zipCodeIds: updated);
  }

  void selectAllZipCodes(List<int> ids) {
    final updated = Set<int>.from(state.zipCodeIds);
    updated.addAll(ids);
    state = state.copyWith(zipCodeIds: updated);
  }

  void unselectAllZipCodes(List<int> ids) {
    final updated = Set<int>.from(state.zipCodeIds);
    updated.removeAll(ids);
    state = state.copyWith(zipCodeIds: updated);
  }

  void clear() {
    state = const AddPlaceFormState();
  }
}

/// ================= PROVIDERS =================

final addPlaceFormProvider =
    NotifierProvider<AddPlaceFormNotifier, AddPlaceFormState>(
      AddPlaceFormNotifier.new,
    );

/// ⭐ Filter Provider
final postOfficeFilterProvider = Provider<PostOfficeLookupFilter>((ref) {
  final form = ref.watch(addPlaceFormProvider);

  return PostOfficeLookupFilter(
    countryId: form.countryId,
    divOneId: form.divOneId,
    divTwoId: form.divTwoId,
    divThreeId: form.divThreeId,
  );
});
