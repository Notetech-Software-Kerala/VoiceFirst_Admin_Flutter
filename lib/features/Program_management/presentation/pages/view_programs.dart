import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Applications/Providers/application_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_management/presentation/dialogs/delete_program_dialog.dart';
import 'package:voice_first_admin/features/Program_management/presentation/pages/add_program_page.dart';
import 'package:voice_first_admin/features/Program_management/presentation/pages/program_detail_page.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'package:voice_first_admin/features/Program_management/models/program_filter.dart';

class ProgramManagementView extends ConsumerStatefulWidget {
  const ProgramManagementView({super.key});

  @override
  ConsumerState<ProgramManagementView> createState() =>
      _ProgramManagementViewState();
}

class _ProgramManagementViewState extends ConsumerState<ProgramManagementView> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(programProvider.notifier)
          .loadAll(
            filter: const ProgramFilter(pageNumber: 1, pageSize: _pageSize),
          );
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final currentSearch = ref.read(programProvider).search;
    ref
        .read(programProvider.notifier)
        .loadAll(
          filter: ProgramFilter(
            pageNumber: page,
            pageSize: _pageSize,
            searchText: currentSearch.isEmpty ? null : currentSearch,
          ),
        );

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(programProvider);
    final notifier = ref.read(programProvider.notifier);
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : 'Program Management',
          style: const TextStyle(color: Colors.white),
        ),
        leading: state.isMultiSelect
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: notifier.exitSelectionMode,
              )
            : null,
        actions: [
          if (!state.isMultiSelect)
            TextButton(
              onPressed: notifier.enterSelectionMode,
              child: const Text(
                'Select',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (state.isMultiSelect)
            TextButton(
              onPressed: notifier.exitSelectionMode,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (state.isMultiSelect && state.selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                notifier.deleteSelected();
                CustomSnackbar.show(
                  context,
                  message: 'Selected programs deleted',
                  type: SnackBarType.success,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search + filters
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(20),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (q) => notifier.search(q),
                  decoration: InputDecoration(
                    hintText: 'Search programs by name, label or route...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.filtered.isEmpty
                ? Center(
                    child: Text(
                      'No programs found',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 60,
                        ),
                        itemCount: state.filtered.length,
                        itemBuilder: (context, index) {
                          final program = state.filtered[index];
                          final id = program.sysProgramId;
                          final isDeleted = program.deleted ?? false;
                          final selected =
                              id != null && state.selectedIds.contains(id);
                          return GestureDetector(
                            onLongPress: id == null
                                ? null
                                : () => notifier.toggleSelection(id),
                            onTap: () {
                              if (id == null) return;

                              // If selection mode is ON → toggle checkbox
                              if (state.isMultiSelect) {
                                notifier.toggleSelection(id);
                                return;
                              }

                              // Otherwise → navigate to detail view
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProgramDetailPage(program: program),
                                ),
                              );
                            },

                            child: Card(
                              color: selected
                                  ? primaryColor.withAlpha(31)
                                  : Colors.white,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: selected
                                    ? BorderSide(
                                        color: primaryColor,
                                        width: 1.5,
                                      )
                                    : BorderSide.none,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    if (state.isMultiSelect && id != null)
                                      Checkbox(
                                        value: selected,
                                        onChanged: (_) =>
                                            notifier.toggleSelection(id),
                                        activeColor: primaryColor,
                                      ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            program.programName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDeleted
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),

                                          const SizedBox(height: 4),
                                          Text(
                                            program.labelName,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ),

                                    if (!state.isMultiSelect &&
                                        id != null &&
                                        !isDeleted)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 🔘 ACTIVE TOGGLE (only if NOT deleted)
                                          if (!isDeleted)
                                            Transform.scale(
                                              scale: 0.75,
                                              child: Switch(
                                                value: program.active ?? true,
                                                onChanged: (val) async {
                                                  final error = await notifier
                                                      .toggleStatus(id, val);
                                                  if (error != null &&
                                                      context.mounted) {
                                                    CustomSnackbar.show(
                                                      context,
                                                      message: error,
                                                      type: SnackBarType.error,
                                                    );
                                                  }
                                                },
                                                activeThumbColor: Colors.green,
                                              ),
                                            ),

                                          // 🗑 DELETE
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              DeleteProgramDialog.show(
                                                context,
                                                ref,
                                                id,
                                                program.programName,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (state.filtered.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 6,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Builder(
                                    builder: (_) {
                                      final start =
                                          (state.currentPage - 1) * _pageSize +
                                          1;
                                      final end =
                                          start + state.filtered.length - 1;
                                      return Text(
                                        '$start-$end of ${state.totalCount}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ),
                                PaginationControls(
                                  currentPage: state.currentPage,
                                  totalCount: state.totalCount,
                                  pageSize: _pageSize,
                                  isLoading: state.isLoading,
                                  hasMoreData: state.hasMoreData,
                                  onPageChanged: _goToPage,
                                  primaryColor: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: state.isMultiSelect
          ? null
          : FloatingActionButton(
              heroTag: 'program_fab',
              backgroundColor: primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProgramPage()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}

class _ApplicationFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programProvider);
    final notifier = ref.read(programProvider.notifier);
    final appsAsync = ref.watch(applicationProvider);

    return appsAsync.when(
      data: (apps) {
        return DropdownButtonFormField<int?>(
          value: apps.any((a) => a.platformId == state.selectedApplicationId)
              ? state.selectedApplicationId
              : null,
          decoration: const InputDecoration(
            labelText: 'Application',
            border: OutlineInputBorder(),
            filled: true,
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All Applications'),
            ),
            ...apps.map(
              (a) => DropdownMenuItem<int?>(
                value: a.platformId,
                child: Text(a.platformName),
              ),
            ),
          ],
          onChanged: notifier.setApplicationFilter,
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const Text('Failed to load applications'),
    );
  }
}


class _CompanyFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programProvider);
    final notifier = ref.read(programProvider.notifier);

    return TextFormField(
      initialValue: state.selectedCompanyId != null
          ? '${state.selectedCompanyId}'
          : '',
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Company Id',
        border: OutlineInputBorder(),
        filled: true,
      ),
      onChanged: (value) {
        if (value.trim().isEmpty) {
          notifier.setCompanyFilter(null);
        } else {
          notifier.setCompanyFilter(int.tryParse(value.trim()));
        }
      },
    );
  }
}

// ignore: unused_element
class _ProgramCard extends StatelessWidget {
  final String name;
  final String label;
  final bool isDeleted;
  final bool isActive;
  final bool selected;
  final bool showCheckbox;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggle;

  const _ProgramCard({
    required this.name,
    required this.label,
    required this.isDeleted,
    required this.isActive,
    required this.selected,
    required this.showCheckbox,
    this.onTap,
    this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D7FF2);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withAlpha(31) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: primaryColor, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCheckbox)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Checkbox(value: selected, onChanged: (_) {}),
              ),

            /// ICON
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.extension_rounded, color: primaryColor),
            ),

            const SizedBox(width: 16),

            /// TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDeleted ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// STATUS CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDeleted
                          ? Colors.red.withAlpha(38)
                          : isActive
                          ? Colors.green.withAlpha(38)
                          : Colors.orange.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDeleted
                          ? 'DELETED'
                          : isActive
                          ? 'ACTIVE'
                          : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDeleted
                            ? Colors.red
                            : isActive
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ACTIONS
            if (!isDeleted)
              Column(
                children: [
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(value: isActive, onChanged: onToggle),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
