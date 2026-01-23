import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Applications/Providers/application_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_management/presentation/dialogs/delete_program_dialog.dart';
import 'package:voice_first_admin/features/Program_management/presentation/pages/add_program_page.dart';
import 'package:voice_first_admin/features/Program_management/presentation/pages/program_detail_page.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';

class ProgramManagementView extends ConsumerWidget {
  const ProgramManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: notifier.search,
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
                // const SizedBox(height: 12),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       SizedBox(
                //         width: 160,
                //         height: 55,
                //         child: _ApplicationFilter(),
                //       ),
                //       const SizedBox(width: 8),
                //       SizedBox(width: 130, height: 55, child: _CompanyFilter()),
                //     ],
                //   ),
                // ),
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
                : ListView.builder(
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
                              ? primaryColor.withOpacity(0.12)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: selected
                                ? BorderSide(color: primaryColor, width: 1.5)
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
                                      // Text(
                                      //   program.programName,
                                      //   style: const TextStyle(
                                      //     fontSize: 16,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      Text(
                                        program.programName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDeleted
                                              ? Colors.red
                                              : Colors.black,
                                          // decoration: isDeleted
                                          //     ? TextDecoration.lineThrough
                                          //     : null,
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
                                      // Text(
                                      //   'Route: ${program.programRoute}',
                                      //   style: TextStyle(
                                      //     color: Colors.grey[600],
                                      //     fontSize: 12,
                                      //   ),
                                      // ),
                                      // const SizedBox(height: 2),
                                      // Text(
                                      //   'App: ${program.applicationId}${program.companyId != null ? ' | Company: ${program.companyId}' : ''}',
                                      //   style: TextStyle(
                                      //     color: Colors.grey[600],
                                      //     fontSize: 11,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                // if (!state.isMultiSelect && id != null)
                                //   Row(
                                //     mainAxisSize: MainAxisSize.min,
                                //     children: [
                                //       IconButton(
                                //         icon: const Icon(
                                //           Icons.delete,
                                //           color: Colors.red,
                                //           size: 20,
                                //         ),
                                //         onPressed: () {
                                //           DeleteProgramDialog.show(
                                //             context,
                                //             ref,
                                //             id,
                                //             program.programName,
                                //           );
                                //         },
                                //       ),
                                //     ],
                                //   ),
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
                                      // IconButton(
                                      //   icon: const Icon(
                                      //     Icons.delete,
                                      //     color: Colors.red,
                                      //   ),
                                      //   onPressed: () {
                                      //     DeleteProgramDialog.show(
                                      //       context,
                                      //       ref,
                                      //       id,
                                      //       program.programName,
                                      //     );
                                      //   },
                                      // ),
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
          ),
        ],
      ),
      floatingActionButton: state.isMultiSelect
          ? null
          : FloatingActionButton(
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
