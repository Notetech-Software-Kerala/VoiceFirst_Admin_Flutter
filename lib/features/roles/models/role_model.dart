class RoleModel {
  final String? id;
  final String name;
  final bool allLocationAccess;
  final bool allIssueAccess;
  final List<ProgramPermissionModel> permissions;
  final bool status;

  RoleModel({
    this.id,
    required this.name,
    this.allLocationAccess = false,
    this.allIssueAccess = false,
    required this.permissions,
    this.status = true,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['roleName'] ?? '',
      allLocationAccess: json['allLocationAccess'] ?? false,
      allIssueAccess: json['allIssuesAccess'] ?? false,
      status: json['status'] ?? true,
      permissions:
          (json['rolePrograms'] as List<dynamic>?)
              ?.map((e) => ProgramPermissionModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleName': name,
      'allLocationAccess': allLocationAccess,
      'allIssuesAccess': allIssueAccess,
      'status': status,
      'rolePrograms': permissions.map((e) => e.toJson()).toList(),
    };
  }

  RoleModel copyWith({
    String? id,
    String? name,
    bool? allLocationAccess,
    bool? allIssueAccess,
    List<ProgramPermissionModel>? permissions,
    bool? status,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      allLocationAccess: allLocationAccess ?? this.allLocationAccess,
      allIssueAccess: allIssueAccess ?? this.allIssueAccess,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
    );
  }
}

class ProgramModel {
  final String id;
  final String label;
  final bool create;
  final bool update;
  final bool view;
  final bool delete;
  final bool download;
  final bool email;

  ProgramModel({
    required this.id,
    required this.label,
    this.create = false,
    this.update = false,
    this.view = false,
    this.delete = false,
    this.download = false,
    this.email = false,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] ?? '',
      label: json['name'] ?? '', // Assuming 'name' or 'label' from API
      create: json['create'] ?? false,
      update: json['update'] ?? false,
      view: json['view'] ?? false,
      delete: json['delete'] ?? false,
      download: json['download'] ?? false,
      email: json['email'] ?? false,
    );
  }
}

class ProgramPermissionModel {
  final String? id;
  final String programId;
  final String? label; // For UI display purposes
  bool create;
  bool update;
  bool view;
  bool delete;
  bool download;
  bool email;

  // Capabilities (UI helper - not part of data persistence usually, but helpful)
  final bool canCreate;
  final bool canUpdate;
  final bool canView;
  final bool canDelete;
  final bool canDownload;
  final bool canEmail;

  ProgramPermissionModel({
    this.id,
    required this.programId,
    this.label,
    this.create = false,
    this.update = false,
    this.view = false,
    this.delete = false,
    this.download = false,
    this.email = false,
    this.canCreate = true,
    this.canUpdate = true,
    this.canView = true,
    this.canDelete = true,
    this.canDownload = true,
    this.canEmail = true,
  });

  factory ProgramPermissionModel.fromJson(Map<String, dynamic> json) {
    return ProgramPermissionModel(
      id: json['id'],
      programId: json['programId'] ?? '',
      create: json['create'] ?? false,
      update: json['update'] ?? false,
      view: json['view'] ?? false,
      delete: json['delete'] ?? false,
      download: json['download'] ?? false,
      email: json['email'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'programId': programId,
      'create': create,
      'update': update,
      'view': view,
      'delete': delete,
      'download': download,
      'email': email,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
