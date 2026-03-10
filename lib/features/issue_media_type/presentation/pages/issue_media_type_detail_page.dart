import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_model.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/dialogs/edit_issue_media_type_dialog.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/providers/issue_media_type_provider.dart';

class IssueMediaTypeDetailPage extends ConsumerWidget {
  final int id;

  const IssueMediaTypeDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final asyncValue = ref.watch(issueMediaTypeDetailProvider(id));

    String formatDate(DateTime dt) {
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return asyncValue.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Issue Media Type Details'),
          elevation: 0,
          leading: const BackButton(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Issue Media Type Details'),
          elevation: 0,
          leading: const BackButton(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load details: $error'),
          ),
        ),
      ),
      data: (updated) {
        final isDeleted = updated.deleted;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Issue Media Type Details'),
            elevation: 0,
            leading: const BackButton(),
            toolbarHeight: kToolbarHeight,
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
                            const Expanded(child: _Label('MEDIA TYPE')),
                            const SizedBox(width: 12),
                            Text(
                              updated.issueMediaType,
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
                                  : (updated.active ? 'Active' : 'Suspended'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDeleted
                                    ? Colors.red
                                    : (updated.active
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
                    mediaType: updated,
                    isDeleted: isDeleted,
                    formatDate: formatDate,
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
                              itemName: updated.issueMediaType,
                              onRecover: () async {
                                final error = await ref
                                    .read(issueMediaTypeProvider.notifier)
                                    .recover(updated.issueMediaTypeId);

                                if (error == null) {
                                  ref.refresh(issueMediaTypeDetailProvider(id));
                                  CustomSnackbar.show(
                                    context,
                                    message:
                                        '${updated.issueMediaType} recovered successfully',
                                    type: SnackBarType.success,
                                  );
                                } else {
                                  CustomSnackbar.show(
                                    context,
                                    message: error,
                                    type: SnackBarType.error,
                                  );
                                }
                              },
                            ),
                          ),
                        )
                      else ...[
                        Expanded(
                          child: StandardDeleteButton(
                            label: 'Delete',
                            onPressed: () => showDeleteBottomSheet(
                              context: context,
                              itemName: updated.issueMediaType,
                              onDelete: () async {
                                final error = await ref
                                    .read(issueMediaTypeProvider.notifier)
                                    .delete(updated.issueMediaTypeId);

                                if (error == null) {
                                  ref.refresh(issueMediaTypeDetailProvider(id));
                                  CustomSnackbar.show(
                                    context,
                                    message:
                                        '${updated.issueMediaType} deleted successfully',
                                    type: SnackBarType.success,
                                  );
                                } else {
                                  CustomSnackbar.show(
                                    context,
                                    message: error,
                                    type: SnackBarType.error,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: StandardEditButton(
                            label: 'Edit',
                            onPressed: () {
                              EditIssueMediaTypeDialog.show(
                                context,
                                ref,
                                updated,
                              );
                            },
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
      },
    );
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
  final IssueMediaTypeModel mediaType;
  final bool isDeleted;
  final String Function(DateTime) formatDate;

  const _HistorySection({
    required this.mediaType,
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

    final hasModified =
        (mediaType.modifiedUser != null &&
            mediaType.modifiedUser!.trim().isNotEmpty) ||
        mediaType.modifiedDate != null;

    final hasDeletedInfo =
        isDeleted &&
        ((mediaType.deletedUser != null &&
                mediaType.deletedUser!.trim().isNotEmpty) ||
            mediaType.deletedDate != null);

    return Column(
      children: [
        _HistoryExpansionTile(
          icon: Icons.flag_circle_outlined,
          title: 'Created Info',
          subtitle:
              'Created by ${formatUser(mediaType.createdUser, fallback: 'Unknown')}',
          initiallyExpanded: true,
          entries: [
            _HistoryEntry(
              label: 'Created By',
              value: formatUser(mediaType.createdUser, fallback: 'Unknown'),
            ),
            _HistoryEntry(
              label: 'Created Date',
              value: formatDateSafe(mediaType.createdDate),
            ),
          ],
        ),
        if (hasModified)
          _HistoryExpansionTile(
            icon: Icons.history,
            title: 'Modified Info',
            subtitle:
                'Modified by ${formatUser(mediaType.modifiedUser, fallback: 'Not modified')}',
            initiallyExpanded: !isDeleted && hasModified,
            entries: [
              _HistoryEntry(
                label: 'Modified By',
                value: formatUser(
                  mediaType.modifiedUser,
                  fallback: 'Not modified',
                ),
              ),
              _HistoryEntry(
                label: 'Modified Date',
                value: formatDateSafe(
                  mediaType.modifiedDate,
                  fallback: 'Not modified',
                ),
              ),
            ],
          ),
        if (hasDeletedInfo)
          _HistoryExpansionTile(
            icon: Icons.delete_forever_outlined,
            title: 'Deleted Info',
            subtitle:
                'Deleted by ${formatUser(mediaType.deletedUser, fallback: 'Unknown')}',
            initiallyExpanded: true,
            entries: [
              _HistoryEntry(
                label: 'Deleted By',
                value: formatUser(mediaType.deletedUser, fallback: 'Unknown'),
              ),
              _HistoryEntry(
                label: 'Deleted Date',
                value: formatDateSafe(mediaType.deletedDate, fallback: 'N/A'),
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
            ? theme.cardColor.withAlpha(153)
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
