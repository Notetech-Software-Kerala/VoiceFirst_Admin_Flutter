import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/custom_field/presentation/providers/custom_field_provider.dart';
import 'package:voice_first_admin/features/custom_field/presentation/pages/add_custom_field_page.dart';
import 'package:voice_first_admin/features/custom_field/presentation/pages/edit_custom_field_page.dart';
import 'package:voice_first_admin/features/custom_field/presentation/pages/custom_field_detail_page.dart';

const _fieldTypeLabels = {
  'text': 'Short Text',
  'textarea': 'Long Text',
  'number': 'Number',
  'dropdown': 'Dropdown',
  'date': 'Date Picker',
};

const _fieldTypeIcons = {
  'text': Icons.short_text,
  'textarea': Icons.notes,
  'number': Icons.tag,
  'dropdown': Icons.arrow_drop_down_circle_outlined,
  'date': Icons.calendar_today_outlined,
};

const _fieldTypeColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
];

class ViewCustomFieldsPage extends ConsumerStatefulWidget {
  const ViewCustomFieldsPage({super.key});

  @override
  ConsumerState<ViewCustomFieldsPage> createState() =>
      _ViewCustomFieldsPageState();
}

class _ViewCustomFieldsPageState
    extends ConsumerState<ViewCustomFieldsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customFieldProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _typeLabel(String type) =>
      _fieldTypeLabels[type.toLowerCase()] ?? type;

  IconData _typeIcon(String type) =>
      _fieldTypeIcons[type.toLowerCase()] ?? Icons.input;

  Color _colorFor(int index) =>
      _fieldTypeColors[index % _fieldTypeColors.length];

  Future<void> _confirmDelete(
    BuildContext context,
    CustomFieldModel field,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Custom Field'),
        content: Text(
          'Are you sure you want to delete "${field.fieldName}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final err = await ref
          .read(customFieldProvider.notifier)
          .remove(field.fieldId!);
      if (context.mounted) {
        if (err == null) {
          CustomSnackbar.show(
            context,
            message: '${field.fieldName} deleted',
            type: SnackBarType.success,
          );
        } else {
          CustomSnackbar.show(
            context,
            message: err,
            type: SnackBarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final state = ref.watch(customFieldProvider);
    final notifier = ref.read(customFieldProvider.notifier);

    return Builder(
      builder: (outerContext) => Scaffold(
        appBar: AppBar(
          backgroundColor:
              theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
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
                'Custom Fields',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: () => _openAddPage(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Field'),
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: notifier.search,
                decoration: InputDecoration(
                  hintText: 'Search fields…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state.search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            notifier.search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // ── Count badge ────────────────────────────────────────────────
            if (!state.isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    Text(
                      '${state.totalCount} field${state.totalCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // ── List ───────────────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _ErrorView(
                          error: state.error!,
                          onRetry: () => notifier.loadAll(),
                        )
                      : state.filtered.isEmpty
                          ? _EmptyView(onAdd: () => _openAddPage(context))
                          : RefreshIndicator(
                              onRefresh: () => notifier.loadAll(),
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                                itemCount: state.filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (ctx, i) {
                                  final field = state.filtered[i];
                                  final color = _colorFor(i);
                                  return _FieldCard(
                                    field: field,
                                    color: color,
                                    typeLabel: _typeLabel(field.fieldDataType),
                                    typeIcon: _typeIcon(field.fieldDataType),
                                    onTap: () => _openDetailPage(context, field),
                                    onEdit: () =>
                                        _openEditPage(context, field),
                                    onDelete: () =>
                                        _confirmDelete(context, field),
                                  );
                                },
                              ),
                            ),
            ),

            // ── Pagination ────────────────────────────────────────────────
            if (!state.isLoading && state.totalPages > 1)
              _PaginationBar(
                current: state.currentPage,
                total: state.totalPages,
                onPageChanged: notifier.goToPage,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetailPage(
    BuildContext context,
    CustomFieldModel field,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomFieldDetailPage(field: field),
      ),
    );
    if (mounted) {
      ref.read(customFieldProvider.notifier).loadAll();
    }
  }

  Future<void> _openAddPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCustomFieldPage(),
      ),
    );
    if (mounted) {
      ref.read(customFieldProvider.notifier).loadAll();
    }
  }

  Future<void> _openEditPage(
    BuildContext context,
    CustomFieldModel field,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCustomFieldPage(field: field),
      ),
    );
    if (mounted) {
      ref.read(customFieldProvider.notifier).loadAll();
    }
  }
}

// ─── Field Card ────────────────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final CustomFieldModel field;
  final Color color;
  final String typeLabel;
  final IconData typeIcon;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FieldCard({
    required this.field,
    required this.color,
    required this.typeLabel,
    required this.typeIcon,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(typeIcon, color: color, size: 22),
        ),
        title: Text(
          field.fieldName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              'Key: ${field.fieldKey}',
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                if (field.validations.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${field.validations.length} rule${field.validations.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
                if (field.options.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${field.options.length} option${field.options.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty & Error States ──────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.text_fields_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No custom fields yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add First Field'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(error.replaceFirst('Exception: ', '')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Pagination Bar ────────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onPageChanged;

  const _PaginationBar({
    required this.current,
    required this.total,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: current > 1 ? () => onPageChanged(current - 1) : null,
          ),
          Text('$current / $total'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                current < total ? () => onPageChanged(current + 1) : null,
          ),
        ],
      ),
    );
  }
}


