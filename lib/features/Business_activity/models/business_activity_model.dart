import 'package:voice_first_admin/features/Business_activity/models/activity_custom_field.dart';

class BusinessActivity {
  final int activityId;
  final String activityName;
  final List<ActivityCustomField>? activityCustomFields;
  final bool active;
  final bool isDeleted;

  final String createdUser;
  final DateTime createdDate;

  final String? modifiedUser;
  final DateTime? modifiedDate;

  final String? deletedUser;
  final DateTime? deletedDate;

  BusinessActivity({
    required this.activityId,
    required this.activityName,
    this.activityCustomFields,
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
      activityId: json['activityId'] as int,
      activityName: json['activityName'] as String,
      activityCustomFields: json['activityCustomFields'] != null
    ? (json['activityCustomFields'] as List)
        .map((e) => ActivityCustomField.fromJson(e))
        .toList()
    : null,
      active: json['active'] as bool,
      isDeleted: json['deleted'],
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
    int? activityId,
    String? activityName,
    bool? active,
    bool? isDeleted,
    String? createdUser,
    DateTime? createdDate,
    String? modifiedUser,
    DateTime? modifiedDate,
    String? deletedUser,
    DateTime? deletedDate,
    bool clearDeletedMeta = false,
  }) {
    return BusinessActivity(
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      active: active ?? this.active,
      isDeleted: isDeleted ?? this.isDeleted,
      createdUser: createdUser ?? this.createdUser,
      createdDate: createdDate ?? this.createdDate,
      modifiedUser: modifiedUser ?? this.modifiedUser,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      deletedUser: clearDeletedMeta ? null : deletedUser ?? this.deletedUser,
      deletedDate: clearDeletedMeta ? null : deletedDate ?? this.deletedDate,
    );
  }
}

