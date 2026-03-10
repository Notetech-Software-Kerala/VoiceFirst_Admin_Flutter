class IssueMediaFormatFilter {
  final int pageNumber;
  final int pageSize;
  final String? search;

  const IssueMediaFormatFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
  });

  IssueMediaFormatFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
  }) {
    return IssueMediaFormatFilter(
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
