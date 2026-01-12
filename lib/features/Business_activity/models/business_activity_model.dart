class BusinessActivity {
  final String id;
  final String activityName;
  final bool isForCompany;
  final bool isForBranch;
  final bool status;

  BusinessActivity({
    required this.id,
    required this.activityName,
    required this.isForCompany,
    required this.isForBranch,
    required this.status,
  });

  BusinessActivity copyWith({
    String? id,
    String? activityName,
    bool? isForCompany,
    bool? isForBranch,
    bool? status,
  }) {
    return BusinessActivity(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      isForCompany: isForCompany ?? this.isForCompany,
      isForBranch: isForBranch ?? this.isForBranch,
      status: status ?? this.status,
    );
  }
}
