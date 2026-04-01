import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/program_action/data/models/program_action_model.dart';
import 'package:voice_first_admin/features/program_action/presentation/dialogs/edit_program_action_dialog.dart';
import 'package:voice_first_admin/features/program_action/presentation/providers/program_action_provider.dart';

class ProgramActionDetailView extends ConsumerWidget {
  final ProgramActionModel action;

  const ProgramActionDetailView({super.key, required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(programActionProvider);

    final updatedAction =
        state.actions
            .where((a) => a.actionId == action.actionId)
            .cast<ProgramActionModel?>()
            .firstOrNull ??
        state.filtered
            .where((a) => a.actionId == action.actionId)
            .cast<ProgramActionModel?>()
            .firstOrNull ??
        action;

    final isDeleted = updatedAction.deleted;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Program Action Details'),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: _Label('ACTION NAME')),
                        const SizedBox(width: 12),
                        Text(
                          updatedAction.actionName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: _Label('STATUS')),
                        const SizedBox(width: 12),
                        Text(
                          isDeleted
                              ? 'Deleted'
                              : (updatedAction.active ? 'Active' : 'Suspended'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDeleted
                                ? Colors.red
                                : (updatedAction.active
                                      ? Colors.green
                                      : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _HistorySection(
                action: updatedAction,
                isDeleted: isDeleted,
                formatDate: _format,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withAlpha(100),
                    theme.scaffoldBackgroundColor.withAlpha(0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  if (isDeleted)
                    Expanded(
                      child: StandardRecoveryButton(
                        label: 'Recover',
                        onPressed: () => showRecoveryBottomSheet(
                          context: context,
                          itemName: updatedAction.actionName,
                          onRecover: () async {
                            final error = await ref
                                .read(programActionProvider.notifier)
                                .recover(updatedAction.actionId);
                            if (context.mounted) {
                              if (error != null) {
                                CustomSnackbar.show(
                                  context,
                                  message: error,
                                  type: SnackBarType.error,
                                );
                              } else {
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      '${updatedAction.actionName} recovered successfully',
                                  type: SnackBarType.success,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: StandardEditButton(
                        label: 'Edit',
                        onPressed: () => EditProgramActionDialog.show(
                          context,
                          ref,
                          updatedAction,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StandardDeleteButton(
                        label: 'Delete',
                        onPressed: () => showDeleteBottomSheet(
                          context: context,
                          itemName: updatedAction.actionName,
                          onDelete: () async {
                            final error = await ref
                                .read(programActionProvider.notifier)
                                .delete(updatedAction.actionId);
                            if (context.mounted) {
                              if (error != null) {
                                CustomSnackbar.show(
                                  context,
                                  message: error,
                                  type: SnackBarType.error,
                                );
                              } else {
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      'Program action deleted successfully',
                                  type: SnackBarType.success,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final ProgramActionModel action;
  final bool isDeleted;
  final String Function(DateTime) formatDate;

  const _HistorySection({
    required this.action,
    required this.isDeleted,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    String formatUser(String? value, {String fallback = 'N/A'}) {
      if (value == null || value.trim().isEmpty) return fallback;
      return value;
    }

    String formatDateSafe(DateTime? value, {String fallback = 'N/A'}) {
      if (value == null) return fallback;
      return formatDate(value);
    }

    return Column(
      children: [
        _HistoryExpansionTile(
          icon: Icons.flag_circle_outlined,
          title: 'Created Info',
          subtitle:
              'Created by ${formatUser(action.createdUser, fallback: 'Unknown')}',
          initiallyExpanded: true,
          entries: [
            _HistoryEntry(
              label: 'Created By',
              value: formatUser(action.createdUser, fallback: 'Unknown'),
            ),
            _HistoryEntry(
              label: 'Created Date',
              value: formatDateSafe(action.createdDate),
            ),
          ],
        ),
        _HistoryExpansionTile(
          icon: Icons.history,
          title: 'Modified Info',
          subtitle:
              'Modified by ${formatUser(action.modifiedUser, fallback: 'Not modified')}',
          initiallyExpanded:
              !isDeleted &&
              (action.modifiedUser != null || action.modifiedDate != null),
          entries: [
            _HistoryEntry(
              label: 'Modified By',
              value: formatUser(action.modifiedUser, fallback: 'Not modified'),
            ),
            _HistoryEntry(
              label: 'Modified Date',
              value: formatDateSafe(
                action.modifiedDate,
                fallback: 'Not modified',
              ),
            ),
          ],
        ),
        if (isDeleted)
          _HistoryExpansionTile(
            icon: Icons.delete_forever_outlined,
            title: 'Deleted Info',
            subtitle:
                'Deleted by ${formatUser(action.deletedUser, fallback: 'Unknown')}',
            initiallyExpanded: true,
            entries: [
              _HistoryEntry(
                label: 'Deleted By',
                value: formatUser(action.deletedUser, fallback: 'Unknown'),
              ),
              _HistoryEntry(
                label: 'Deleted Date',
                value: formatDateSafe(action.deletedDate, fallback: 'N/A'),
              ),
            ],
          ),
      ],
    );
  }
}

class _HistoryExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_HistoryEntry> entries;
  final bool initiallyExpanded;

  const _HistoryExpansionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.entries,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, index) =>
                  _HistoryChip(entry: entries[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEntry {
  final String label;
  final String value;
  const _HistoryEntry({required this.label, required this.value});
}

class _HistoryChip extends StatelessWidget {
  final _HistoryEntry entry;
  const _HistoryChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.cardColor.withAlpha(100)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withAlpha(153)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
