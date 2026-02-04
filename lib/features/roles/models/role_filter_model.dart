class RoleFilterModel {
  final String? searchBy;
  final String? searchText;
  final DateTime? createdFromDate;
  final DateTime? createdToDate;
  final DateTime? updatedFromDate;
  final DateTime? updatedToDate;
  final DateTime? deletedFromDate;
  final DateTime? deletedToDate;
  final String? sortBy;
  final String sortOrder; // 'asc' or 'desc'
  final bool? active;
  final bool? deleted;
  final int pageNumber;
  final int limit;

  const RoleFilterModel({
    this.searchBy,
    this.searchText,
    this.createdFromDate,
    this.createdToDate,
    this.updatedFromDate,
    this.updatedToDate,
    this.deletedFromDate,
    this.deletedToDate,
    this.sortBy,
    this.sortOrder = 'desc',
    this.active,
    this.deleted,
    this.pageNumber = 1,
    this.limit = 10,
  });

  RoleFilterModel copyWith({
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
  }) {
    return RoleFilterModel(
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
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'pageNumber': pageNumber.toString(),
      'limit': limit.toString(),
      'sortOrder': sortOrder,
    };

    if (searchBy != null && searchBy!.isNotEmpty)
      params['searchBy'] = searchBy!;
    if (searchText != null && searchText!.isNotEmpty)
      params['searchText'] = searchText!;
    if (sortBy != null && sortBy!.isNotEmpty) params['sortBy'] = sortBy!;

    if (active != null) params['active'] = active.toString();
    if (deleted != null) params['deleted'] = deleted.toString();

    if (createdFromDate != null)
      params['createdFromDate'] = createdFromDate!.toIso8601String();
    if (createdToDate != null)
      params['createdToDate'] = createdToDate!.toIso8601String();

    if (updatedFromDate != null)
      params['updatedFromDate'] = updatedFromDate!.toIso8601String();
    if (updatedToDate != null)
      params['updatedToDate'] = updatedToDate!.toIso8601String();

    if (deletedFromDate != null)
      params['deletedFromDate'] = deletedFromDate!.toIso8601String();
    if (deletedToDate != null)
      params['deletedToDate'] = deletedToDate!.toIso8601String();

    return params;
  }
}
