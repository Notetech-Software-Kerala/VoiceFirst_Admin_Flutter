class DivisionOneFilter {
  final int pageNumber;
  final int pageSize;
  final String? searchText;

  const DivisionOneFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.searchText,
  });

  DivisionOneFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? searchText,
  }) {
    return DivisionOneFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchText: searchText ?? this.searchText,
    );
  }

  Map<String, String> toQueryParams(String countryId) {
    return {
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      'countryId': countryId,
      if (searchText != null && searchText!.isNotEmpty)
        'SearchText': searchText!,
    };
  }
}
