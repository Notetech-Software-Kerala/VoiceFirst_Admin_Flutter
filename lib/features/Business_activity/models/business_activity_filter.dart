class BusinessActivityFilter {
  final String? searchBy;
  final String? searchText;

  final String? sortBy;
  final String? sortOrder;

  final bool? active;
  final bool? deleted;

  final int pageNumber;
  final int limit;

  final DateTime? createdFromDate;
  final DateTime? createdToDate;
  final DateTime? updatedFromDate;
  final DateTime? updatedToDate;
  final DateTime? deletedFromDate;
  final DateTime? deletedToDate;

  const BusinessActivityFilter({
    this.searchBy,
    this.searchText,
    this.sortBy,
    this.sortOrder,
    this.active,
    this.deleted,
    required this.pageNumber,
    required this.limit,
    this.createdFromDate,
    this.createdToDate,
    this.updatedFromDate,
    this.updatedToDate,
    this.deletedFromDate,
    this.deletedToDate,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'PageNumber': pageNumber.toString(),
      'PageSize': limit.toString(),
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

    add('SearchBy', searchBy);
    add('SearchText', searchText);
    add('SortBy', sortBy);
    add('SortOrder', sortOrder);

    if (active != null) {
      params['Active'] = active.toString();
    }
    if (deleted != null) {
      params['Deleted'] = deleted.toString();
    }

    addDate('CreatedFromDate', createdFromDate);
    addDate('CreatedToDate', createdToDate);
    addDate('UpdatedFromDate', updatedFromDate);
    addDate('UpdatedToDate', updatedToDate);
    addDate('DeletedFromDate', deletedFromDate);
    addDate('DeletedToDate', deletedToDate);

    return params;
  }
}

