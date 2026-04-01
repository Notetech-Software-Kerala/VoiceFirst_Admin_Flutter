import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_first_admin/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:voice_first_admin/features/reset_password/presentation/pages/change_password_page.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/presentation/pages/login_screen.dart';
import '../providers/profile_provider.dart';
import '../../../../core/providers/theme_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Sticky Header ─────────────────────────────────────────────────
          _ProfileHeader(),

          // ── Scrollable Body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero — glowing avatar + name + role badge
                  _HeroSection(profileState: profileState),
                  const SizedBox(height: 40),

                  // 2. Bento cards — stacked vertically so long text is always visible
                  if (profileState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        _BentoCard(
                          category: 'Personal',
                          icon: Icons.badge_outlined,
                          iconColor: colors.tertiary,
                          children: [
                            _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Gender',
                              value: profileState.gender.isNotEmpty
                                  ? profileState.gender
                                  : '—',
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Birth Year',
                              value: profileState.birthYear.isNotEmpty
                                  ? profileState.birthYear
                                  : '—',
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.tag,
                              label: 'User ID',
                              value: '#${profileState.userId}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _BentoCard(
                          category: 'Contact',
                          icon: Icons.contact_mail_outlined,
                          iconColor: colors.primary,
                          children: [
                            _InfoRow(
                              icon: Icons.alternate_email,
                              label: 'Email',
                              value: profileState.email.isNotEmpty
                                  ? profileState.email
                                  : '—',
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.call_outlined,
                              label: 'Phone',
                              value: profileState.phoneNumber.isNotEmpty
                                  ? profileState.phoneNumber
                                  : '—',
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.shield_outlined,
                              label: 'Role',
                              value: profileState.userRole.isNotEmpty
                                  ? profileState.userRole
                                  : '—',
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // 3. Preferences section
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 14),
                    child: Text(
                      'Preferences',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _PreferencesCard(
                    children: [
                      _SettingsTile(
                        icon: isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode_outlined,
                        iconColor: colors.primary,
                        title: 'Dark Mode',
                        subtitle: isDarkMode
                            ? 'Optimized for night environments'
                            : 'Light theme active',
                        trailing: _PillSwitch(
                          value: isDarkMode,
                          onChanged: (val) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setTheme(
                                  val ? ThemeMode.dark : ThemeMode.light,
                                );
                          },
                        ),
                        showDivider: true,
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_active_outlined,
                        iconColor: colors.onSurfaceVariant,
                        title: 'Push Notifications',
                        subtitle: profileState.pushNotifications
                            ? 'Enabled — stay updated with alerts'
                            : 'Disabled',
                        trailing: _PillSwitch(
                          value: profileState.pushNotifications,
                          onChanged: (_) =>
                              profileNotifier.togglePushNotifications(),
                        ),
                        showDivider: true,
                      ),
                      _SettingsTile(
                        icon: Icons.mail_outline,
                        iconColor: colors.onSurfaceVariant,
                        title: 'Email Alerts',
                        subtitle: profileState.emailAlerts
                            ? 'Enabled'
                            : 'Disabled',
                        trailing: _PillSwitch(
                          value: profileState.emailAlerts,
                          onChanged: (_) => profileNotifier.toggleEmailAlerts(),
                        ),
                        showDivider: true,
                      ),
                      _SettingsTile(
                        icon: Icons.language,
                        iconColor: colors.onSurfaceVariant,
                        title: 'Language',
                        subtitle: 'English (US)',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colors.onSurfaceVariant,
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 4. Security
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 14),
                    child: Text(
                      'Security',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _PreferencesCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        iconColor: colors.primary,
                        title: 'Change Password',
                        subtitle: 'Update your credentials',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colors.onSurfaceVariant,
                        ),
                        showDivider: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.verified_user_outlined,
                        iconColor: colors.onSurfaceVariant,
                        title: 'Two-Factor Auth',
                        subtitle: 'Enabled',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'On',
                              style: TextStyle(
                                color: Colors.greenAccent[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 5. Sign Out
                  InkWell(
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: colors.error),
                          const SizedBox(width: 10),
                          Text(
                            'Sign Out',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.error,
                            ),
                          ),
                        ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky Header
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Profile',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section — glowing avatar, name, verified role badge
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.profileState});
  final ProfileState profileState;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring
            Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primaryContainer],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Avatar
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(
                  color: colors.surfaceContainerHighest,
                  width: 4,
                ),
                image: DecorationImage(
                  image: NetworkImage(profileState.profileImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          profileState.userName,
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Verified role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: colors.primary, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'NOTETECH • ${profileState.userRole.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bento Card
// ─────────────────────────────────────────────────────────────────────────────
class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.children,
  });
  final String category;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Row inside bento card
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: colors.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preferences / Settings card container
// ─────────────────────────────────────────────────────────────────────────────
class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings tile
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.showDivider,
    this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Pill Switch
// ─────────────────────────────────────────────────────────────────────────────
class _PillSwitch extends StatelessWidget {
  const _PillSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 26,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: value
                ? colors.onPrimaryContainer
                : colors.onSurfaceVariant.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
