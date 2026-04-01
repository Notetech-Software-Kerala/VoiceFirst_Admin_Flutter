class UserProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String mobileNo;
  final String birthYear;
  final String dialCode;
  final List<String> roles;

  const UserProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.mobileNo,
    required this.birthYear,
    required this.dialCode,
    required this.roles,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get primaryRole => roles.isNotEmpty ? roles.first : 'User';
  String get phoneNumber => '$dialCode $mobileNo';

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final rolesList = (json['roles'] as List<dynamic>?)
            ?.map((r) => r.toString())
            .toList() ??
        [];

    return UserProfileModel(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      mobileNo: json['mobileNo'] as String? ?? '',
      birthYear: json['birthYear'] as String? ?? '',
      dialCode: json['dialCode'] as String? ?? '',
      roles: rolesList,
    );
  }
}
