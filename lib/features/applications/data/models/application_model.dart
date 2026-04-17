class ApplicationModel {
  final int platformId;
  final String platformName;

  const ApplicationModel({
    required this.platformId,
    required this.platformName,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      platformId: json['platformId'] as int,
      platformName: json['platformName'] as String,
    );
  }
}
