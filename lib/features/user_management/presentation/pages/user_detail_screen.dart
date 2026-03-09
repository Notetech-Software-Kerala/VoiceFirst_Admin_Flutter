import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/delete_bottom_sheet.dart';
import '../../../../core/widgets/recovery_bottom_sheet.dart';
import '../../data/models/user_model.dart';
import '../providers/user_provider.dart';
import 'edit_user_screen.dart';

class UserDetailScreen extends ConsumerWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final userNotifier = ref.read(userProvider.notifier);

    return Scaffold(
      // 1. Top Navigation Bar
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          "Employee Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),

      // 2. Main Scrollable Content
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              24,
              16,
              160,
            ), // Bottom padding for Action Bar
            children: [
              // --- Profile Header ---
              Column(
                children: [
                  // Avatar with Status Indicator
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primary, primary.withValues(alpha: 0.4)],
                          ),
                          border: Border.all(
                            color: isDark
                                ? theme.scaffoldBackgroundColor
                                : Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName.substring(0, 1).toUpperCase() +
                                    (user.lastName.isNotEmpty
                                        ? user.lastName
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : "")
                              : "U",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      // Status Dot
                      Container(
                        margin: const EdgeInsets.only(right: 8, bottom: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: user.active ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? theme.scaffoldBackgroundColor
                                : Colors.white,
                            width: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name and Tags
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Employee ID: ${user.id}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.active
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: user.active
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          user.active ? "ACTIVE" : "SUSPENDED",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: user.active ? Colors.green : Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- Personal Information Card ---
              _SectionTitle(title: "Personal Information", color: primary),
              _InfoCard(
                children: [
                  _InfoRow(
                    icon: Icons.mail_outline,
                    label: "Email Address",
                    value: user.email,
                    showBorder: true,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: "Role",
                    value: user.roleName ?? "N/A",
                    showBorder: true,
                  ),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: "Birth Year",
                    value: user.birthYear ?? "N/A",
                    showBorder: true,
                  ),
                  _InfoRow(
                    icon: Icons.event_outlined,
                    label: "Joined Date",
                    value:
                        user.createdDate?.toString().split(' ')[0] ?? "Unknown",
                    showBorder: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Contact Details Card ---
              _SectionTitle(title: "Contact Details", color: primary),
              _InfoCard(
                children: [
                  _InfoRow(
                    icon: Icons.call_outlined,
                    label: "Mobile Number",
                    value: user.mobileNo ?? "N/A",
                    showBorder: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // --- Placeholder for other fields not in model yet ---
              // _SectionTitle(title: "Audit Trail", color: primary),
              // _InfoCard(...)
            ],
          ),

          // 3. Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (user.deleted)
                      ElevatedButton.icon(
                        onPressed: () {
                          showRecoveryBottomSheet(
                            context: context,
                            itemName: "${user.firstName} ${user.lastName}",
                            title: "RECOVER USER?",
                            questionText:
                                "Are you sure you want to restore this user?",
                            onRecover: () async {
                              try {
                                await userNotifier.recoverUser(user.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "User recovered successfully",
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context); // Go back to list
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Failed to recover user: $e",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.restore_from_trash, size: 20),
                        label: const Text("Recover Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    else ...[
                      // Edit Profile Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditUserScreen(user: user),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: const Text("Edit Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: primary.withValues(alpha: 0.4),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Deactivate & Delete Row
                      Row(
                        children: [
                          // Deactivate Button (Placeholder)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Deactivate coming soon"),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.block, size: 20),
                              label: const Text("Deactivate"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.grey[200],
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.grey[900],
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delete Button
                          Container(
                            width: 56,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showDeleteBottomSheet(
                                  context: context,
                                  itemName:
                                      "${user.firstName} ${user.lastName}",
                                  title: "DELETE USER?",
                                  warningText:
                                      "Are you sure you want to remove this user?",
                                  subWarningText:
                                      "This action cannot be undone.",
                                  onDelete: () async {
                                    try {
                                      await userNotifier.deleteUser(user.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "User deleted successfully",
                                            ),
                                          ),
                                        );
                                        Navigator.pop(
                                          context,
                                        ); // Go back to list
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Failed to delete user: $e",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: color,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showBorder;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showBorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: theme.dividerColor))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
