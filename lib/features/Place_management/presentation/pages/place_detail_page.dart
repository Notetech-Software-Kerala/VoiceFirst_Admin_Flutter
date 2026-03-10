import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/Place_management/widgets/place_detail_widgets.dart';
import 'package:voice_first_admin/features/Place_management/widgets/place_post_office_tile.dart';
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
                        const Expanded(child: PlaceSectionLabel('PLACE NAME')),
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
                        const Expanded(child: PlaceSectionLabel('STATUS')),
                        const SizedBox(width: 12),
                        Text(
                          isDeleted
                              ? 'Deleted'
                              : (place.active ? 'Active' : 'Suspended'),
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
                            (office) => PlacePostOfficeTile(
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
                      PlaceHistorySection(place: place, formatDate: _fmtDate),
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
        String fallbackLabel(String? label, String fallback) {
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
                PlaceInfoRow(
                  label: 'Country Name',
                  value: office.countryName ?? 'Unknown',
                ),
                const SizedBox(height: 8),
                PlaceInfoRow(
                  label: fallbackLabel(office.divisionOneLabel, 'Division One'),
                  value: office.divisionOneName ?? 'N/A',
                ),
                const SizedBox(height: 4),
                PlaceInfoRow(
                  label: fallbackLabel(office.divisionTwoLabel, 'Division Two'),
                  value: office.divisionTwoName ?? 'N/A',
                ),
                const SizedBox(height: 4),
                PlaceInfoRow(
                  label: fallbackLabel(
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
          PlaceInfoRow(
            label: 'Created By',
            value: zip.createdUser ?? 'Unknown',
          ),
          PlaceInfoRow(
            label: 'Created Date',
            value: formatDate(zip.createdDate),
          ),
        ];

        if (zip.modifiedUser != null || zip.modifiedDate != null) {
          rows.add(const SizedBox(height: 8));
          rows.add(
            PlaceInfoRow(
              label: 'Modified By',
              value: zip.modifiedUser ?? 'Unknown',
            ),
          );
          rows.add(
            PlaceInfoRow(
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
