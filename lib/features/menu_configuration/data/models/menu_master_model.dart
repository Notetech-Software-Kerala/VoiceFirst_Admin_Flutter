class MenuMasterModel {
  final int menuId;
  final String menuName;
  final String icon;
  final String route;
  final String plateForm;
  final int plateFormId;
  final bool active;
  final bool deleted;
  final String? createdUser;
  final String? createdDate;
  final String? modifiedUser;
  final String? modifiedDate;
  final String? deletedUser;
  final String? deletedDate;
  final bool web;
  final bool app;

  MenuMasterModel({
    required this.menuId,
    required this.menuName,
    required this.icon,
    required this.route,
    required this.plateForm,
    required this.plateFormId,
    required this.active,
    required this.deleted,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
    required this.web,
    required this.app,
  });

  factory MenuMasterModel.fromJson(Map<String, dynamic> json) {
    return MenuMasterModel(
      menuId: json['menuId'] ?? 0,
      menuName: json['menuName'] ?? '',
      icon: json['icon'] ?? '',
      route: json['route'] ?? '',
      plateForm: json['plateForm'] ?? '',
      plateFormId: json['plateFormId'] ?? 0,
      active: json['active'] ?? false,
      deleted: json['deleted'] ?? false,
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      modifiedUser: json['modifiedUser'],
      modifiedDate: json['modifiedDate'],
      deletedUser: json['deletedUser'],
      deletedDate: json['deletedDate'],
      web: json['web'] ?? false,
      app: json['app'] ?? false,
    );
  }
}

class PaginatedMenuMasterResponse {
  final List<MenuMasterModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  PaginatedMenuMasterResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedMenuMasterResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final data = json['data'];
      var itemsJson = data['items'] as List<dynamic>? ?? [];
      List<MenuMasterModel> itemsList = itemsJson
          .map((itemJson) => MenuMasterModel.fromJson(itemJson))
          .toList();

      return PaginatedMenuMasterResponse(
        items: itemsList,
        totalCount: data['totalCount'] ?? 0,
        pageNumber: data['pageNumber'] ?? 1,
        pageSize: data['pageSize'] ?? 10,
        totalPages: data['totalPages'] ?? 1,
      );
    } else {
      // Fallback if structured differently
      return PaginatedMenuMasterResponse(
        items: [],
        totalCount: 0,
        pageNumber: 1,
        pageSize: 10,
        totalPages: 1,
      );
    }
  }
}
