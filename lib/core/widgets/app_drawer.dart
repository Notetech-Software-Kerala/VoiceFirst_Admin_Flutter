import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const SidebarWidget({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final textColor = theme.textTheme.bodyMedium?.color;
    final subTextColor = theme.iconTheme.color;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(color: primary.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- User Profile Header ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primary.withValues(alpha: 0.1), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                // Glowing Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "JD",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      // Online Status Dot
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "John Doe",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "SUPER ADMIN",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Scrollable Menu Content ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Search Mockup
                Container(
                  margin: const EdgeInsets.only(bottom: 16, top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20, color: subTextColor),
                      const SizedBox(width: 8),
                      Text(
                        "Quick access...",
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Dashboard
                _SidebarItem(
                  title: "Dashboard",
                  icon: Icons.dashboard,
                  isSelected: currentIndex == 0,
                  onTap: () => onNavigate(0),
                ),

                // Organization Accordion
                _SidebarAccordion(
                  title: "Organization",
                  icon: Icons.corporate_fare,
                  // We simulate expanding selection if children are selected
                  isExpanded: currentIndex == 1,
                  children: [
                    _SidebarSubItem(
                      title: "Org Setup",
                      subtitle: "Manage Permissions & Roles",
                      icon: Icons.admin_panel_settings,
                      isSelected: currentIndex == 1,
                      onTap: () => onNavigate(1),
                    ),
                    _SidebarSubItem(
                      title: "Post Office",
                      subtitle: "Setup Locations",
                      icon: Icons.local_post_office,
                      isSelected: currentIndex == 4,
                      onTap: () => onNavigate(4),
                    ),
                    _SidebarSubItem(
                      title: "Branches",
                      subtitle: "Manage global locations",
                      icon: Icons.account_tree,
                    ),
                    _SidebarSubItem(
                      title: "Business Activity",
                      subtitle: "Manage Business Activity",
                      icon: Icons.business_center_outlined,
                      isSelected: currentIndex == 5,
                      onTap: () => onNavigate(5),
                    ),
                    _SidebarSubItem(
                      title: "Manage Country",
                      subtitle: "Manage Country",
                      icon: Icons.business_center_outlined,
                      isSelected: currentIndex == 6,
                      onTap: () => onNavigate(6),
                    ),

                    _SidebarSubItem(
                      title: "Program Action",
                      icon: Icons.playlist_play,
                      isSelected: currentIndex == 7,
                      onTap: () => onNavigate(7),
                      subtitle: 'Manage Program Action',
                    ),
                    _SidebarSubItem(
                      title: "Program Management",
                      icon: Icons.settings_applications,
                      isSelected: currentIndex == 8,
                      onTap: () => onNavigate(8),
                      subtitle: 'Manage Programs',
                    ),
                    _SidebarSubItem(
                      title: "Plan Management",
                      icon: Icons.settings_applications,
                      isSelected: currentIndex == 9,
                      onTap: () => onNavigate(9),
                      subtitle: 'Manage Plans',
                    ),
                    _SidebarSubItem(
                      title: "Place Management",
                      subtitle: "Manage Places",
                      icon: Icons.settings_applications,
                      isSelected: currentIndex == 10,
                      onTap: () => onNavigate(10),
                    ),
                    _SidebarSubItem(
                      title: "Menu Config",
                      subtitle: "Configure User App Menu",
                      icon: Icons.menu_open,
                      isSelected: currentIndex == 10,
                      onTap: () => onNavigate(10),
                    ),
                     _SidebarSubItem(
                      title: "Place Management",
                      subtitle: "Manage Places",
                      icon: Icons.settings_applications,
                      isSelected: currentIndex == 11,
                      onTap: () => onNavigate(11),
                    ),
                  ],
                ),

                // System Accordion
                _SidebarAccordion(
                  title: "System",
                  icon: Icons.settings_input_component,
                  children: [
                    _SidebarSubItem(
                      title: "Users",
                      subtitle: "User management",
                      icon: Icons.group,
                      isSelected: currentIndex == 2,
                      onTap: () => onNavigate(2),
                    ),
                    _SidebarSubItem(
                      title: "Master Data",
                      subtitle: "Core system records",
                      icon: Icons.dataset,
                    ),
                    _SidebarSubItem(
                      title: "Menu Config",
                      subtitle: "Configure User App Menu",
                      icon: Icons.menu_open,
                      isSelected: currentIndex == 10,
                      onTap: () => onNavigate(10),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    "COMMUNICATION",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: subTextColor,
                    ),
                  ),
                ),

                _SidebarItem(title: "Voice Logs", icon: Icons.graphic_eq),
                _SidebarItem(
                  title: "Team Chats",
                  icon: Icons.chat_bubble_outline,
                  trailing: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "4",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Super Admin Tool Card
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "SUPER ADMIN TOOL",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Icon(Icons.bolt, size: 16, color: primary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Active Company:",
                        style: TextStyle(fontSize: 11, color: subTextColor),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Global Logistics Inc.",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const Icon(Icons.swap_horiz, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // --- Footer ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
              color: theme.cardColor.withValues(
                alpha: 0.8,
              ), // mimic blur slightly
            ),
            child: Column(
              children: [
                _SidebarItem(
                  title: "Settings",
                  icon: Icons.settings,
                  isCompact: true,
                  isSelected: currentIndex == 3,
                  onTap: () => onNavigate(3),
                ),
                _SidebarItem(
                  title: "Logout",
                  icon: Icons.logout,
                  color: Colors.red[400],
                  isCompact: true,
                ),

                const SizedBox(height: 20),

                // Branding
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "VOICEFIRST v2.4",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                    letterSpacing: 1.0,
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

// -----------------------------------------------------------------------------
// Helper Widgets
// -----------------------------------------------------------------------------

class _SidebarAccordion extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isExpanded;

  const _SidebarAccordion({
    required this.title,
    required this.icon,
    required this.children,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      // Remove default borders from ExpansionTile
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: theme.primaryColor, size: 22),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 12), // Indent children
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        children: children
            .map(
              (child) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.iconTheme.color!.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(left: 8),
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SidebarSubItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const _SidebarSubItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subColor = theme.iconTheme.color;
    final primary = theme.primaryColor;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Icon(icon, size: 18, color: isSelected ? primary : subColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? primary : null,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 10, color: subColor)),
      hoverColor: theme.dividerColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: primary.withValues(alpha: 0.05),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Color? color;
  final bool isCompact;
  final VoidCallback? onTap;
  final bool isSelected;

  const _SidebarItem({
    required this.title,
    required this.icon,
    this.trailing,
    this.color,
    this.isCompact = false,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    final itemColor =
        color ??
        (isSelected
            ? primary
            : (isCompact
                  ? theme.iconTheme.color
                  : theme.textTheme.bodyMedium?.color));
    final iconColor =
        color ??
        (isSelected
            ? primary
            : (isCompact ? theme.iconTheme.color : theme.primaryColor));

    return ListTile(
      dense: isCompact,
      visualDensity: isCompact ? VisualDensity.compact : VisualDensity.standard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, color: iconColor, size: isCompact ? 20 : 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected
              ? FontWeight.bold
              : (isCompact ? FontWeight.normal : FontWeight.w500),
          color: itemColor,
        ),
      ),
      trailing: trailing,
      hoverColor: theme.dividerColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: primary.withValues(alpha: 0.05),
    );
  }
}
