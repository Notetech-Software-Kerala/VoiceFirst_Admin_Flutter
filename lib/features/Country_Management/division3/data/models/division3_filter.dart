class DivisionThreeFilter {
  final int pageNumber;
  final int pageSize;
  final String? search;
  final int divisionTwoId;

  const DivisionThreeFilter({
    required this.divisionTwoId,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
  });

  DivisionThreeFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    int? divisionTwoId,
  }) {
    return DivisionThreeFilter(
      divisionTwoId: divisionTwoId ?? this.divisionTwoId,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
    );
  }

  Map<String, String> toQueryParams() {
    return {
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      'divisionTwoId': divisionTwoId.toString(),
      if (search != null && search!.isNotEmpty) 'SearchText': search!,
    };
  }
}
