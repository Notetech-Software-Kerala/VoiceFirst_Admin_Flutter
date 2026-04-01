class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String mobileNo;
  final String birthYear;
  final int dialCodeId;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.mobileNo,
    required this.birthYear,
    required this.dialCodeId,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'gender': gender,
        'mobileNo': mobileNo,
        'birthYear': birthYear,
        'dialCodeId': dialCodeId,
      };
}
