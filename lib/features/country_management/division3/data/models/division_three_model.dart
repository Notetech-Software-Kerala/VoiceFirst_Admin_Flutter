class DivisionThreeModel {
  final int id;
  final int divisionTwoId;
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
      id: json['divThreeId'],
      divisionTwoId: json['divTwoId'],
      name: json['divThreeName'] ?? '',
      status: json['active'] ?? false,
    );
  }
}
