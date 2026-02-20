class UserFilterModel {
  final String? searchBy;
  final String? searchText;
  final DateTime? createdFromDate;
  final DateTime? createdToDate;
  final DateTime? updatedFromDate;
  final DateTime? updatedToDate;
  final DateTime? deletedFromDate;
  final DateTime? deletedToDate;
  final String? sortBy;
  final String sortOrder;
  final bool? active;
  final bool? deleted;
  final int pageNumber;
  final int limit;

  // Convenience for UI filtering
  final String? role;

  const UserFilterModel({
    this.searchBy,
    this.searchText,
    this.createdFromDate,
    this.createdToDate,
    this.updatedFromDate,
    this.updatedToDate,
    this.deletedFromDate,
    this.deletedToDate,
    this.sortBy,
    this.sortOrder = 'Desc',
    this.active,
    this.deleted,
    this.pageNumber = 1,
    this.limit = 10,
    this.role,
  });

  UserFilterModel copyWith({
    String? searchBy,
    String? searchText,
    DateTime? createdFromDate,
    DateTime? createdToDate,
    DateTime? updatedFromDate,
    DateTime? updatedToDate,
    DateTime? deletedFromDate,
    DateTime? deletedToDate,
    String? sortBy,
    String? sortOrder,
    bool? active,
    bool? deleted,
    int? pageNumber,
    int? limit,
    String? role,
  }) {
    return UserFilterModel(
      searchBy: searchBy ?? this.searchBy,
      searchText: searchText ?? this.searchText,
      createdFromDate: createdFromDate ?? this.createdFromDate,
      createdToDate: createdToDate ?? this.createdToDate,
      updatedFromDate: updatedFromDate ?? this.updatedFromDate,
      updatedToDate: updatedToDate ?? this.updatedToDate,
      deletedFromDate: deletedFromDate ?? this.deletedFromDate,
      deletedToDate: deletedToDate ?? this.deletedToDate,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      pageNumber: pageNumber ?? this.pageNumber,
      limit: limit ?? this.limit,
      role: role ?? this.role,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'PageNumber': pageNumber.toString(),
      'Limit': limit.toString(),
      'SortOrder': sortOrder,
    };

    if (searchBy != null && searchBy!.isNotEmpty) {
      params['SearchBy'] = searchBy!;
    }
    if (searchText != null && searchText!.isNotEmpty) {
      params['SearchText'] = searchText!;
    }
    if (sortBy != null && sortBy!.isNotEmpty) {
      params['SortBy'] = sortBy!;
    }

    if (active != null) params['Active'] = active.toString();
    if (deleted != null) params['Deleted'] = deleted.toString();

    if (createdFromDate != null) {
      params['CreatedFromDate'] = createdFromDate!.toIso8601String();
    }
    if (createdToDate != null) {
      params['CreatedToDate'] = createdToDate!.toIso8601String();
    }
    // Add other date params if needed

    return params;
  }
}
