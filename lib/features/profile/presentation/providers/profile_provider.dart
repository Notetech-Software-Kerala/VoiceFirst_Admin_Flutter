import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/profile/data/models/update_profile_request.dart';
import 'package:voice_first_admin/features/profile/data/repositories/profile_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class ProfileState {
  final bool pushNotifications;
  final bool emailAlerts;

  // From JWT (available immediately after login)
  final String userName;
  final String userRole;
  final String userId;
  final String profileImageUrl;

  // From /users/me API (loaded after login)
  final String email;
  final String gender;
  final String mobileNo;
  final String birthYear;
  final String dialCode;
  final String phoneNumber;

  // Loading / error state for the API fetch
  final bool isLoading;
  final String? error;

  ProfileState({
    this.pushNotifications = false,
    this.emailAlerts = true,
    this.userName = '',
    this.userRole = '',
    this.userId = '',
    this.profileImageUrl =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
    this.email = '',
    this.gender = '',
    this.mobileNo = '',
    this.birthYear = '',
    this.dialCode = '',
    this.phoneNumber = '',
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    bool? pushNotifications,
    bool? emailAlerts,
    String? userName,
    String? userRole,
    String? userId,
    String? profileImageUrl,
    String? email,
    String? gender,
    String? mobileNo,
    String? birthYear,
    String? dialCode,
    String? phoneNumber,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userId: userId ?? this.userId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      mobileNo: mobileNo ?? this.mobileNo,
      birthYear: birthYear ?? this.birthYear,
      dialCode: dialCode ?? this.dialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => ProfileState();

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  // Called by AuthNotifier right after login / startup token check
  void setUserFromToken(Map<String, dynamic> jwtPayload) {
    final firstName =
        jwtPayload['FirstName'] ??
        jwtPayload['firstName'] ??
        jwtPayload['given_name'] ??
        '';
    final lastName =
        jwtPayload['LastName'] ??
        jwtPayload['lastName'] ??
        jwtPayload['family_name'] ??
        '';

    String name = '$firstName $lastName'.trim();
    if (name.isEmpty) {
      name =
          jwtPayload['name']?.toString() ??
          jwtPayload['email']?.toString() ??
          'Unknown User';
    }

    final role =
        jwtPayload['role'] ?? jwtPayload['roles']?.toString() ?? 'System User';

    final id =
        jwtPayload['uid'] ??
        jwtPayload['id'] ??
        jwtPayload['userId'] ??
        jwtPayload['sub'] ??
        '0000';

    state = state.copyWith(
      userName: name,
      userRole: role.toString(),
      userId: id.toString(),
    );

    // Immediately fetch full profile from API
    fetchProfile();
  }

  // Fetches full profile from GET /users/me
  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getMyProfile();
      state = state.copyWith(
        isLoading: false,
        userName: profile.fullName.isNotEmpty ? profile.fullName : state.userName,
        userRole: profile.primaryRole.isNotEmpty ? profile.primaryRole : state.userRole,
        email: profile.email,
        gender: _capitalize(profile.gender),
        mobileNo: profile.mobileNo,
        birthYear: profile.birthYear,
        dialCode: profile.dialCode,
        phoneNumber: profile.phoneNumber,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Saves profile updates to POST /users/me and re-fetches
  Future<bool> saveProfile(UpdateProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateProfile(request);
      await fetchProfile(); // refresh from server
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void togglePushNotifications() {
    state = state.copyWith(pushNotifications: !state.pushNotifications);
  }

  void toggleEmailAlerts() {
    state = state.copyWith(emailAlerts: !state.emailAlerts);
  }

  void updateProfile(String name, String role) {
    state = state.copyWith(userName: name, userRole: role);
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
