import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';

import '../../data/models/place_model.dart';
import '../providers/place_provider.dart';
import '../providers/place_state.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  final int placeId;
  final PlaceModel? initialPlace;

  const PlaceDetailPage({super.key, required this.placeId, this.initialPlace});

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  final Set<int> _expandedOffices = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(placeProvider.notifier).selectPlace(widget.placeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(placeProvider);
    final notifier = ref.read(placeProvider.notifier);
    final place = _resolvePlace(state);

    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Place Details')),
        body: Center(
          child: state.isDetailLoading
              ? const CircularProgressIndicator()
              : const Text('Unable to load place details'),
        ),
      );
    }

    final bool isDeleted = place.deleted;
    final bool isActive = place.active && !isDeleted;
    final String statusText = isDeleted
        ? 'Deleted'
        : (isActive ? 'Active' : 'Inactive');
    final Color statusColor = isDeleted
        ? Colors.red
        : (isActive ? Colors.green : Colors.orange);

    final totalPostOffices = place.postOffices.length;
    final totalZipCodes = place.postOffices.fold<int>(
      0,
      (sum, office) => sum + office.zipCodes.length,
    );
    final activeZipCodes = place.postOffices.fold<int>(
      0,
      (sum, office) => sum + office.zipCodes.where((zip) => zip.active).length,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Details'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: state.isDetailLoading
              ? const LinearProgressIndicator(minHeight: 1)
              : Divider(height: 1, color: theme.dividerColor),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
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
                      children: [
                        const Expanded(child: _Label('PLACE NAME')),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Text(
                            place.placeName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: _Label('STATUS')),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(statusText),
                          backgroundColor: statusColor.withOpacity(.12),
                          labelStyle: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.account_tree,
                            label: 'Post Offices',
                            value: '$totalPostOffices',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.local_post_office_outlined,
                            label: 'Zip Codes',
                            value: '$activeZipCodes / $totalZipCodes',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Created By',
                      value: place.createdUser ?? 'Unknown',
                    ),
                    _InfoRow(
                      label: 'Created Date',
                      value: _fmtDate(place.createdDate),
                    ),
                    if (place.modifiedUser != null ||
                        place.modifiedDate != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Modified By',
                        value: place.modifiedUser ?? 'Unknown',
                      ),
                      _InfoRow(
                        label: 'Modified Date',
                        value: _fmtDate(place.modifiedDate),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_city_outlined),
                        const SizedBox(width: 8),
                        const Text(
                          'Linked Post Offices',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          '${place.postOffices.length} entries',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (place.postOffices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No post offices linked yet'),
                      )
                    else
                      ...place.postOffices.map(
                        (office) => _PostOfficeTile(
                          office: office,
                          expanded: _expandedOffices.contains(
                            office.postOfficeId,
                          ),
                          formatDate: _fmtDate,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              if (expanded) {
                                _expandedOffices.add(office.postOfficeId);
                              } else {
                                _expandedOffices.remove(office.postOfficeId);
                              }
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: const Icon(Icons.history),
                    title: const Text(
                      'History',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Created, updated & deleted information',
                      style: theme.textTheme.bodySmall,
                    ),
                    children: [
                      _PlaceHistorySection(place: place, formatDate: _fmtDate),
                    ],
                  ),
                ),
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
                    theme.scaffoldBackgroundColor.withAlpha(230),
                    theme.scaffoldBackgroundColor.withAlpha(0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: isDeleted
                        ? StandardRecoveryButton(
                            label: 'Recover Place',
                            onPressed: () {
                              showRecoveryBottomSheet(
                                context: context,
                                itemName: place.placeName,
                                onRecover: () async {
                                  final success = await notifier.recoverPlace(
                                    place.placeId,
                                  );
                                  if (!context.mounted) return;
                                  CustomSnackbar.show(
                                    context,
                                    message: success
                                        ? 'Place recovered successfully'
                                        : 'Failed to recover place',
                                    type: success
                                        ? SnackBarType.success
                                        : SnackBarType.error,
                                  );
                                },
                              );
                            },
                          )
                        : StandardDeleteButton(
                            label: 'Delete Place',
                            onPressed: () {
                              showDeleteBottomSheet(
                                context: context,
                                itemName: place.placeName,
                                onDelete: () async {
                                  final success = await notifier.deletePlace(
                                    place.placeId,
                                  );
                                  if (!context.mounted) return;
                                  CustomSnackbar.show(
                                    context,
                                    message: success
                                        ? 'Place deleted successfully'
                                        : 'Failed to delete place',
                                    type: success
                                        ? SnackBarType.success
                                        : SnackBarType.error,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  if (!isDeleted) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: StandardEditButton(
                        label: 'Edit Place',
                        onPressed: () {
                          CustomSnackbar.show(
                            context,
                            message: 'Edit place is not implemented yet',
                            type: SnackBarType.info,
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
  }

  PlaceModel? _resolvePlace(PlaceState state) {
    if (state.selectedPlace?.placeId == widget.placeId) {
      return state.selectedPlace;
    }

    PlaceModel? cached;
    for (final item in state.places) {
      if (item.placeId == widget.placeId) {
        cached = item;
        break;
      }
    }

    return cached ?? widget.initialPlace;
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _PostOfficeTile extends StatelessWidget {
  final PlacePostOffice office;
  final bool expanded;
  final void Function(bool expanded) onExpansionChanged;
  final String Function(DateTime?) formatDate;

  const _PostOfficeTile({
    required this.office,
    required this.expanded,
    required this.onExpansionChanged,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: onExpansionChanged,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          office.postOfficeName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${office.zipCodes.length} zip codes'),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          if (office.zipCodes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No zip codes linked'),
            )
          else
            ...office.zipCodes.map(
              (zip) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            zip.zipCode,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (zip.active ? Colors.green : Colors.orange)
                                .withAlpha(31),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            zip.active ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: zip.active ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Created By',
                      value: zip.createdUser ?? 'Unknown',
                    ),
                    _InfoRow(
                      label: 'Created Date',
                      value: formatDate(zip.createdDate),
                    ),
                    if (zip.modifiedUser != null ||
                        zip.modifiedDate != null) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                        label: 'Modified By',
                        value: zip.modifiedUser ?? 'Unknown',
                      ),
                      _InfoRow(
                        label: 'Modified Date',
                        value: formatDate(zip.modifiedDate),
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
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

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
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceHistorySection extends StatelessWidget {
  final PlaceModel place;
  final String Function(DateTime?) formatDate;

  const _PlaceHistorySection({required this.place, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _HistoryExpansionTile(
        icon: Icons.flag_circle_outlined,
        title: 'Created Info',
        subtitle: 'Created by ${_formatUser(place.createdUser)}',
        initiallyExpanded: true,
        entries: [
          _HistoryEntry(
            label: 'Created By',
            value: _formatUser(place.createdUser),
          ),
          _HistoryEntry(
            label: 'Created Date',
            value: formatDate(place.createdDate),
          ),
        ],
      ),
    ];

    final hasModified =
        place.modifiedUser != null || place.modifiedDate != null;
    final hasDeleted = place.deletedUser != null || place.deletedDate != null;

    if (hasModified) {
      tiles.add(
        _HistoryExpansionTile(
          icon: Icons.update,
          title: 'Modified Info',
          subtitle: 'Modified by ${_formatUser(place.modifiedUser)}',
          entries: [
            _HistoryEntry(
              label: 'Modified By',
              value: _formatUser(place.modifiedUser),
            ),
            _HistoryEntry(
              label: 'Modified Date',
              value: formatDate(place.modifiedDate),
            ),
          ],
        ),
      );
    }

    if (hasDeleted) {
      tiles.add(
        _HistoryExpansionTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Deleted Info',
          subtitle: 'Deleted by ${_formatUser(place.deletedUser)}',
          entries: [
            _HistoryEntry(
              label: 'Deleted By',
              value: _formatUser(place.deletedUser),
            ),
            _HistoryEntry(
              label: 'Deleted Date',
              value: formatDate(place.deletedDate),
            ),
          ],
        ),
      );
    }

    return Column(children: tiles);
  }

  String _formatUser(String? value) {
    if (value == null || value.trim().isEmpty) return 'Unknown';
    return value;
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: entries.map((entry) => entry).toList(),
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryEntry({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
