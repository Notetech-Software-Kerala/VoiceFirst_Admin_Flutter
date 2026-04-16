class CreateProgramRequest {
  final String programName;
  final String label;
  final String route;
  final int platformId;
  final int companyId;
  final List<int> actionIds;

  CreateProgramRequest({
    required this.programName,
    required this.label,
    required this.route,
    required this.platformId,
    required this.companyId,
    required this.actionIds,
  });

  Map<String, dynamic> toJson() {
    return {
      "programName": programName,
      "label": label,
      "route": route,
      "platformId": platformId,
      "companyId": companyId,
      "actionIds": actionIds,
    };
  }
}
