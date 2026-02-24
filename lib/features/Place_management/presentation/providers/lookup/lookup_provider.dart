import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/data/models/post_office_lookup_filter.dart';
import 'package:voice_first_admin/features/Place_management/data/place_service/place_lookup_service.dart';

/// SERVICE
final placeLookupServiceProvider = Provider<PlaceLookupService>((ref) {
  return PlaceLookupService();
});

// ===============================
// COUNTRY
// ===============================
final countryLookupProvider = FutureProvider.autoDispose<List<CountryLookup>>((
  ref,
) {
  return ref.read(placeLookupServiceProvider).getCountries();
});

// ===============================
// DIVISION 1
// ===============================
final divisionOneLookupProvider = FutureProvider.autoDispose
    .family<List<DivisionOneLookup>, int>((ref, countryId) {
      return ref.read(placeLookupServiceProvider).getDivisionOne(countryId);
    });

// ===============================
// DIVISION 2
// ===============================
final divisionTwoLookupProvider = FutureProvider.autoDispose
    .family<List<DivisionTwoLookup>, int>((ref, divOneId) {
      return ref.read(placeLookupServiceProvider).getDivisionTwo(divOneId);
    });

// ===============================
// DIVISION 3
// ===============================
final divisionThreeLookupProvider = FutureProvider.autoDispose
    .family<List<DivisionThreeLookup>, int>((ref, divTwoId) {
      return ref.read(placeLookupServiceProvider).getDivisionThree(divTwoId);
    });

// ===============================
// POST OFFICE
// ===============================
final postOfficeLookupProvider = FutureProvider.autoDispose
    .family<List<PostOfficeLookup>, PostOfficeLookupFilter>((ref, filter) {
      if (!filter.isReady) return Future.value([]);

      return ref
          .read(placeLookupServiceProvider)
          .getPostOffices(
            countryId: filter.countryId,
            divOneId: filter.divOneId,
            divTwoId: filter.divTwoId,
            divThreeId: filter.divThreeId,
            placeId: filter.placeId,
          );
    });
    
// ===============================
// UNLINKED ZIP PROVIDER (EDIT PAGE)
// ===============================
final unlinkedZipCodesProvider = FutureProvider.autoDispose
    .family<List<ZipCodeLookup>, ({int postOfficeId, int placeId})>(
  (ref, params) {
    return ref.read(placeLookupServiceProvider).getUnlinkedZipCodes(
          postOfficeIds: [params.postOfficeId],
          placeId: params.placeId,
        );
  },
);
