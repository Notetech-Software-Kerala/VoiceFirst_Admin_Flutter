import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/app_menu_model.dart';
import '../providers/menu_provider.dart';

// --- 1. SCREEN ---

class AdminMenuEditorScreen extends ConsumerStatefulWidget {
  const AdminMenuEditorScreen({super.key});

  @override
  ConsumerState<AdminMenuEditorScreen> createState() =>
      _AdminMenuEditorScreenState();
}

class _AdminMenuEditorScreenState extends ConsumerState<AdminMenuEditorScreen> {
  bool _isSaving = false;

  void _onReorderParent(List<AppMenuModel> items, int oldIndex, int newIndex) {
    // Optimistic UI update logic handled in provider or local state
    // For simplicity, calling provider method which updates state
    ref.read(menuProvider.notifier).reorderParent(oldIndex, newIndex);
  }

  void _onReorderChild(
    List<AppMenuModel> items,
    int parentIndex,
    int oldIndex,
    int newIndex,
  ) {
    ref
        .read(menuProvider.notifier)
        .reorderChild(parentIndex, oldIndex, newIndex);
  }

  void _moveChild(
    List<AppMenuModel> items,
    AppMenuModel item,
    int fromParentId,
    int toParentId,
  ) {
    if (fromParentId == toParentId) return;

    ref.read(menuProvider.notifier).moveChild(item, fromParentId, toParentId);

    // Find destination title for snackbar
    // Find destination title for snackbar
    String destTitle;
    if (toParentId == 0) {
      destTitle = "Top Level";
    } else {
      try {
        destTitle = items
            .firstWhere(
              (e) => e.appMenuId == toParentId,
              orElse: () => items.first,
            ) // Fallback to avoid crash if not found
            .menuName;
      } catch (e) {
        destTitle = "Unknown Folder";
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Moved '${item.menuName}' to '$destTitle'")),
    );
  }

  Future<void> _saveMenuConfiguration() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(menuProvider.notifier).saveChanges();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu order updated successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);

    // Define Colors from Design
    const primary = Color(0xFF135BEC);
    const bgDark = Color(0xFF101622);
    const surfaceColor = Color(0xFF1E2532);

    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        primaryColor: primary,
        cardColor: surfaceColor,
        iconTheme: const IconThemeData(color: Color(0xFF94A3B8)),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: const Color(0xFFE2E8F0), displayColor: Colors.white),
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: surfaceColor,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackgroundContext(),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: 340,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: _buildGlassPanel(context, menuState),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassPanel(
    BuildContext context,
    AsyncValue<List<AppMenuModel>> menuState,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101622).withOpacity(0.85),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(10, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pass items to header if available, else empty list
              _buildHeader(context, menuState.asData?.value ?? []),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: menuState.when(
                  data: (items) => ReorderableListView(
                    padding: const EdgeInsets.all(16),
                    onReorder: (oldIndex, newIndex) =>
                        _onReorderParent(items, oldIndex, newIndex),
                    proxyDecorator: (child, index, animation) =>
                        _proxyDecorator(child, index, animation, context),
                    children: [
                      for (int index = 0; index < items.length; index++)
                        _buildParentTile(index, items[index], items, context),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error: $err",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<AppMenuModel> items) {
    return DragTarget<_MenuMoveRequest>(
      onWillAccept: (data) {
        if (data == null) return false;
        // Accept as root only if it's not already root (parentId != 0)
        if (data.fromParentId == 0) return false;
        return true;
      },
      onAccept: (data) {
        _moveChild(
          items,
          data.item,
          data.fromParentId,
          0, // 0 = Root
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isHovered
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: isHovered
                ? const BorderRadius.vertical(top: Radius.circular(24))
                : null,
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Navigation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHovered
                        ? "Drop to make top-level"
                        : "Drag items to reorder",
                    style: TextStyle(
                      fontSize: 12,
                      color: isHovered
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400],
                      fontWeight: isHovered
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParentTile(
    int index,
    AppMenuModel item,
    List<AppMenuModel> allItems,
    BuildContext context,
  ) {
    return Container(
      key: ValueKey(item.appMenuId),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_indicator, color: Colors.grey[600]),
          ),
          title: DragTarget<_MenuMoveRequest>(
            onWillAccept: (data) {
              if (data == null) return false;
              // Prevent dropping on self
              if (data.item.appMenuId == item.appMenuId) return false;
              // Prevent dropping if target is the current parent (already there)
              if (data.fromParentId == item.appMenuId) return false;

              return true;
            },
            onAccept: (data) {
              // Validate: Cannot drop into a parent that has a route (is a page, not a folder)
              if (item.route.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Cannot add items to '${item.menuName}' because it has a route.",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              _moveChild(
                allItems,
                data.item,
                data.fromParentId,
                item.appMenuId,
              );
            },
            builder: (context, candidateData, rejectedData) {
              final isHovered = candidateData.isNotEmpty;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isHovered
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isHovered
                      ? Border.all(color: Theme.of(context).primaryColor)
                      : null,
                ),
                child: Row(
                  children: [
                    // Cross-Parent Move Handle
                    Draggable<_MenuMoveRequest>(
                      data: _MenuMoveRequest(
                        item: item,
                        fromParentId: 0,
                      ), // 0 = Root
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2532),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.drive_file_move,
                                color: Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.menuName,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Icon(
                          Icons.drive_file_move_outline,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      child: Tooltip(
                        message: "Drag to move to another folder",
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.drive_file_move_outline,
                            size: 20,
                            color: Colors.blue.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      _getIconData(item.icon),
                      size: 20,
                      color: isHovered
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.menuName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isHovered
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          children: [
            if (item.children.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF101622).withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) =>
                      _onReorderChild(allItems, index, oldIndex, newIndex),
                  children: [
                    for (int i = 0; i < item.children.length; i++)
                      _buildChildTile(
                        item.children[i],
                        item.appMenuId,
                        context,
                      ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Drop items here or add new",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildTile(
    AppMenuModel item,
    int parentId,
    BuildContext context,
  ) {
    return Container(
      key: ValueKey(item.appMenuId),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        leading: Draggable<_MenuMoveRequest>(
          data: _MenuMoveRequest(item: item, fromParentId: parentId),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2532),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.drive_file_move,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.menuName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Icon(
              Icons.drive_file_move_outline,
              size: 18,
              color: Colors.grey[600],
            ),
          ),
          child: Tooltip(
            message: "Drag to move folder",
            child: Icon(
              Icons.drive_file_move_outline,
              size: 18,
              color: Colors.grey[500],
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(_getIconData(item.icon), size: 16, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.menuName,
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.drag_handle, size: 18, color: Colors.grey[700]),
      ),
    );
  }

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
        return Icons.circle_outlined; // Default
    }
  }

  Widget _proxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
    BuildContext context,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.05, animValue)!;
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2532),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0x660F172A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _saveMenuConfiguration,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, size: 20),
            label: const Text("Save Layout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundContext() {
    return Container(
      color: const Color(0xFF101622),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DASHBOARD",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(backgroundColor: Colors.grey),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuMoveRequest {
  final AppMenuModel item;
  final int fromParentId;
  _MenuMoveRequest({required this.item, required this.fromParentId});
}
