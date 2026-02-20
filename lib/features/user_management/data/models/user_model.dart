class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobileNo;
  final bool active;
  final DateTime? createdDate;
  final String? roleName; // Assuming API returns role name or ID
  final String? imageUrl; // Hypothetical, API might not return this directly

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.mobileNo,
    required this.active,
    this.createdDate,
    this.roleName,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['employeeId'] ?? json['id'] ?? 0, // Fallback
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobileNo'],
      active: json['active'] ?? true,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
      roleName: json['roleName'] ?? 'User', // Default
      imageUrl: json['imageUrl'], // If available
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
