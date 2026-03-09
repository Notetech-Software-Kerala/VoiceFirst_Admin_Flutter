import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import 'user_detail_screen.dart';
import 'edit_user_screen.dart';
import '../../../../core/widgets/standard_pagination_controls.dart';
import '../../../../core/widgets/standard_page_layout.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    // Pagination Info
    final totalPages = (userState.totalCount / userState.filter.limit).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    return StandardPageLayout(
      title: "User Management",
      onRefresh: () => userNotifier.fetchUsers(page: 1),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(130), // Search + Filters roughly
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                height: 48,
                child: TextField(
                  onChanged: (value) => userNotifier.setSearch(value),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        theme.cardColor, // Re-use standard search appearance
                    hintText: "Search by name or email...",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(Icons.search, color: theme.hintColor),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                ),
              ),
            ),
            // Filter Chips (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: "All",
                    isSelected: userState.filter.role == null,
                    onTap: () => userNotifier.setRoleFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: "Super Admin",
                    isSelected: userState.filter.role == "Super Admin",
                    onTap: () => userNotifier.setRoleFilter("Super Admin"),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: "Company Admin",
                    isSelected: userState.filter.role == "Company Admin",
                    onTap: () => userNotifier.setRoleFilter("Company Admin"),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: "Sales",
                    isSelected: userState.filter.role == "Sales",
                    onTap: () => userNotifier.setRoleFilter("Sales"),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: "Support",
                    isSelected: userState.filter.role == "Support",
                    onTap: () => userNotifier.setRoleFilter("Support"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "userFab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditUserScreen()),
          );
        },
        backgroundColor: theme.primaryColor,
        elevation: 4,
        child: const Icon(Icons.person_add, color: Colors.white, size: 30),
      ),
      slivers: [
        if (userState.isLoading && userState.users.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (userState.errorMessage != null)
          SliverFillRemaining(
            child: Center(child: Text("Error: ${userState.errorMessage}")),
          )
        else if (userState.users.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text("No users found.")),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final user = userState.users[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailScreen(user: user),
                      ),
                    );
                  },
                  child: _UserCard(
                    name: "${user.firstName} ${user.lastName}",
                    email: user.email,
                    role: user.roleName ?? "User",
                    status: user.active ? "Active" : "Suspended",
                    joinText: user.createdDate != null
                        ? "Joined ${user.createdDate.toString().split(' ')[0]}" // Simple formatting
                        : "Unknown date",
                    imageUrl:
                        user.imageUrl ??
                        "https://i.pravatar.cc/150?u=${user.id}", // Fallback
                    statusColor: user.active ? Colors.green : Colors.grey,
                    roleColor: Colors.blue, // Simplify for now
                    isDimmed: !user.active,
                  ),
                );
              }, childCount: userState.users.length),
            ),
          ),
      ],
      bottomNavigationBar: StandardPaginationControls(
        currentPage: userState.filter.pageNumber,
        totalPages: safeTotalPages,
        onPageChanged: (newPage) {
          if (!userState.isLoading) {
            userNotifier.setPage(newPage);
          }
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : (isDark ? primary.withValues(alpha: 0.1) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? primary.withValues(alpha: 0.8) : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String status;
  final String joinText;
  final String imageUrl;
  final Color statusColor;
  final Color roleColor;
  final bool isDimmed;

  const _UserCard({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinText,
    required this.imageUrl,
    required this.statusColor,
    required this.roleColor,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using Opacity widget here for the whole card dimming effect
    return Opacity(
      opacity: isDimmed ? 0.75 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Avatar + Name + Menu
            Row(
              children: [
                // Avatar with Status Dot
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: theme.cardColor, width: 2),
                      ),
                      child: isDimmed
                          ? Container(color: Colors.grey.withValues(alpha: 0.5))
                          : null, // Grayscale hack
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.cardColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                // Menu Icon
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                  color: theme.hintColor,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom Row: Badges + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _Badge(label: role, color: roleColor),
                    const SizedBox(width: 8),
                    _Badge(label: status, color: statusColor),
                  ],
                ),
                Text(
                  joinText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
