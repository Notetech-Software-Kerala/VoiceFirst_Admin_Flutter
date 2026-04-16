
import 'package:voice_first_admin/features/business_activity_management/data/models/activity_custom_field.dart';

class UpdateActivityRequest {
  final String? activityName;
  final bool? active;
  final List<int>? addCustomFieldIds;
  final List<Map<String, dynamic>>? updateCustomField;

  const UpdateActivityRequest({
    this.activityName,
    this.active,
    this.addCustomFieldIds,
    this.updateCustomField,
  });

  /// Creates request by comparing old and new state
  factory UpdateActivityRequest.fromChanges({
    required String newName,
    required String oldName,
    required bool? newActive,
    required bool oldActive,
    required Set<int> newFieldIds,
    required List<ActivityCustomField> oldFields,
  }) {
    /// 1️⃣ Name change
    final nameChanged = newName != oldName;

    /// 2️⃣ Status change
    final activeChanged =
        newActive != null && newActive != oldActive;

    /// 3️⃣ Old IDs
    final oldIds = oldFields.map((e) => e.customFieldId).toSet();

    /// 4️⃣ New fields to add
    final addIds = newFieldIds.difference(oldIds).toList();

    /// 5️⃣ Fields whose active status changed
    final updates = <Map<String, dynamic>>[];

    for (final field in oldFields) {
      final shouldBeActive = newFieldIds.contains(field.customFieldId);

      if (shouldBeActive != field.active) {
        updates.add({
          "activityCustomFieldLinkId": field.activityCustomFieldLinkId,
          "active": shouldBeActive,
        });
      }
    }

    return UpdateActivityRequest(
      activityName: nameChanged ? newName : null,
      active: activeChanged ? newActive : null,
      addCustomFieldIds: addIds.isEmpty ? null : addIds,
      updateCustomField: updates.isEmpty ? null : updates,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (activityName != null) data['activityName'] = activityName;

    if (active != null) data['active'] = active;

    if (addCustomFieldIds != null && addCustomFieldIds!.isNotEmpty) {
      data['addCustomFieldIds'] = addCustomFieldIds;
    }

    if (updateCustomField != null && updateCustomField!.isNotEmpty) {
      data['updateCustomField'] = updateCustomField;
    }

    return data;
  }
}