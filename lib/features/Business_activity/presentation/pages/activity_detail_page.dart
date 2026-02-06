import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../dialogs/edit_activity_dialog.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class ActivityDetailPage extends ConsumerWidget {
  final BusinessActivity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final state = ref.watch(businessActivityProvider);

    final updatedActivity = state.items.firstWhere(
      (a) => a.activityId == activity.activityId,
      orElse: () => activity,
    );

    final isDeleted = updatedActivity.isDeleted;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Activity Details'),
        elevation: 0,
        leading: const BackButton(),
        toolbarHeight: kToolbarHeight,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              // PRIMARY INFO CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity Name Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: _Label('ACTIVITY NAME')),
                        const SizedBox(width: 12),
                        Text(
                          updatedActivity.activityName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: _Label('STATUS')),
                        const SizedBox(width: 12),
                        Text(
                          isDeleted
                              ? 'Deleted'
                              : (updatedActivity.active
                                    ? 'Active'
                                    : 'Inactive'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDeleted
                                ? Colors.red
                                : (updatedActivity.active
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

              // HISTORY (Created/Modified [+ Deleted if deleted])
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text(
                            'History',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Audit information',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.6,
                        children: [
                          _GridItem(
                            label: 'Created By',
                            value: updatedActivity.createdUser,
                          ),
                          _GridItem(
                            label: 'Created Date',
                            value: _format(updatedActivity.createdDate),
                          ),
                          _GridItem(
                            label: 'Modified By',
                            value: updatedActivity.modifiedUser ?? 'N/A',
                          ),
                          _GridItem(
                            label: 'Modified Date',
                            value: updatedActivity.modifiedDate != null
                                ? _format(updatedActivity.modifiedDate!)
                                : 'Not modified',
                          ),
                          if (isDeleted) ...[
                            _GridItem(
                              label: 'Deleted By',
                              value: updatedActivity.deletedUser ?? 'N/A',
                            ),
                            _GridItem(
                              label: 'Deleted Date',
                              value: updatedActivity.deletedDate != null
                                  ? _format(updatedActivity.deletedDate!)
                                  : 'N/A',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // STICKY FOOTER ACTIONS
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
                          itemName: updatedActivity.activityName,
                          onRecover: () {
                            ref
                                .read(businessActivityProvider.notifier)
                                .recover(updatedActivity.activityId);
                            CustomSnackbar.show(
                              context,
                              message:
                                  '${updatedActivity.activityName} recovered successfully',
                              type: SnackBarType.success,
                            );
                          },
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: StandardEditButton(
                        label: 'Edit',
                        onPressed: () => EditActivityDialog.show(
                          context,
                          ref,
                          updatedActivity,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StandardDeleteButton(
                        label: 'Delete',
                        onPressed: () => showDeleteBottomSheet(
                          context: context,
                          itemName: updatedActivity.activityName,
                          onDelete: () {
                            ref
                                .read(businessActivityProvider.notifier)
                                .delete(updatedActivity.activityId);
                            CustomSnackbar.show(
                              context,
                              message:
                                  '${updatedActivity.activityName} deleted successfully',
                              type: SnackBarType.success,
                            );
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

// ───────────────── UI HELPERS ─────────────────

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

class _GridItem extends StatelessWidget {
  final String label;
  final String value;

  const _GridItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
