import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post_office_lookup_filter.dart';
import 'add_place_provider.dart';

/// Edit form state for place management
class EditPlaceFormNotifier extends Notifier<AddPlaceFormState> {
  @override
  AddPlaceFormState build() {
    return const AddPlaceFormState();
  }

  void reset() {
    state = const AddPlaceFormState();
  }

  void setCountry(int id) {
    state = AddPlaceFormState(
      countryId: id,
      divOneId: null,
      divTwoId: null,
      divThreeId: null,
      zipCodeIds: {},
    );
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
}

/// Simple form provider (one edit form at a time)
final editPlaceFormProvider =
    NotifierProvider<EditPlaceFormNotifier, AddPlaceFormState>(
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
