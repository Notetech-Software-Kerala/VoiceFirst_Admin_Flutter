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
