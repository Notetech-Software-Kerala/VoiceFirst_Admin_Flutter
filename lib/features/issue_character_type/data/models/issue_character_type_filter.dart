class IssueCharacterTypeFilter {
  final int pageNumber;
  final int pageSize;
  final String? search;

  const IssueCharacterTypeFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
  });

  IssueCharacterTypeFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
  }) {
    return IssueCharacterTypeFilter(
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
