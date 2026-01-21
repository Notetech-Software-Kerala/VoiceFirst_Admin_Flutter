import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import '../providers/program_action_provider.dart';
import '../dialogs/edit_program_action_dialog.dart';
import '../dialogs/delete_program_action_dialog.dart';

class ProgramActionDetailView extends ConsumerWidget {
  final int actionId;

  const ProgramActionDetailView({super.key, required this.actionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = const Color(0xFF0D7FF2);

    final state = ref.watch(programActionProvider);

    final action = state.actions
        .where((a) => a.actionId == actionId)
        .cast<ProgramActionModel?>()
        .firstOrNull;

    // SAFETY GUARD
    if (action == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Action Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Action not found')),
      );
    }

    // Determine if action is deleted
    final isDeleted = action.deleted;

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
                          action.actionName,
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
                            color: action.active
                                ? Colors.green.withAlpha(38)
                                : Colors.red.withAlpha(38),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            action.active ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: action.active
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
                        value: action.actionId.toString(),
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Action Name',
                        value: action.actionName,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Active Status',
                        value: action.active ? 'Active' : 'Inactive',
                        primaryColor: primaryColor,
                        valueColor: action.active ? Colors.green : Colors.red,
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
                  if (action.createdUser != null ||
                      action.createdDate != null) ...[
                    _DetailSection(
                      title: 'Created Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Created By',
                          value: action.createdUser ?? 'N/A',
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Created Date',
                          value: action.createdDate != null
                              ? _formatDateTime(action.createdDate!)
                              : 'N/A',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (action.modifiedUser != null ||
                      action.modifiedDate != null) ...[
                    _DetailSection(
                      title: 'Modified Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Modified By',
                          value: action.modifiedUser ?? 'N/A',
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Modified Date',
                          value: action.modifiedDate != null
                              ? _formatDateTime(action.modifiedDate!)
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
                          value: action.deletedUser?.isEmpty ?? true
                              ? 'N/A'
                              : action.deletedUser!,
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Deleted Date',
                          value: action.deletedDate != null
                              ? _formatDateTime(action.deletedDate!)
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
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final error = await ref
                                  .read(programActionProvider.notifier)
                                  .recover(action.actionId);

                              if (error != null) {
                                if (context.mounted) {
                                  CustomSnackbar.show(
                                    context,
                                    message: error,
                                    type: SnackBarType.error,
                                  );
                                }
                                return;
                              }

                              if (context.mounted) {
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      '${action.actionName} recovered successfully',
                                  type: SnackBarType.success,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.restore,
                              color: Colors.white,
                            ),
                            label: const Text('Recover Action'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
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
                          child: ElevatedButton.icon(
                            onPressed: () => EditProgramActionDialog.show(
                              context,
                              ref,
                              action,
                            ),
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text('Edit Action'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        /// 🗑 DELETE
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => DeleteProgramActionDialog.show(
                              context,
                              ref,
                              action.actionId,
                              action.actionName,
                            ),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('Delete Action'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
