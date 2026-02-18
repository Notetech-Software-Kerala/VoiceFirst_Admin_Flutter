import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/data/models/post_office_lookup_filter.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';

/// ================= STATE =================

class AddPlaceFormState {
  final int? countryId;
  final int? divOneId;
  final int? divTwoId;
  final int? divThreeId;

  /// selected zipcodes from ANY post office
  final Set<int> zipCodeIds;

  const AddPlaceFormState({
    this.countryId,
    this.divOneId,
    this.divTwoId,
    this.divThreeId,
    this.zipCodeIds = const {},
  });

  AddPlaceFormState copyWith({
    int? countryId,
    int? divOneId,
    int? divTwoId,
    int? divThreeId,
    Set<int>? zipCodeIds,
  }) {
    return AddPlaceFormState(
      countryId: countryId ?? this.countryId,
      divOneId: divOneId ?? this.divOneId,
      divTwoId: divTwoId ?? this.divTwoId,
      divThreeId: divThreeId ?? this.divThreeId,
      zipCodeIds: zipCodeIds ?? this.zipCodeIds,
    );
  }
}

/// ================= NOTIFIER =================

class AddPlaceFormNotifier extends Notifier<AddPlaceFormState> {
  @override
  AddPlaceFormState build() {
    return const AddPlaceFormState();
  }

  /// COUNTRY resets everything below
  void setCountry(int id) {
    state = AddPlaceFormState(countryId: id);
  }

  void setDivOne(int id) {
    state = state.copyWith(
      divOneId: id,
      divTwoId: null,
      divThreeId: null,
      zipCodeIds: {},
    );
  }

  void setDivTwo(int id) {
    state = state.copyWith(divTwoId: id, divThreeId: null, zipCodeIds: {});
  }

  void setDivThree(int id) {
    state = state.copyWith(divThreeId: id, zipCodeIds: {});
  }

  /// Toggle single zip
  void toggleZip(int id) {
    final updated = Set<int>.from(state.zipCodeIds);

    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    state = state.copyWith(zipCodeIds: updated);
  }

  /// Select ALL from a post office
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

// /// ⭐ Lazy zipcode loader WITH caching
// final zipCodesByPostOfficeProvider = FutureProvider.autoDispose
//     .family<List<ZipCodeLookup>, int>((ref, id) async {
//       /// keep cached after first load
//       ref.keepAlive();

//       final lookupService = ref.read(placeLookupServiceProvider);

//       return lookupService.getZipCodes(id);
//     });

final postOfficeFilterForEditProvider =
    Provider.family<PostOfficeLookupFilter, int>((ref, placeId) {
      final form = ref.watch(addPlaceFormProvider);

      return PostOfficeLookupFilter(
        countryId: form.countryId,
        divOneId: form.divOneId,
        divTwoId: form.divTwoId,
        divThreeId: form.divThreeId,
        placeId: placeId, // ⭐ KEY
      );
    });
