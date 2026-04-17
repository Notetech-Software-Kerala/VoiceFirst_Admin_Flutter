class DivisionTwoModel {
  final int id;
  final int divisionOneId;
  final String name;
  final bool status;

  DivisionTwoModel({
    required this.id,
    required this.divisionOneId,
    required this.name,
    required this.status,
  });

  factory DivisionTwoModel.fromJson(Map<String, dynamic> json) {
    return DivisionTwoModel(
      id: json['divTwoId'],
      divisionOneId: json['divOneId'],
      name: json['divTwoName'] ?? '',
      status: json['active'] ?? false,
    );
  }

  DivisionTwoModel copyWith({
    int? id,
    int? divisionOneId,
    String? name,
    bool? status,
  }) {
    return DivisionTwoModel(
      id: id ?? this.id,
      divisionOneId: divisionOneId ?? this.divisionOneId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}
