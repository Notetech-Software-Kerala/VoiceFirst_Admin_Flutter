class CustomFieldFilter {
  final int pageNumber;
  final int pageSize;
  final String? search;

  const CustomFieldFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    return params;
  }
}
