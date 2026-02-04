class RoleModel {
  final int? roleId; // API uses integer roleId
  final String roleName;
  final bool isMandatory;
  final String? rolePurpose;
  final int? platformId;
  final bool active;
  final bool deleted;
  final DateTime? createdDate;
  final String? createdUser;
  final DateTime? modifiedDate;
  final String? modifiedUser;
  final List<ProgramPermissionModel> permissions;

  // UI Helpers (Legacy compatibility if needed, or mapped)
  String get id => roleId?.toString() ?? '';
  String get name => roleName;
  bool get status => active;

  RoleModel({
    this.roleId,
    required this.roleName,
    this.isMandatory = false,
    this.rolePurpose,
    this.platformId,
    this.active = true,
    this.deleted = false,
    this.createdDate,
    this.createdUser,
    this.modifiedDate,
    this.modifiedUser,
    this.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleId: json['roleId'],
      roleName: json['roleName'] ?? '',
      isMandatory: json['isMandatory'] ?? false,
      rolePurpose: json['rolePurpose'],
      platformId: json['platformId'],
      active: json['active'] ?? true,
      deleted: json['deleted'] ?? false,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
      createdUser: json['createdUser'],
      modifiedDate: json['modifiedDate'] != null
          ? DateTime.tryParse(json['modifiedDate'])
          : null,
      modifiedUser: json['modifiedUser'],
      permissions:
          (json['rolePrograms'] as List<dynamic>?)
              ?.map((e) => ProgramPermissionModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (roleId != null) 'roleId': roleId,
      'roleName': roleName,
      'isMandatory': isMandatory,
      'rolePurpose': rolePurpose,
      'platformId': platformId ?? 1,
      'active': active,
      'deleted': deleted,
      'rolePrograms': permissions.map((e) => e.toJson()).toList(),
    };
  }

  RoleModel copyWith({
    int? roleId,
    String? roleName,
    bool? isMandatory,
    String? rolePurpose,
    int? platformId,
    bool? active,
    bool? deleted,
    List<ProgramPermissionModel>? permissions,
  }) {
    return RoleModel(
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      isMandatory: isMandatory ?? this.isMandatory,
      rolePurpose: rolePurpose ?? this.rolePurpose,
      platformId: platformId ?? this.platformId,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      permissions: permissions ?? this.permissions,
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
