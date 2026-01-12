import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText = theme.colorScheme.onSurfaceVariant;

    // Watch the profile state
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // --- Custom Sticky Header ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const Text(
                  "Settings",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Done",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Scrollable Content ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Profile Section (Now using Riverpod state)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () => _showEditDialog(context, ref, profileState),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        profileState.profileImageUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.cardColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profileState.userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    profileState.userRole,
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "ID: ${profileState.userId}",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: theme.primaryColor,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // General Section
                  _buildSectionHeader("General", secondaryText),
                  _buildSectionContainer(
                    context,
                    children: [
                      _buildTile(
                        context,
                        icon: Icons.branding_watermark,
                        iconColor: theme.primaryColor,
                        title: "App Name",
                        trailing: _buildTrailingText(context, "Admin Console"),
                      ),
                      _buildTile(
                        context,
                        icon: Icons.language,
                        iconColor: Colors.orange,
                        title: "Language",
                        trailing: _buildTrailingText(context, "English (US)"),
                      ),
                      _buildTile(
                        context,
                        icon: Icons.schedule,
                        iconColor: Colors.purple,
                        title: "Time Zone",
                        trailing: _buildTrailingText(context, "UTC-5"),
                        isLast: true,
                      ),
                    ],
                  ),

                  // Notifications Section (Now using Riverpod methods)
                  _buildSectionHeader("Notifications", secondaryText),
                  _buildSectionContainer(
                    context,
                    children: [
                      _buildTile(
                        context,
                        icon: Icons.notifications,
                        iconColor: Colors.red,
                        title: "Push Notifications",
                        trailing: Switch.adaptive(
                          value: profileState.pushNotifications,
                          activeTrackColor: theme.primaryColor,
                          onChanged: (v) =>
                              profileNotifier.togglePushNotifications(),
                        ),
                      ),
                      _buildTile(
                        context,
                        icon: Icons.mail,
                        iconColor: Colors.blue,
                        title: "Email Alerts",
                        trailing: Switch.adaptive(
                          value: profileState.emailAlerts,
                          activeTrackColor: theme.primaryColor,
                          onChanged: (v) => profileNotifier.toggleEmailAlerts(),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  // Security Section
                  _buildSectionHeader("Security & Access", secondaryText),
                  _buildSectionContainer(
                    context,
                    children: [
                      _buildTile(
                        context,
                        icon: Icons.verified_user,
                        iconColor: Colors.green,
                        title: "Two-Factor Auth",
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Enabled",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: theme.iconTheme.color,
                            ),
                          ],
                        ),
                      ),
                      _buildTile(
                        context,
                        icon: Icons.manage_accounts,
                        iconColor: Colors.indigo,
                        title: "User Roles",
                        isLast: true,
                      ),
                    ],
                  ),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 32,
                    ),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Log Out",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          if (trailing != null)
            trailing
          else
            Icon(Icons.chevron_right, color: theme.iconTheme.color),
        ],
      ),
    );
  }

  Widget _buildTrailingText(BuildContext context, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ProfileState profile,
  ) {
    final nameController = TextEditingController(text: profile.userName);
    final roleController = TextEditingController(text: profile.userRole);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Enter your name",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: "Role",
                  hintText: "Enter your role",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(profileProvider.notifier)
                    .updateProfile(nameController.text, roleController.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
