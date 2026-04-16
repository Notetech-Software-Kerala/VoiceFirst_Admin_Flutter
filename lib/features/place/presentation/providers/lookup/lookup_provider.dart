import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/place/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/place/data/models/post_office_lookup_filter.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/place/data/repositories/place_lookup_repository.dart'
    show PlaceLookupRepository;

/// REPOSITORY
final placeLookupRepositoryProvider = Provider<PlaceLookupRepository>((ref) {
  return PlaceLookupRepository(ref.read(dioClientProvider));
});

// ===============================
// COUNTRY
// ===============================
final countryLookupProvider = FutureProvider.autoDispose<List<CountryLookup>>((
  ref,
) {
  return ref.read(placeLookupRepositoryProvider).getCountries();
});

// ===============================
// DIVISION 1
// ===============================
final divisionOneLookupProvider = FutureProvider.autoDispose
    .family<List<DivisionOneLookup>, int>((ref, countryId) {
      return ref.read(placeLookupRepositoryProvider).getDivisionOne(countryId);
    });

// ===============================
// DIVISION 2
// ===============================
final divisionTwoLookupProvider = FutureProvider.autoDispose
    .family<List<DivisionTwoLookup>, int>((ref, divOneId) {
      return ref.read(placeLookupRepositoryProvider).getDivisionTwo(divOneId);
    });

// ===============================
// DIVISION 3
// ===============================
final divisionThreeLookupProvider = FutureProvider.autoDispose
    .family<List<DivisionThreeLookup>, int>((ref, divTwoId) {
      return ref.read(placeLookupRepositoryProvider).getDivisionThree(divTwoId);
    });

// ===============================
// POST OFFICE
// ===============================
final postOfficeLookupProvider = FutureProvider.autoDispose
    .family<List<PostOfficeLookup>, PostOfficeLookupFilter>((ref, filter) {
      if (!filter.isReady) return Future.value([]);

      return ref
          .read(placeLookupRepositoryProvider)
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
    .family<List<ZipCodeLookup>, ({int postOfficeId, int placeId})>((
      ref,
      params,
    ) {
      return ref
          .read(placeLookupRepositoryProvider)
          .getUnlinkedZipCodes(
            postOfficeIds: [params.postOfficeId],
            placeId: params.placeId,
          );
    });
