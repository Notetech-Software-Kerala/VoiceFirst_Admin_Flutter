class BusinessActivityFilter {
  final String? searchText;
  final String? sortBy;
  final String? sortOrder;
  final int pageNumber;
  final int limit;
  final bool? active;
  final bool? deleted;

  final DateTime? createdFromDate;
  final DateTime? createdToDate;
  final DateTime? updatedFromDate;
  final DateTime? updatedToDate;
  final DateTime? deletedFromDate;
  final DateTime? deletedToDate;

  BusinessActivityFilter({
    this.searchText,
    this.sortBy,
    this.sortOrder,
    this.active,
    this.deleted,
    this.createdFromDate,
    this.createdToDate,
    this.updatedFromDate,
    this.updatedToDate,
    this.deletedFromDate,
    this.deletedToDate,
    this.pageNumber = 1,
    this.limit = 20,
  });

  Map<String, String> toQueryParams() {
    final map = <String, String>{
      'PageNumber': pageNumber.toString(),
      'Limit': limit.toString(),
    };

    void add(String key, dynamic value) {
      if (value == null) return;
      map[key] = value is DateTime
          ? value.toIso8601String()
          : value.toString();
    }

    add('SearchText', searchText);
    add('SortBy', sortBy);
    add('SortOrder', sortOrder);
    add('Active', active);
    add('Deleted', deleted);
    add('CreatedFromDate', createdFromDate);
    add('CreatedToDate', createdToDate);
    add('UpdatedFromDate', updatedFromDate);
    add('UpdatedToDate', updatedToDate);
    add('DeletedFromDate', deletedFromDate);
    add('DeletedToDate', deletedToDate);

    return map;
  }
}
