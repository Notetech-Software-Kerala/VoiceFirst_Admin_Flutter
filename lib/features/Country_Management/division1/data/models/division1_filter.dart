import 'package:voice_first_admin/core/models/base_filter_model.dart';

class DivisionOneFilter extends BaseFilterModel {
  final int pageNumber;
  final int pageSize;
  final int countryId;

  const DivisionOneFilter({
    required this.countryId,
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

  // Do not override copyWith; use BaseFilterModel.copyWith for base fields.

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      'countryId': countryId.toString(),
    };

    void add(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        params[key] = value;
      }
    }

    void addDate(String key, DateTime? value) {
      if (value != null) {
        params[key] = value.toIso8601String();
      }
    }

    // 🔍 Search
    add('SearchBy', searchBy);
    add('SearchText', searchText);

    // 🔽 Sorting (safe handling)
    if (sortBy != null && sortBy!.isNotEmpty) {
      params['SortBy'] = sortBy!;
      params['SortOrder'] = sortOrder ?? 'asc';
    }

    // ✅ Status filters
    if (active != null) {
      params['Active'] = active! ? 'true' : 'false';
    }
    if (deleted != null) {
      params['Deleted'] = deleted! ? 'true' : 'false';
    }

    // 📅 Date filters
    addDate('CreatedFromDate', createdFromDate);
    addDate('CreatedToDate', createdToDate);
    addDate('UpdatedFromDate', updatedFromDate);
    addDate('UpdatedToDate', updatedToDate);
    addDate('DeletedFromDate', deletedFromDate);
    addDate('DeletedToDate', deletedToDate);

    return params;
  }
}
