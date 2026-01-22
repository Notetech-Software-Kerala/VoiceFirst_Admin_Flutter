class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  // Add getter for backward compatibility
  int get currentPage => pageNumber;

  PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });
}
