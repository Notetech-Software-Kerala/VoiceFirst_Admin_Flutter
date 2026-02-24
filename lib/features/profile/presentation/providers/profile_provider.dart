import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

class ProfileState {
  final bool pushNotifications;
  final bool emailAlerts;
  final String userName;
  final String userRole;
  final String userId;
  final String profileImageUrl;

  ProfileState({
    required this.pushNotifications,
    required this.emailAlerts,
    required this.userName,
    required this.userRole,
    required this.userId,
    required this.profileImageUrl,
  });

  ProfileState copyWith({
    bool? pushNotifications,
    bool? emailAlerts,
    String? userName,
    String? userRole,
    String? userId,
    String? profileImageUrl,
  }) {
    return ProfileState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userId: userId ?? this.userId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

@Riverpod(keepAlive: true)
class Profile extends _$Profile {
  @override
  ProfileState build() {
    return ProfileState(
      pushNotifications: false,
      emailAlerts: true,
      userName: "Jane Doe",
      userRole: "Super Administrator",
      userId: "839201",
      profileImageUrl:
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
    );
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

  void setUserFromToken(Map<String, dynamic> jwtPayload) {
    // Determine the user's name (try specific fields from backend payload)
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

    String name = "$firstName $lastName".trim();

    if (name.isEmpty) {
      name =
          jwtPayload['name']?.toString() ??
          jwtPayload['email']?.toString() ??
          "Unknown User";
    }

    final role =
        jwtPayload['role'] ?? jwtPayload['roles']?.toString() ?? "System User";

    final id =
        jwtPayload['uid'] ??
        jwtPayload['id'] ??
        jwtPayload['userId'] ??
        jwtPayload['sub'] ??
        "0000";

    // Update the state
    state = state.copyWith(
      userName: name,
      userRole: role.toString(),
      userId: id.toString(),
      // Keep existing avatar or provide a default
    );
  }
}
