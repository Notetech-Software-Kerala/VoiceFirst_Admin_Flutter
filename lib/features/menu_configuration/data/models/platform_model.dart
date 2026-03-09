class PlatformModel {
  final int platformId;
  final String platformName;

  PlatformModel({required this.platformId, required this.platformName});

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      platformId: json['platformId'] ?? 0,
      platformName: json['platformName'] ?? '',
    );
  }
}
