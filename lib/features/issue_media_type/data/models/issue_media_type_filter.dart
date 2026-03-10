class IssueMediaTypeFilter {
  final int pageNumber;
  final int pageSize;
  final String? search;

  const IssueMediaTypeFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
  });

  IssueMediaTypeFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
  }) {
    return IssueMediaTypeFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
    };

    if (search != null && search!.isNotEmpty) {
      params['SearchText'] = search!;
    }

    return params;
  }
}
