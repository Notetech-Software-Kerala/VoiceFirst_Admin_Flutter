import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:voice_first_admin/features/profile/presentation/pages/profile_page.dart';
import 'package:voice_first_admin/features/roles/presentation/pages/roles_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardPage(),
          RolesPage(),
          Center(child: Text("Users Page Placeholder")),
          ProfilePage(),
        ],
      ),
      extendBody: true,
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
            label: "Org Setup",
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
