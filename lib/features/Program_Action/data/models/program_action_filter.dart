class ProgramActionFilter {
  final int pageNumber;
  final int pageSize;
  final String? search;

  const ProgramActionFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
  });

  ProgramActionFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
  }) {
    return ProgramActionFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      if (search != null && search!.isNotEmpty) 'SearchText': search,
    };
  }
}
