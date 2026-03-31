import 'package:voice_first_admin/core/models/base_filter_model.dart';

class IssueCharacterTypeFilter extends BaseFilterModel {
  final int pageNumber;
  final int pageSize;

  const IssueCharacterTypeFilter({
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

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
    };

    void add(String key, String? value) {
      if (value != null && value.isNotEmpty) params[key] = value;
    }

    void addDate(String key, DateTime? value) {
      if (value != null) params[key] = value.toIso8601String();
    }

    add('SearchText', searchText);
    add('SearchBy', searchBy);

    if (sortBy != null && sortBy!.isNotEmpty) {
      params['SortBy'] = sortBy!;
      if (sortOrder != null && sortOrder!.isNotEmpty) {
        params['SortOrder'] = sortOrder!;
      }
    }

    if (active != null) params['Active'] = active! ? 'true' : 'false';
    if (deleted != null) params['Deleted'] = deleted! ? 'true' : 'false';

    addDate('CreatedFromDate', createdFromDate);
    addDate('CreatedToDate', createdToDate);
    addDate('UpdatedFromDate', updatedFromDate);
    addDate('UpdatedToDate', updatedToDate);
    addDate('DeletedFromDate', deletedFromDate);
    addDate('DeletedToDate', deletedToDate);

    return params;
  }

  IssueCharacterTypeFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? searchText,
    String? searchBy,
    String? sortBy,
    String? sortOrder,
    bool? active,
    bool? deleted,
    DateTime? createdFromDate,
    DateTime? createdToDate,
    DateTime? updatedFromDate,
    DateTime? updatedToDate,
    DateTime? deletedFromDate,
    DateTime? deletedToDate,
  }) {
    return IssueCharacterTypeFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchText: searchText ?? this.searchText,
      searchBy: searchBy ?? this.searchBy,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      createdFromDate: createdFromDate ?? this.createdFromDate,
      createdToDate: createdToDate ?? this.createdToDate,
      updatedFromDate: updatedFromDate ?? this.updatedFromDate,
      updatedToDate: updatedToDate ?? this.updatedToDate,
      deletedFromDate: deletedFromDate ?? this.deletedFromDate,
      deletedToDate: deletedToDate ?? this.deletedToDate,
    );
  }
}
