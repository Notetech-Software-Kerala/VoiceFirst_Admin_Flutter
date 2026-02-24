class PasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  const PasswordState({
    required this.isLoading,
    required this.errorMessage,
    required this.success,
  });

  factory PasswordState.initial() {
    return const PasswordState(
      isLoading: false,
      errorMessage: null,
      success: false,
    );
  }

  PasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return PasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? this.success,
    );
  }
}




