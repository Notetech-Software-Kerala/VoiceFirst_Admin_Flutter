import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_model.dart';
import 'package:voice_first_admin/features/issue_type/presentation/dialogs/add_issue_type_dialog.dart';
import 'package:voice_first_admin/features/issue_type/presentation/dialogs/edit_issue_type_dialog.dart';
import 'package:voice_first_admin/features/issue_type/presentation/pages/issue_type_detail_page.dart';
import 'package:voice_first_admin/features/issue_type/presentation/providers/issue_type_provider.dart';

// Cycling colors and icons for type cards
const _cardColors = <MaterialColor>[
  Colors.blue,
  Colors.indigo,
  Colors.green,
  Colors.amber,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.red,
];

const _cardIcons = <IconData>[
  Icons.construction,
  Icons.account_balance_wallet,
  Icons.handshake,
  Icons.security,
  Icons.support_agent,
  Icons.bug_report_outlined,
  Icons.settings_suggest_outlined,
  Icons.report_problem_outlined,
];

class ViewIssueTypePage extends ConsumerStatefulWidget {
  const ViewIssueTypePage({super.key});

  @override
  ConsumerState<ViewIssueTypePage> createState() => _ViewIssueTypePageState();
}

class _ViewIssueTypePageState extends ConsumerState<ViewIssueTypePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueTypeProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    final state = ref.watch(issueTypeProvider);
    final notifier = ref.read(issueTypeProvider.notifier);

    return Builder(
      builder: (outerContext) => Scaffold(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(outerContext).openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VOICEFIRST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: primary,
              ),
            ),
            const Text(
              'Issue Types',
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
                onPressed: () => AddIssueTypeDialog.show(context, ref),
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
          constraints: const BoxConstraints(maxWidth: 1024),
          child: RefreshIndicator(
            onRefresh: () async => notifier.loadAll(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                // ── Search & Filter ──────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: notifier.search,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.cardColor,
                          hintText: 'Search issue types...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
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
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, size: 20),
                      label: const Text('Filters'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                        backgroundColor: theme.cardColor,
                        side: BorderSide(color: theme.dividerColor),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Stats Grid ───────────────────────────────────────────
                _StatsGrid(state: state),
                const SizedBox(height: 24),

                // ── Section Header ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACTIVE MASTER DATA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    if (!state.isLoading)
                      Text(
                        'Showing ${state.filtered.length} of ${state.totalCount} entries',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                        'No issue types found',
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

                    return _IssueTypeCard(
                      item: item,
                      color: color,
                      icon: icon,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              IssueTypeDetailPage(id: item.issueTypeId),
                        ),
                      ),
                      onEdit: () =>
                          EditIssueTypeDialog.show(context, ref, item),
                      onDelete: () => showDeleteBottomSheet(
                        context: context,
                        itemName: item.issueType,
                        onDelete: () async {
                          final error = await notifier.delete(item.issueTypeId);
                          if (context.mounted) {
                            CustomSnackbar.show(
                              context,
                              message:
                                  error ?? 'Issue type deleted successfully',
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

                // ── Add New Button ───────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: () => AddIssueTypeDialog.show(context, ref),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Create New Type'),
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

                // ── Pagination ────────────────────────────────────────────
                const SizedBox(height: 16),
                StandardPaginationControls(
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  onPageChanged: (page) => notifier.goToPage(page),
                ),
              ],
            ),
          ),
        ),
          ),
      ),
    );
  }
}

// ── Stats Grid ─────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final dynamic state;
  const _StatsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    const emerald = Color(0xFF10B981);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            _StatCard(
              title: 'Total Types',
              value: '${state.totalCount}',
              valueColor: primary,
            ),
            _StatCard(
              title: 'Active',
              value: '${state.activeCount}',
              valueColor: emerald,
            ),
            _StatCard(
              title: 'Inactive',
              value: '${state.inactiveCount}',
              valueColor: Colors.orange,
            ),
            const _StatCard(title: 'Current Page', value: '—'),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _StatCard({required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Issue Type Card ────────────────────────────────────────────────────────────

class _IssueTypeCard extends StatelessWidget {
  final IssueTypeModel item;
  final MaterialColor color;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IssueTypeCard({
    required this.item,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDeleted = item.deleted;
    final isActive = item.active && !isDeleted;

    const emerald = Color(0xFF10B981);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDeleted
              ? (isDark
                    ? const Color(0x800F172A)
                    : Colors.white.withValues(alpha: 0.5))
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDeleted
                ? Colors.grey.withValues(alpha: 0.3)
                : theme.dividerColor,
            width: isDeleted ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isDeleted ? 0.6 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon Box ───────────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: isDeleted ? Colors.grey : color[600]),
              ),
              const SizedBox(width: 16),

              // ── Content ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.issueType,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? Colors.red.withValues(alpha: 0.1)
                                : (isActive
                                      ? emerald.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1)),
                            border: Border.all(
                              color: isDeleted
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : (isActive
                                        ? emerald.withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.2)),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isDeleted
                                ? 'DELETED'
                                : (isActive ? 'ACTIVE' : 'INACTIVE'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDeleted
                                  ? Colors.red
                                  : (isActive ? emerald : Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Description
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // ID chip
                    const SizedBox(height: 8),
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
                        'ID: ${item.issueTypeId}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Action Buttons ─────────────────────────────────────
              Column(
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
      ),
    );
  }
}
