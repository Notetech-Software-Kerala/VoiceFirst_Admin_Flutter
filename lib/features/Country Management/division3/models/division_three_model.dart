class DivisionThreeModel {
  final String id;
  final String divisionTwoId;
  final String name;
  final bool status;

  DivisionThreeModel({
    required this.id,
    required this.divisionTwoId,
    required this.name,
    required this.status,
  });

  factory DivisionThreeModel.fromJson(Map<String, dynamic> json) {
    return DivisionThreeModel(
      id: json['divThreeId'].toString(),
      divisionTwoId: json['divTwoId'].toString(),
      name: json['divThreeName'] ?? '',
      status: json['active'] ?? false,
    );
  }
}
