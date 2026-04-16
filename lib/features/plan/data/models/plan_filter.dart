import 'package:voice_first_admin/core/models/base_filter_model.dart';

class PlanFilter extends BaseFilterModel {
  final int pageNumber;
  final int limit;

  const PlanFilter({
    this.pageNumber = 1,
    this.limit = 10,
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

  @override
  PlanFilter copyWith({
    int? pageNumber,
    int? limit,
    String? searchBy,
    String? searchText,
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
    return PlanFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      limit: limit ?? this.limit,
      searchBy: searchBy ?? this.searchBy,
      searchText: searchText ?? this.searchText,
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

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'PageNumber': pageNumber.toString(),
      'Limit': limit.toString(),
    };

    void add(String key, String? value) {
      if (value != null && value.isNotEmpty) params[key] = value;
    }

    void addDate(String key, DateTime? value) {
      if (value != null) params[key] = value.toIso8601String();
    }

    add('SearchBy', searchBy);
    add('SearchText', searchText);
    add('SortBy', sortBy);
    // Only include SortOrder when SortBy is provided
    if ((sortBy?.isNotEmpty ?? false) && (sortOrder.isNotEmpty)) {
      add('SortOrder', sortOrder);
    }

    if (active != null) params['Active'] = active.toString().toLowerCase();
    if (deleted != null) params['Deleted'] = deleted.toString().toLowerCase();

    addDate('CreatedFromDate', createdFromDate);
    addDate('CreatedToDate', createdToDate);
    addDate('UpdatedFromDate', updatedFromDate);
    addDate('UpdatedToDate', updatedToDate);
    addDate('DeletedFromDate', deletedFromDate);
    addDate('DeletedToDate', deletedToDate);

    return params;
  }
}
