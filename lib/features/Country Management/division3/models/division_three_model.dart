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
      id: json['id'],
      divisionTwoId: json['divisionTwoId'],
      name: json['name'] ?? json['divisionThree'], // Fallback for compatibility
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'divisionTwoId': divisionTwoId,
      'name': name,
      'status': status,
    };
  }

  DivisionThreeModel copyWith({
    String? id,
    String? divisionTwoId,
    String? name,
    bool? status,
  }) {
    return DivisionThreeModel(
      id: id ?? this.id,
      divisionTwoId: divisionTwoId ?? this.divisionTwoId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivisionThreeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
