class BusinessActivity {
  final String id;
  final String activityName;
  final bool status;

  BusinessActivity({
    required this.id,
    required this.activityName,
    required this.status,
  });

  BusinessActivity copyWith({String? id, String? activityName, bool? status}) {
    return BusinessActivity(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      status: status ?? this.status,
    );
  }
}
