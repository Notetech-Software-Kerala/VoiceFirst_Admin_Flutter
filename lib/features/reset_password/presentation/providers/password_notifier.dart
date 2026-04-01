import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/reset_password/data/models/change_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/forgot_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/reset_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/repositories/password_repository.dart';
import 'package:voice_first_admin/features/reset_password/presentation/providers/password_state.dart';

class PasswordNotifier extends Notifier<PasswordState> {
  late final PasswordRepository _service;

  @override
  PasswordState build() {
    _service = ref.read(passwordRepositoryProvider);
    return PasswordState.initial();
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null, success: false);
    try {
      await _service.forgotPassword(ForgotPasswordRequest(email: email));
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        success: false,
      );
    }
  }

  Future<void> resetPassword({
    required String grant,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, success: false);

    try {
      await _service.resetPassword(
        ResetPasswordRequest(
          newPassword: newPassword,
          passwordResetGrant: grant,
        ),
      );

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        success: false,
      );
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, success: false);
    try {
      await _service.changePassword(
        ChangePasswordRequest(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ),
      );
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        success: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(success: false);
  }
}
