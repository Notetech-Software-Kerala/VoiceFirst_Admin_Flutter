class PagedFilter {
  final int pageNumber;
  final int limit;
  final String? searchText;
  final String? sortBy;
  final String? sortOrder;
  final bool? active;
  final bool? deleted;

  const PagedFilter({
    this.pageNumber = 1,
    this.limit = 10,
    this.searchText,
    this.sortBy,
    this.sortOrder,
    this.active,
    this.deleted,
  });

  Map<String, dynamic> toQuery() => {
        'PageNumber': pageNumber,
        'Limit': limit,
        if (searchText?.isNotEmpty == true) 'SearchText': searchText,
        if (sortBy != null) 'SortBy': sortBy,
        if (sortOrder != null) 'SortOrder': sortOrder,
        if (active != null) 'Active': active,
        if (deleted != null) 'Deleted': deleted,
      };
}
