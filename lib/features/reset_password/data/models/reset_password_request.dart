// class ResetPasswordRequest {
//   final String email;
//   final String otp;
//   final String newPassword;

//   const ResetPasswordRequest({
//     required this.email,
//     required this.otp,
//     required this.newPassword,
//   });

//   Map<String, dynamic> toJson() {
//     return {'email': email, 'otp': otp, 'newPassword': newPassword};
//   }
// }


class ResetPasswordRequest {
  final String newPassword;
  final String passwordResetGrant;

  const ResetPasswordRequest({
    required this.newPassword,
    required this.passwordResetGrant,
  });

  Map<String, dynamic> toJson() {
    return {
      "newPassword": newPassword,
      "passwordResetGrant": passwordResetGrant,
    };
  }
}