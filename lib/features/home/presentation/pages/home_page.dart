import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/business_activity/presentation/pages/view_business_activity.dart';
import 'package:voice_first_admin/features/country_management/country/presentation/pages/view_country.dart';
import 'package:voice_first_admin/features/Place_management/presentation/pages/view_place.dart';
import 'package:voice_first_admin/features/Plan_management/presentation/pages/view_plan.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/pages/view_program_action.dart';
import 'package:voice_first_admin/features/Program_management/presentation/pages/view_programs.dart';
import 'package:voice_first_admin/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/pages/view_issue_character_type.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/pages/view_issue_media_format.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/pages/view_issue_media_type.dart';
import 'package:voice_first_admin/features/issue_status/presentation/pages/view_issue_status.dart';
import 'package:voice_first_admin/features/issue_type/presentation/pages/view_issue_type.dart';
import 'package:voice_first_admin/features/profile/presentation/pages/profile_page.dart';
import 'package:voice_first_admin/features/roles/presentation/pages/roles_page.dart';
import 'package:voice_first_admin/features/post_office/presentation/pages/post_office_list_page.dart';
import '../../../../core/widgets/app_drawer.dart';
import 'package:voice_first_admin/features/menu_configuration/presentation/pages/menu_management_screen.dart';
import 'package:voice_first_admin/features/user_management/presentation/pages/user_list_screen.dart';
import 'package:voice_first_admin/features/custom_field/presentation/pages/view_custom_fields_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Responsive Layout Check
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final pages = [
      DashboardPage(),
      RolesPage(),
      UserListScreen(),
      ProfilePage(),
      PostOfficeListScreen(),
      ViewBusinessActivityPage(),
      CountryView(),
      ProgramActionView(),
      ProgramManagementView(),
      ViewPlanPage(),
      MenuManagementScreen(),
      ViewPlacePage(),
      ViewIssueCharacterTypePage(),
      ViewIssueMediaFormatPage(),
      ViewIssueMediaTypePage(),
      ViewIssueStatusPage(),
      ViewIssueTypePage(),
      ViewCustomFieldsPage(), // 17
    ];

    final content = pages[_selectedIndex];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SidebarWidget(
              currentIndex: _selectedIndex,
              onNavigate: (i) => setState(() => _selectedIndex = i),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    // Mobile/Tablet Layout
    return Scaffold(
      drawer: Drawer(
        width: 280,
        backgroundColor: Theme.of(context).cardColor,
        child: SidebarWidget(
          currentIndex: _selectedIndex,
          onNavigate: (i) => setState(() {
            _selectedIndex = i;
            Navigator.pop(context); // Close drawer
          }),
        ),
      ),
      body: content,
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            index: 0,
            isSelected: currentIndex == 0,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.domain,
            label: "Roles",
            index: 1,
            isSelected: currentIndex == 1,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.group,
            label: "Users",
            index: 2,
            isSelected: currentIndex == 2,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.settings,
            label: "Settings",
            index: 3,
            isSelected: currentIndex == 3,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF0D7FF2) : Colors.grey;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
