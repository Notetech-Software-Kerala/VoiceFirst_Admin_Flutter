import 'package:voice_first_admin/core/models/base_filter_model.dart';

class CountryFilter extends BaseFilterModel {
  final int pageNumber;
  final int pageSize;

  const CountryFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    super.searchText,
    super.searchBy,
    super.sortBy,
    super.sortOrder,
    super.active,
    super.deleted,
    super.createdFromDate,
    super.createdToDate,
    super.updatedFromDate,
    super.updatedToDate,
    super.deletedFromDate,
    super.deletedToDate,
  });

  // Note: rely on BaseFilterModel.copyWith for base fields; do not override copyWith here.

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
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
