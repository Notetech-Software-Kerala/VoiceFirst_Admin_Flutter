import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/data/models/post_office_lookup_filter.dart';
import 'package:voice_first_admin/features/Place_management/data/place_service/place_lookup_service.dart';

/// SERVICE
final placeLookupServiceProvider = Provider<PlaceLookupService>((ref) {
  return PlaceLookupService();
});



final postOfficeLookupProvider = FutureProvider.autoDispose
    .family<
      PaginatedLookupResponse<PostOfficeLookup>,
      (PostOfficeLookupFilter, int, String)
    >((ref, params) {
      final filter = params.$1;
      final page = params.$2;
      final searchText = params.$3;

      if (!filter.isReady) {
        return Future.value(
          PaginatedLookupResponse(
            items: [],
            totalCount: 0,
            totalPages: 1,
            currentPage: 1,
          ),
        );
      }

      return ref
          .read(placeLookupServiceProvider)
          .getPostOffices(
            countryId: filter.countryId!,
            divOneId: filter.divOneId!,
            divTwoId: filter.divTwoId!,
            divThreeId: filter.divThreeId!,
            pageNumber: page,
            searchText: searchText.isEmpty ? null : searchText,
          );
    });

// ===============================
// UNLINKED ZIP PROVIDER (EDIT PAGE)
// ===============================

final unlinkedZipCodesProvider =
    FutureProvider.family<
      List<ZipCodeLookup>,
      ({int postOfficeId, int placeId})
    >((ref, params) {
      return ref
          .read(placeLookupServiceProvider)
          .getUnlinkedZipCodes(
            postOfficeIds: [params.postOfficeId],
            placeId: params.placeId,
          );
    });
