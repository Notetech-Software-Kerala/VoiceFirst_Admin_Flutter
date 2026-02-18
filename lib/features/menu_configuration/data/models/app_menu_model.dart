class AppMenuModel {
  final int appMenuId;
  final int parentId;
  final int menuId;
  final String menuName;
  final String icon;
  final String route;
  final int sortOrder;
  final bool active;
  final bool deleted;

  // Local UI helper for nested structure
  List<AppMenuModel> children;
  bool isVisible; // Local toggle state

  AppMenuModel({
    required this.appMenuId,
    required this.parentId,
    required this.menuId,
    required this.menuName,
    required this.icon,
    required this.route,
    required this.sortOrder,
    required this.active,
    required this.deleted,
    this.children = const [],
    this.isVisible = true,
  });

  factory AppMenuModel.fromJson(Map<String, dynamic> json) {
    return AppMenuModel(
      appMenuId: json['appMenuId'] ?? 0,
      parentId: json['parentId'] ?? 0,
      menuId: json['menuId'] ?? 0,
      menuName: json['menuName'] ?? '',
      icon: json['icon'] ?? '',
      route: json['route'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      active: json['active'] ?? true,
      deleted: json['deleted'] ?? false,
      isVisible:
          json['active'] ?? true, // Default local visibility to active status
    );
  }

  // To convert back if needed, mainly for UI updates to local state
  AppMenuModel copyWith({
    int? appMenuId,
    int? parentId,
    int? menuId,
    String? menuName,
    String? icon,
    String? route,
    int? sortOrder,
    bool? active,
    List<AppMenuModel>? children,
    bool? isVisible,
  }) {
    return AppMenuModel(
      appMenuId: appMenuId ?? this.appMenuId,
      parentId: parentId ?? this.parentId,
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      deleted: this.deleted,
      children: children ?? this.children,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

// Helper to build tree from flat list
List<AppMenuModel> buildMenuTree(List<AppMenuModel> flatList) {
  // Sort by sortOrder first
  flatList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  final Map<int, AppMenuModel> map = {};
  for (var item in flatList) {
    map[item.appMenuId] = item.copyWith(
      children: [],
    ); // Initialize empty children
  }

  final List<AppMenuModel> roots = [];

  for (var item in flatList) {
    if (item.parentId == 0) {
      roots.add(map[item.appMenuId]!);
    } else {
      if (map.containsKey(item.parentId)) {
        map[item.parentId]!.children.add(map[item.appMenuId]!);
      } else {
        // Fallback if parent not found, treat as root or ignore?
        // Treating as root for safety to avoid data loss
        roots.add(map[item.appMenuId]!);
      }
    }
  }
  return roots;
}
