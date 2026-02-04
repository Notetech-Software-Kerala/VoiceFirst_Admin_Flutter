import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import '../providers/program_action_provider.dart';
import '../dialogs/edit_program_action_dialog.dart';

class ProgramActionDetailView extends ConsumerWidget {
  final ProgramActionModel action;

  const ProgramActionDetailView({super.key, required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = const Color(0xFF0D7FF2);

    final state = ref.watch(programActionProvider);

    // Get the latest version of this action from the provider
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

    // Determine if action is deleted
    final isDeleted = updatedAction.deleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Program Action Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          updatedAction.actionName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: updatedAction.active
                                ? Colors.green.withAlpha(38)
                                : Colors.red.withAlpha(38),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            updatedAction.active ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: updatedAction.active
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailSection(
                    title: 'Basic Information',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Action ID',
                        value: updatedAction.actionId.toString(),
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Action Name',
                        value: updatedAction.actionName,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Active Status',
                        value: updatedAction.active ? 'Active' : 'Inactive',
                        primaryColor: primaryColor,
                        valueColor: updatedAction.active
                            ? Colors.green
                            : Colors.red,
                      ),
                      _DetailItem(
                        label: 'Delete Status',
                        value: isDeleted ? 'Deleted' : 'Not Deleted',
                        primaryColor: primaryColor,
                        valueColor: isDeleted ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (updatedAction.createdUser != null ||
                      updatedAction.createdDate != null) ...[
                    _DetailSection(
                      title: 'Created Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Created By',
                          value: updatedAction.createdUser ?? 'N/A',
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Created Date',
                          value: updatedAction.createdDate != null
                              ? _formatDateTime(updatedAction.createdDate!)
                              : 'N/A',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (updatedAction.modifiedUser != null ||
                      updatedAction.modifiedDate != null) ...[
                    _DetailSection(
                      title: 'Modified Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Modified By',
                          value: updatedAction.modifiedUser ?? 'N/A',
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Modified Date',
                          value: updatedAction.modifiedDate != null
                              ? _formatDateTime(updatedAction.modifiedDate!)
                              : 'Not modified',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (isDeleted) ...[
                    _DetailSection(
                      title: 'Deleted Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Deleted By',
                          value: updatedAction.deletedUser?.isEmpty ?? true
                              ? 'N/A'
                              : updatedAction.deletedUser!,
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Deleted Date',
                          value: updatedAction.deletedDate != null
                              ? _formatDateTime(updatedAction.deletedDate!)
                              : 'N/A',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      if (isDeleted)
                        /// ♻️ RECOVER BUTTON
                        Expanded(
                          child: OutlinedButton.icon(
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
                            icon: const Icon(
                              Icons.restore,
                              color: Colors.green,
                            ),
                            label: const Text(
                              'Recover Action',
                              style: TextStyle(color: Colors.green),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                      else ...[
                        /// ✏️ EDIT
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => EditProgramActionDialog.show(
                              context,
                              ref,
                              updatedAction,
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Edit Action',
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        /// 🗑 DELETE
                        Expanded(
                          child: OutlinedButton(
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
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Delete Action',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.primaryColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 0, color: Colors.grey.shade200),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color primaryColor;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.primaryColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
