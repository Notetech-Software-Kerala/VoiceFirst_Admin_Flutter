import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. MODEL ---
class MenuItemConfig {
  final String id;
  final String title;
  final String iconCode;
  final IconData? iconData; // Helper for local icons
  bool isVisible;
  List<MenuItemConfig> children;

  MenuItemConfig({
    required this.id,
    required this.title,
    this.iconCode = '',
    this.iconData,
    this.isVisible = true,
    this.children = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'iconCode': iconCode,
    'isVisible': isVisible,
    'children': children.map((e) => e.toJson()).toList(),
  };
}

class AdminMenuEditorScreen extends StatefulWidget {
  const AdminMenuEditorScreen({super.key});

  @override
  State<AdminMenuEditorScreen> createState() => _AdminMenuEditorScreenState();
}

class _AdminMenuEditorScreenState extends State<AdminMenuEditorScreen> {
  // --- 2. STATE ---
  // We keep a single list for simplicity of drag-and-drop hierarchy
  // but we can render them with section headers if needed.
  List<MenuItemConfig> _menuItems = [
    MenuItemConfig(
      id: '1',
      title: 'Dashboard',
      iconData: Icons.dashboard_outlined,
      children: [
        MenuItemConfig(
          id: '1-1',
          title: 'Analytics',
          iconData: Icons.trending_up,
        ),
        MenuItemConfig(
          id: '1-2',
          title: 'Overview',
          iconData: Icons.visibility,
        ),
      ],
    ),
    MenuItemConfig(
      id: '2',
      title: 'Users & Roles',
      iconData: Icons.group_outlined,
      children: [],
    ),
    MenuItemConfig(
      id: '3',
      title: 'System Security',
      iconData: Icons.verified_user_outlined,
    ),
    MenuItemConfig(
      id: '4',
      title: 'Master Data',
      iconData: Icons.storage,
      children: [
        MenuItemConfig(
          id: '4-1',
          title: 'Post Offices',
          iconData: Icons.local_post_office,
        ),
        MenuItemConfig(
          id: '4-2',
          title: 'Voice Templates',
          iconData: Icons.mic_none,
        ),
      ],
    ),
  ];

  bool _isSaving = false;

  // --- 3. LOGIC ---

  void _onReorderParent(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = _menuItems.removeAt(oldIndex);
      _menuItems.insert(newIndex, item);
    });
  }

  void _onReorderChild(int parentIndex, int oldIndex, int newIndex) {
    setState(() {
      var children = _menuItems[parentIndex].children;
      if (oldIndex < newIndex) newIndex -= 1;
      final item = children.removeAt(oldIndex);
      children.insert(newIndex, item);
    });
  }

  void _moveChild(MenuItemConfig item, String fromParentId, String toParentId) {
    if (fromParentId == toParentId) return;

    setState(() {
      final sourceParent = _menuItems.firstWhere((e) => e.id == fromParentId);
      sourceParent.children.removeWhere((child) => child.id == item.id);

      final destParent = _menuItems.firstWhere((e) => e.id == toParentId);
      destParent.children.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Moved '${item.title}' to '${_findTitle(toParentId)}'"),
      ),
    );
  }

  String _findTitle(String id) =>
      _menuItems.firstWhere((e) => e.id == id).title;

  Future<void> _saveMenuConfiguration() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    // print(jsonEncode(_menuItems.map((e) => e.toJson()).toList()));
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Menu order updated successfully!")),
      );
    }
  }

  // --- 4. BUILD ---

  @override
  Widget build(BuildContext context) {
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
                  child: _buildGlassPanel(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassPanel(BuildContext context) {
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
              _buildHeader(context),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.all(16),
                  onReorder: _onReorderParent,
                  proxyDecorator: (child, index, animation) =>
                      _proxyDecorator(child, index, animation, context),
                  children: [
                    for (int index = 0; index < _menuItems.length; index++)
                      _buildParentTile(index, _menuItems[index], context),
                  ],
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentTile(
    int index,
    MenuItemConfig item,
    BuildContext context,
  ) {
    return Container(
      key: ValueKey(item.id),
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
          leading: Icon(Icons.drag_indicator, color: Colors.grey[600]),
          // DRAG TARGET FOR CROSS-PARENT DROPPING
          title: DragTarget<_MenuMoveRequest>(
            onWillAccept: (data) =>
                data != null && data.fromParentId != item.id,
            onAccept: (data) =>
                _moveChild(data.item, data.fromParentId, item.id),
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
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isHovered
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
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
                      _onReorderChild(index, oldIndex, newIndex),
                  children: [
                    for (int i = 0; i < item.children.length; i++)
                      _buildChildTile(item.children[i], item.id, context),
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
    MenuItemConfig item,
    String parentId,
    BuildContext context,
  ) {
    return Container(
      key: ValueKey(item.id),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        // DRAGGABLE HANDLE
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
                  Text(item.title, style: const TextStyle(color: Colors.white)),
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
        title: Text(
          item.title,
          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
        ),
        trailing: Icon(Icons.drag_handle, size: 18, color: Colors.grey[700]),
      ),
    );
  }

  // --- HELPERS ---

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

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
                "Drag items to reorder",
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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
  final MenuItemConfig item;
  final String fromParentId;
  _MenuMoveRequest({required this.item, required this.fromParentId});
}
