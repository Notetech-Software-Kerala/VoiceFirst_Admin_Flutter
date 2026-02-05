import 'program_management_model.dart';

class UpdateProgramRequest {
  final String? programName;
  final String? label;
  final String? route;
  final int? platformId;
  final int? companyId;
  final bool? active;

  final List<ProgramActionSummary> originalActions;
  final Set<int> selectedActionIds;

  UpdateProgramRequest({
    this.programName,
    this.label,
    this.route,
    this.platformId,
    this.companyId,
    this.active,
    required this.originalActions,
    required this.selectedActionIds,
  });

  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{};

    if (programName != null) body["programName"] = programName;
    if (label != null) body["label"] = label;
    if (route != null) body["route"] = route;
    if (platformId != null) body["platformId"] = platformId;
    if (companyId != null) body["companyId"] = companyId;
    if (active != null) body["active"] = active;

    final updateActions = <Map<String, dynamic>>[];
    final insertActions = <int>[];

    final originalIds = originalActions.map((a) => a.actionId).toSet();

    /// ✅ Detect status changes
    for (final action in originalActions) {
      final shouldBeActive = selectedActionIds.contains(action.actionId);

      if (action.active != shouldBeActive) {
        updateActions.add({
          "actionId": action.actionId,
          "active": shouldBeActive,
        });
      }
    }

    /// ✅ Brand new actions
    insertActions.addAll(selectedActionIds.difference(originalIds));

    if (updateActions.isNotEmpty) {
      body["updateActions"] = updateActions;
    }

    if (insertActions.isNotEmpty) {
      body["insertActions"] = insertActions;
    }

    return body;
  }
}
