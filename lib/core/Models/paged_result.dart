class PagedResult<T> {
  final List<T> items;
  final int totalCount;

  PagedResult({required this.items, required this.totalCount});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PagedResult(
      items: (json['items'] as List).map((e) => fromJson(e)).toList(),
      totalCount: json['totalCount'],
    );
  }
}
