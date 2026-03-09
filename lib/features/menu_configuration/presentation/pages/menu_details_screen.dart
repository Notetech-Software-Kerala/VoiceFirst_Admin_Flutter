import 'package:flutter/material.dart';
import '../../data/models/menu_master_model.dart';
import 'package:intl/intl.dart';

class MenuDetailsScreen extends StatelessWidget {
  final MenuMasterModel item;

  const MenuDetailsScreen({super.key, required this.item});

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy, hh:mm a').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Preferring the app's existing primary color
    final primary = theme.primaryColor;

    return Scaffold(
      // 1. Sticky AppBar
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Menu Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
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
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              // --- Hero Info Section ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(
                      _getIconData(item.icon),
                      color: primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.menuName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (item.active ? Colors.green : Colors.red)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      (item.active ? Colors.green : Colors.red)
                                          .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                item.active ? "Active" : "Disabled",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: item.active
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "• Menu Status",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Action Quick Bar ---
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.edit,
                      label: "Edit",
                      textColor: Colors.white,
                      bgColor: primary,
                      borderColor: Colors.transparent,
                      shadowColor: primary.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: item.active
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      label: item.active ? "Suspend" : "Activate",
                      textColor: Colors.amber,
                      bgColor: Colors.amber.withValues(alpha: 0.1),
                      borderColor: Colors.amber.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.delete_outline,
                      label: "Delete",
                      textColor: Colors.red[400]!,
                      bgColor: Colors.red.withValues(alpha: 0.1),
                      borderColor: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Configuration Info ---
              _buildSectionTitle("Configuration"),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildConfigRow(
                      "Platform",
                      item.plateForm.isNotEmpty ? item.plateForm : 'N/A',
                      true,
                      theme,
                    ),
                    _buildConfigRow(
                      "Web Visibility",
                      item.web ? "Visible" : "Hidden",
                      true,
                      theme,
                    ),
                    _buildConfigRow(
                      "App Visibility",
                      item.app ? "Visible" : "Hidden",
                      true,
                      theme,
                    ),
                    _buildConfigRow(
                      "Route",
                      item.route.isNotEmpty ? item.route : "Folder",
                      false,
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Audit Trail ---
              _buildSectionTitle("Audit Trail"),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAuditItem(
                          "Created By",
                          item.createdUser ?? "System Admin",
                          CrossAxisAlignment.start,
                        ),
                        _buildAuditItem(
                          "Created Date",
                          _formatDate(item.createdDate),
                          CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: theme.dividerColor, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAuditItem(
                          "Modified By",
                          item.modifiedUser ?? "System Admin",
                          CrossAxisAlignment.start,
                        ),
                        _buildAuditItem(
                          "Modified Date",
                          _formatDate(item.modifiedDate),
                          CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Associated Programs ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Associated Programs", paddingBottom: 0),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add, size: 16, color: primary),
                    label: Text(
                      "Add New",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 36,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No programs associated with this menu yet.",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

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

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
    Color? shadowColor,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: shadowColor != null
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double paddingBottom = 12}) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: paddingBottom),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildConfigRow(
    String label,
    String value,
    bool showBorder,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: theme.dividerColor))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAuditItem(
    String label,
    String value,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
