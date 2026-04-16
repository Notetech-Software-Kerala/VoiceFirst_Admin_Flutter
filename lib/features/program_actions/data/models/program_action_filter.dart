import 'package:voice_first_admin/core/models/base_filter_model.dart';

class ProgramActionFilter extends BaseFilterModel {
  final int pageNumber;
  final int limit;

  const ProgramActionFilter({
    this.pageNumber = 1,
    this.limit = 10,
    super.searchBy,
    super.searchText,
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
  ProgramActionFilter copyWith({
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
    return ProgramActionFilter(
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

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'PageNumber': pageNumber.toString(),
      'PageSize': limit.toString(),
    };
    if (searchBy != null && searchBy!.isNotEmpty) params['SearchBy'] = searchBy;
    if (searchText != null && searchText!.isNotEmpty) {
      params['SearchText'] = searchText;
    }
    if (sortBy != null && sortBy!.isNotEmpty) {
      params['SortBy'] = sortBy;
      if (sortOrder.isNotEmpty) params['SortOrder'] = sortOrder;
    }
    if (active != null) params['Active'] = active.toString().toLowerCase();
    if (deleted != null) params['Deleted'] = deleted.toString().toLowerCase();
    if (createdFromDate != null) {
      params['CreatedFromDate'] = createdFromDate!.toIso8601String();
    }
    if (createdToDate != null) {
      params['CreatedToDate'] = createdToDate!.toIso8601String();
    }
    if (updatedFromDate != null) {
      params['UpdatedFromDate'] = updatedFromDate!.toIso8601String();
    }
    if (updatedToDate != null) {
      params['UpdatedToDate'] = updatedToDate!.toIso8601String();
    }
    if (deletedFromDate != null) {
      params['DeletedFromDate'] = deletedFromDate!.toIso8601String();
    }
    if (deletedToDate != null) {
      params['DeletedToDate'] = deletedToDate!.toIso8601String();
    }
    return params;
  }
}
