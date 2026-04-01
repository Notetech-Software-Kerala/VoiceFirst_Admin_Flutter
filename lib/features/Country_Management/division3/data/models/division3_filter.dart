import 'package:voice_first_admin/core/models/base_filter_model.dart';

class DivisionThreeFilter extends BaseFilterModel {
  final int pageNumber;
  final int pageSize;
  final int divisionTwoId;

  const DivisionThreeFilter({
    required this.divisionTwoId,
    this.pageNumber = 1,
    this.pageSize = 10,
    super.searchText,
    super.searchBy,
    super.sortBy,
    super.sortOrder,
    super.active,
    super.deleted,
  });

  // Do not override copyWith; rely on BaseFilterModel for base fields and construct new filter instances as needed.

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      'divisionTwoId': divisionTwoId.toString(),
    };

    if (searchText != null && searchText!.isNotEmpty) {
      params['SearchText'] = searchText!;
    }
    if (searchBy != null && searchBy!.isNotEmpty) {
      params['SearchBy'] = searchBy!;
    }
    if (sortBy != null && sortBy!.isNotEmpty) {
      params['SortBy'] = sortBy!;
      params['SortOrder'] = sortOrder;
    }
    if (active != null) params['Active'] = active! ? 'true' : 'false';
    if (deleted != null) params['Deleted'] = deleted! ? 'true' : 'false';

    return params;
  }
}
