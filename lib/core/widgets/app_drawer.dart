// import 'package:flutter/material.dart';

// class AppDrawer extends StatefulWidget {
//   const AppDrawer({super.key});

//   @override
//   State<AppDrawer> createState() => _AppDrawerState();
// }

// class _AppDrawerState extends State<AppDrawer> {
//   bool _isCountryManagementExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = const Color(0xFF0D7FF2);

//     return Drawer(
//       child: Column(
//         children: [
//           // Drawer Header
//           DrawerHeader(
//             decoration: BoxDecoration(color: primaryColor),
//             child: const Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.admin_panel_settings,
//                     size: 50,
//                     color: Color(0xFF0D7FF2),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   'VoiceFirst Admin',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Menu Items
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.dashboard,
//                   title: 'Dashboard',
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Navigate to dashboard
//                   },
//                 ),
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.business,
//                   title: 'Business Activity',
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Navigate to business activity
//                   },
//                 ),

//                 // Country Management with submenu
//                 ExpansionTile(
//                   leading: Icon(Icons.public, color: primaryColor),
//                   title: const Text(
//                     'Country Management',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   trailing: Icon(
//                     _isCountryManagementExpanded
//                         ? Icons.expand_less
//                         : Icons.expand_more,
//                     color: primaryColor,
//                   ),
//                   onExpansionChanged: (expanded) {
//                     setState(() {
//                       _isCountryManagementExpanded = expanded;
//                     });
//                   },
//                   children: [
//                     _buildSubMenuItem(
//                       context,
//                       icon: Icons.flag,
//                       title: 'Countries',
//                       onTap: () {
//                         Navigator.pop(context);
//                         // Navigate to countries
//                       },
//                     ),
//                     _buildSubMenuItem(
//                       context,
//                       icon: Icons.location_city,
//                       title: 'Division One',
//                       onTap: () {
//                         Navigator.pop(context);
//                         // Navigate to division one
//                       },
//                     ),
//                     _buildSubMenuItem(
//                       context,
//                       icon: Icons.map,
//                       title: 'Division Two',
//                       onTap: () {
//                         Navigator.pop(context);
//                         // Navigate to division two
//                       },
//                     ),
//                     _buildSubMenuItem(
//                       context,
//                       icon: Icons.place,
//                       title: 'Division Three',
//                       onTap: () {
//                         Navigator.pop(context);
//                         // Navigate to division three
//                       },
//                     ),
//                   ],
//                 ),

//                 _buildMenuItem(
//                   context,
//                   icon: Icons.settings_applications,
//                   title: 'Program Actions',
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Navigate to program actions
//                   },
//                 ),
//                 const Divider(),
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.settings,
//                   title: 'Settings',
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Navigate to settings
//                   },
//                 ),
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.help_outline,
//                   title: 'Help & Support',
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Navigate to help
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Logout Button
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text('Logout', style: TextStyle(color: Colors.red)),
//             onTap: () {
//               Navigator.pop(context);
//               _showLogoutDialog(context);
//             },
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuItem(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF0D7FF2)),
//       title: Text(title, style: const TextStyle(fontSize: 16)),
//       onTap: onTap,
//       hoverColor: const Color(0xFF0D7FF2).withOpacity(0.1),
//     );
//   }

//   Widget _buildSubMenuItem(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF0D7FF2), size: 20),
//       title: Text(title, style: const TextStyle(fontSize: 14)),
//       contentPadding: const EdgeInsets.only(left: 72, right: 16),
//       onTap: onTap,
//       hoverColor: const Color(0xFF0D7FF2).withOpacity(0.1),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         icon: const Icon(Icons.logout, color: Colors.red, size: 48),
//         title: const Text(
//           'Logout',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: const Text(
//           'Are you sure you want to logout?',
//           textAlign: TextAlign.center,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.pop(dialogContext);
//               // Perform logout action
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _orgExpanded = false;

  static const primaryColor = Color(0xFF0D7FF2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            _DrawerHeader(theme),

            // ===== MENU =====
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _sectionTitle("MAIN"),
                  _drawerItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    onTap: () => _navigate(context),
                  ),
                  _drawerItem(
                    icon: Icons.business,
                    title: "Business Activity",
                    onTap: () => _navigate(context),
                  ),

                  const SizedBox(height: 12),
                  _sectionTitle("ORGANIZATION"),

                  _expandableSection(
                    context,
                    theme,
                    title: "Location Management",
                    icon: Icons.public,
                    expanded: _orgExpanded,
                    onChanged: (v) => setState(() => _orgExpanded = v),
                    children: [
                      _subItem("Countries", Icons.flag),
                      _subItem("Division One", Icons.location_city),
                      _subItem("Division Two", Icons.map),
                      _subItem("Division Three", Icons.place),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _sectionTitle("SYSTEM"),

                  _drawerItem(
                    icon: Icons.admin_panel_settings,
                    title: "Roles & Permissions",
                    onTap: () => _navigate(context),
                  ),
                  _drawerItem(
                    icon: Icons.settings_applications,
                    title: "Program Actions",
                    onTap: () => _navigate(context),
                  ),

                  const Divider(height: 32),

                  _drawerItem(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () => _navigate(context),
                  ),
                  _drawerItem(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    onTap: () => _navigate(context),
                  ),
                ],
              ),
            ),

            // ===== LOGOUT =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showLogoutDialog(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _DrawerHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              size: 30,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "VoiceFirst Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "System Administrator",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: primaryColor),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expandableSection(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required IconData icon,
    required bool expanded,
    required ValueChanged<bool> onChanged,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        expanded ? Icons.expand_less : Icons.expand_more,
        color: primaryColor,
      ),
      onExpansionChanged: onChanged,
      children: children,
    );
  }

  Widget _subItem(String title, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.fromLTRB(56, 10, 16, 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: primaryColor),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ACTIONS =================

  void _navigate(BuildContext context) {
    Navigator.pop(context);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
