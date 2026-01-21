class BusinessActivity {
  final int id;
  final String name;
  final bool active;
  final bool isDeleted;

  final String createdUser;
  final DateTime createdDate;

  final String? modifiedUser;
  final DateTime? modifiedDate;

  final String? deletedUser;
  final DateTime? deletedDate;

  BusinessActivity({
    required this.id,
    required this.name,
    required this.active,
    required this.isDeleted,
    required this.createdUser,
    required this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
  });

  factory BusinessActivity.fromJson(Map<String, dynamic> json) {
    return BusinessActivity(
      id: json['id'],
      name: json['name'],
      active: json['active'],
      isDeleted: json['delete'],
      createdUser: json['createdUser'],
      createdDate: DateTime.parse(json['createdDate']),
      // modifiedUser: json['modifiedUser'],
      modifiedUser: json['modifiedUser']?.toString().trim().isEmpty == true
          ? null
          : json['modifiedUser'],

      modifiedDate: json['modifiedDate'] != null
          ? DateTime.parse(json['modifiedDate'])
          : null,
      deletedUser: json['deletedUser']?.toString().trim().isEmpty == true
          ? null
          : json['deletedUser'],
      deletedDate: json['deletedDate'] != null
          ? DateTime.parse(json['deletedDate'])
          : null,
    );
  }

  BusinessActivity copyWith({
    int? id,
    String? name,
    bool? active,
    bool? isDeleted,
    String? createdUser,
    DateTime? createdDate,
    String? modifiedUser,
    DateTime? modifiedDate,
    String? deletedUser,
    DateTime? deletedDate,
  }) {
    return BusinessActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      isDeleted: isDeleted ?? this.isDeleted,
      createdUser: createdUser ?? this.createdUser,
      createdDate: createdDate ?? this.createdDate,
      modifiedUser: modifiedUser ?? this.modifiedUser,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      deletedUser: deletedUser ?? this.deletedUser,
      deletedDate: deletedDate ?? this.deletedDate,
    );
  }
}
