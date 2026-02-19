class CountryFilter {
  final int pageNumber;
  final int pageSize;
  final String? searchText;

  const CountryFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.searchText,
  });

  CountryFilter copyWith({int? pageNumber, int? pageSize, String? searchText}) {
    return CountryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchText: searchText ?? this.searchText,
    );
  }

  Map<String, String> toQueryParams() {
    return {
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      if (searchText != null && searchText!.isNotEmpty)
        'SearchText': searchText!,
    };
  }
}
