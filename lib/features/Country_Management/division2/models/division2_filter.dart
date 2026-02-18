class DivisionTwoFilter {
  final int pageNumber;
  final int pageSize;
  final String? searchText;
  final int divisionOneId;

  const DivisionTwoFilter({
    required this.divisionOneId,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.searchText,
  });

  DivisionTwoFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? searchText,
    int? divisionOneId,
  }) {
    return DivisionTwoFilter(
      divisionOneId: divisionOneId ?? this.divisionOneId,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchText: searchText ?? this.searchText,
    );
  }

  Map<String, String> toQueryParams() {
    return {
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      'divisionOneId': divisionOneId.toString(),
      if (searchText != null && searchText!.isNotEmpty)
        'SearchText': searchText!,
    };
  }
}
