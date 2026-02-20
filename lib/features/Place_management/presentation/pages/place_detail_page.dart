import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import '../../data/models/place_model.dart';
import '../providers/place_provider.dart';
import '../providers/place_state.dart';
import 'edit_place_page.dart';

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
                        Text(
                          place.placeName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: _Label('STATUS')),
                        const SizedBox(width: 12),
                        Text(
                          isDeleted
                              ? 'Deleted'
                              : (place.active ? 'Active' : 'Inactive'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDeleted
                                ? Colors.red
                                : (place.active ? Colors.green : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  // Only show post offices that have at least one active zip code
                  final visibleOffices = place.postOffices
                      .where(
                        (office) => office.zipCodes.any((zip) => zip.active),
                      )
                      .toList();

                  return Container(
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
                              '${visibleOffices.length} entries',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (visibleOffices.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No post offices available now'),
                          )
                        else
                          ...visibleOffices.map(
                            (office) => _PostOfficeTile(
                              office: office,
                              expanded: _expandedOffices.contains(
                                office.postOfficeId,
                              ),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  if (expanded) {
                                    _expandedOffices.add(office.postOfficeId);
                                  } else {
                                    _expandedOffices.remove(
                                      office.postOfficeId,
                                    );
                                  }
                                });
                              },
                              onPostOfficeInfo: (o) =>
                                  _showPostOfficeInfoDialog(context, o),
                              onZipInfo: (zip) => _showZipCodeInfoDialog(
                                context,
                                zip,
                                _fmtDate,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
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
                        onPressed: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPlacePage(place: place),
                            ),
                          );
                          if (result == true && mounted) {
                            CustomSnackbar.show(
                              context,
                              message: 'Place updated successfully',
                              type: SnackBarType.success,
                            );
                          }
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
    if (state.selectedPlace != null &&
        state.selectedPlace!.placeId == widget.placeId) {
      return state.selectedPlace;
    }

    try {
      return state.places.firstWhere((p) => p.placeId == widget.placeId);
    } catch (_) {
      return null;
    }
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

  void _showPostOfficeInfoDialog(BuildContext context, PlacePostOffice office) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String _fallbackLabel(String? label, String fallback) {
          if (label == null || label.trim().isEmpty) return fallback;
          return label;
        }

        return AlertDialog(
          title: const Text('Post Office Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Country Name',
                  value: office.countryName ?? 'Unknown',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: _fallbackLabel(
                    office.divisionOneLabel,
                    'Division One',
                  ),
                  value: office.divisionOneName ?? 'N/A',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  label: _fallbackLabel(
                    office.divisionTwoLabel,
                    'Division Two',
                  ),
                  value: office.divisionTwoName ?? 'N/A',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  label: _fallbackLabel(
                    office.divisionThreeLabel,
                    'Division Three',
                  ),
                  value: office.divisionThreeName ?? 'N/A',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showZipCodeInfoDialog(
    BuildContext context,
    PlaceZipCodeLink zip,
    String Function(DateTime?) formatDate,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final rows = <Widget>[
          _InfoRow(label: 'Created By', value: zip.createdUser ?? 'Unknown'),
          _InfoRow(label: 'Created Date', value: formatDate(zip.createdDate)),
        ];

        if (zip.modifiedUser != null || zip.modifiedDate != null) {
          rows.add(const SizedBox(height: 8));
          rows.add(
            _InfoRow(
              label: 'Modified By',
              value: zip.modifiedUser ?? 'Unknown',
            ),
          );
          rows.add(
            _InfoRow(
              label: 'Modified Date',
              value: formatDate(zip.modifiedDate),
            ),
          );
        }

        return AlertDialog(
          title: const Text('Zip Code Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _PostOfficeTile extends StatelessWidget {
  final PlacePostOffice office;
  final bool expanded;
  final void Function(bool expanded) onExpansionChanged;
  final void Function(PlacePostOffice office) onPostOfficeInfo;
  final void Function(PlaceZipCodeLink zip) onZipInfo;

  const _PostOfficeTile({
    required this.office,
    required this.expanded,
    required this.onExpansionChanged,
    required this.onPostOfficeInfo,
    required this.onZipInfo,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.blue,
              ),
              tooltip: 'Post office info',
              onPressed: () => onPostOfficeInfo(office),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        subtitle: Text(
          '${office.zipCodes.where((z) => z.active).length} zip codes',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          // Only show active zip codes for this post office
          if (office.zipCodes.where((z) => z.active).isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No active zip codes'),
            )
          else
            ...office.zipCodes
                .where((zip) => zip.active)
                .map(
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.blue,
                              ),
                              tooltip: 'Zip code info',
                              onPressed: () => onZipInfo(zip),
                            ),
                          ],
                        ),
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

    final hasModifiedUser =
        place.modifiedUser != null && place.modifiedUser!.trim().isNotEmpty;
    final hasModified = hasModifiedUser || place.modifiedDate != null;
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
