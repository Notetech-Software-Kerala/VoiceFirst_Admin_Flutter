class DivisionOneModel {
  final int id;
  final int countryId;
  final String name;
  final bool status;

  DivisionOneModel({
    required this.id,
    required this.countryId,
    required this.name,
    required this.status,
  });

  factory DivisionOneModel.fromJson(Map<String, dynamic> json) {
    return DivisionOneModel(
      id: json['divOneId'],
      countryId: json['countryId'],
      name: json['divOneName'] ?? '',
      status: json['active'] ?? false,
    );
  }

  DivisionOneModel copyWith({
    int? id,
    int? countryId,
    String? name,
    bool? status,
  }) {
    return DivisionOneModel(
      id: id ?? this.id,
      countryId: countryId ?? this.countryId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}
