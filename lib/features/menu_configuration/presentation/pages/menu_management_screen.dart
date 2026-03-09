import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/menu_configuration/presentation/pages/admin_menu_editor_screen.dart';
import 'package:voice_first_admin/features/menu_configuration/presentation/pages/add_menu_item_screen.dart';
import 'package:voice_first_admin/features/menu_configuration/presentation/pages/menu_details_screen.dart';
import 'package:voice_first_admin/features/menu_configuration/presentation/providers/menu_master_provider.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import '../../data/models/menu_master_model.dart';

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() =>
      _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with current filter state if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text =
          ref.read(menuMasterFilterProvider).searchText ?? '';
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(menuMasterFilterProvider.notifier).updateSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    final asyncMasterData = ref.watch(menuMasterProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // 1. Sticky AppBar
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Usually handled by drawer or pop, but just in case:
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          "Menu Management",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 8),
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
              24,
            ), // Bottom padding
            children: [
              // --- Search Bar ---
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? theme.cardColor : Colors.grey[100],
                  hintText: "Search menu items...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Action Buttons ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminMenuEditorScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text("Configure"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? theme.cardColor
                            : Colors.grey[200],
                        foregroundColor: isDark
                            ? Colors.white
                            : Colors.grey[900],
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddMenuItemScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add Menu"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primary.withValues(alpha: 0.4),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Async Data Render ---
              asyncMasterData.when(
                data: (data) {
                  final activeItems = data.items
                      .where((i) => i.active)
                      .toList();
                  final disabledItems = data.items
                      .where((i) => !i.active)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Active Menus Section ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "ACTIVE MENUS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${activeItems.length} items",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (activeItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "No active menus found.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...activeItems.map((item) => _MenuCard(item: item)),

                      const SizedBox(height: 24),

                      // --- Disabled Items Section ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "DISABLED ITEMS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${disabledItems.length} items",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (disabledItems.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.cardColor.withValues(alpha: 0.5)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                Icons.visibility_off_outlined,
                                size: 36,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "No hidden menu items",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Items you disable will appear here",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...disabledItems.map((item) => _MenuCard(item: item)),

                      const SizedBox(height: 16),

                      StandardPaginationControls(
                        currentPage: data.pageNumber,
                        totalPages: data.totalPages,
                        onPageChanged: (page) {
                          ref
                              .read(menuMasterFilterProvider.notifier)
                              .setPage(page);
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "Error loading menus: $error",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _MenuCard extends StatelessWidget {
  final MenuMasterModel item;

  const _MenuCard({required this.item});

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'settings':
        return Icons.settings;
      case 'users':
        return Icons.group;
      case 'user-plus':
        return Icons.person_add;
      case 'list':
        return Icons.list;
      case 'dashboard':
        return Icons.dashboard;
      case 'shield':
        return Icons.shield;
      case 'lock':
        return Icons.lock;
      case 'bar-chart':
        return Icons.bar_chart;
      case 'test':
        return Icons.bug_report;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuDetailsScreen(item: item)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getIconData(item.icon), color: primary),
            ),
            const SizedBox(width: 16),

            // Title & Route
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.route.isEmpty ? 'Folder' : item.route,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Badge & Chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.active
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.active ? "ACTIVE" : "DISABLED",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: item.active ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
