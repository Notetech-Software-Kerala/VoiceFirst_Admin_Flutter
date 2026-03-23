class ActionLinkItem {
  final int actionLinkId;
  final String actionName;

  const ActionLinkItem({required this.actionLinkId, required this.actionName});

  factory ActionLinkItem.fromJson(Map<String, dynamic> json) {
    return ActionLinkItem(
      actionLinkId: json['actionLinkId'] as int,
      actionName: json['actionName'] as String? ?? '',
    );
  }
}

class ProgramActionLinkProgram {
  final int programId;
  final String programName;
  final List<ActionLinkItem> actions;

  const ProgramActionLinkProgram({
    required this.programId,
    required this.programName,
    required this.actions,
  });

  factory ProgramActionLinkProgram.fromJson(Map<String, dynamic> json) {
    final list = (json['action'] as List<dynamic>? ?? <dynamic>[]);
    return ProgramActionLinkProgram(
      programId: json['programId'] as int,
      programName: json['programName'] as String? ?? '',
      actions: list
          .map((e) => ActionLinkItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
