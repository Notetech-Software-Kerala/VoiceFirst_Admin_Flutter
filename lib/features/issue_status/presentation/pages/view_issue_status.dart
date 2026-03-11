import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_model.dart';
import 'package:voice_first_admin/features/issue_status/presentation/dialogs/add_issue_status_dialog.dart';
import 'package:voice_first_admin/features/issue_status/presentation/dialogs/edit_issue_status_dialog.dart';
import 'package:voice_first_admin/features/issue_status/presentation/pages/issue_status_detail_page.dart';
import 'package:voice_first_admin/features/issue_status/presentation/providers/issue_status_provider.dart';

// Cycling colors and icons for status cards
const _cardColors = <MaterialColor>[
  Colors.green,
  Colors.blue,
  Colors.amber,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.red,
  Colors.cyan,
];

const _cardIcons = <IconData>[
  Icons.check_circle_outline,
  Icons.radio_button_unchecked,
  Icons.pause_circle_outline,
  Icons.sync,
  Icons.flag_outlined,
  Icons.star_outline,
  Icons.help_outline,
  Icons.info_outline,
];

class ViewIssueStatusPage extends ConsumerStatefulWidget {
  const ViewIssueStatusPage({super.key});

  @override
  ConsumerState<ViewIssueStatusPage> createState() =>
      _ViewIssueStatusPageState();
}

class _ViewIssueStatusPageState extends ConsumerState<ViewIssueStatusPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueStatusProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _buildSubtitle(IssueStatusModel item) {
    final parts = <String>[];

    if (item.createdUser != null && item.createdDate != null) {
      parts.add(
        'Created by ${item.createdUser} on ${_formatDate(item.createdDate!)}',
      );
    } else if (item.createdUser != null) {
      parts.add('Created by ${item.createdUser}');
    } else if (item.createdDate != null) {
      parts.add('Created on ${_formatDate(item.createdDate!)}');
    }

    if (item.modifiedUser != null && item.modifiedDate != null) {
      parts.add(
        'Modified by ${item.modifiedUser} on ${_formatDate(item.modifiedDate!)}',
      );
    }

    return parts.join(', ');
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    final state = ref.watch(issueStatusProvider);
    final notifier = ref.read(issueStatusProvider.notifier);

    return Scaffold(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "VOICEFIRST",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: primary,
              ),
            ),
            const Text(
              "Issue Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => AddIssueStatusDialog.show(context, ref),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: RefreshIndicator(
            onRefresh: () async => notifier.loadAll(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // ── Search Bar ──────────────────────────────────────────
                TextField(
                  controller: _searchController,
                  onChanged: notifier.search,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? const Color(0x801E293B)
                        : Colors.grey[200],
                    hintText: "Search statuses...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

                // ── Header Row ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "SYSTEM MASTER DATA",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${state.totalCount} ${state.totalCount == 1 ? 'Status' : 'Statuses'}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Loading / Empty / List ──────────────────────────────
                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No issue statuses found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...state.filtered.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final color = _cardColors[index % _cardColors.length];
                    final icon = _cardIcons[index % _cardIcons.length];

                    return _StatusCard(
                      item: item,
                      color: color,
                      icon: icon,
                      subtitle: _buildSubtitle(item),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              IssueStatusDetailPage(id: item.issueStatusId),
                        ),
                      ),
                      onEdit: () =>
                          EditIssueStatusDialog.show(context, ref, item),
                      onDelete: () => showDeleteBottomSheet(
                        context: context,
                        itemName: item.issueStatus,
                        onDelete: () async {
                          final error = await notifier.delete(
                            item.issueStatusId,
                          );
                          if (context.mounted) {
                            CustomSnackbar.show(
                              context,
                              message:
                                  error ?? 'Issue status deleted successfully',
                              type: error != null
                                  ? SnackBarType.error
                                  : SnackBarType.success,
                            );
                          }
                        },
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // ── Add New Status Button ───────────────────────────────
                ElevatedButton.icon(
                  onPressed: () => AddIssueStatusDialog.show(context, ref),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text("Add New Status"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: primary.withValues(alpha: 0.3),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // ── Pagination ─────────────────────────────────────────
                if (state.totalPages > 1) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: state.currentPage > 1
                            ? () => notifier.goToPage(state.currentPage - 1)
                            : null,
                      ),
                      Text(
                        'Page ${state.currentPage} of ${state.totalPages}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: state.currentPage < state.totalPages
                            ? () => notifier.goToPage(state.currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final IssueStatusModel item;
  final MaterialColor color;
  final IconData icon;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StatusCard({
    required this.item,
    required this.color,
    required this.icon,
    required this.subtitle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDeleted = item.deleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // ── Colored Icon Box ──────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isDeleted ? Colors.grey : color[600]),
            ),
            const SizedBox(width: 16),

            // ── Text Content ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.issueStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDeleted ? Colors.grey : null,
                            decoration: isDeleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "ID: ${item.issueStatusId}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // ── Action Buttons ────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: isDeleted ? Colors.grey[300] : Colors.grey[400],
                  onPressed: isDeleted ? null : onEdit,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: isDeleted ? Colors.grey[300] : Colors.grey[400],
                  onPressed: isDeleted ? null : onDelete,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
