import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/data/models/place_model.dart';
import 'package:voice_first_admin/features/Place_management/data/models/place_requests.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/editPlaceFormProvider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/add_place_provider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/pages/add_more_zip_codes_page.dart';
import '../providers/place_provider.dart';

class EditPlacePage extends ConsumerStatefulWidget {
  final PlaceModel place;

  const EditPlacePage({super.key, required this.place});

  @override
  ConsumerState<EditPlacePage> createState() => _EditPlacePageState();
}

class _EditPlacePageState extends ConsumerState<EditPlacePage> {
  late TextEditingController _nameController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Always start with a fresh edit form state, but
    // delay the mutation until after the first frame
    Future.microtask(() {
      final notifier = ref.read(editPlaceFormProvider.notifier);
      notifier.reset();
      notifier.initializeFromPlace(widget.place);
    });
    _nameController = TextEditingController(text: widget.place.placeName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      _showSnack('Please enter a place name', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Use provider's diff logic
      final formNotifier = ref.read(editPlaceFormProvider.notifier);
      final diff = formNotifier.buildZipDiff(widget.place);

      debugPrint(
        '[EditPlacePage] updateZipCodes: ${diff.updateZipCodes.length}',
      );
      debugPrint('[EditPlacePage] insertZipIds: ${diff.insertZipIds.length}');

      // ⭐⭐⭐ ENTERPRISE DIFF CHECK
      final original = widget.place;

      final bool nameChanged =
          _nameController.text.trim() != original.placeName;

      final bool hasZipChanges =
          diff.updateZipCodes.isNotEmpty || diff.insertZipIds.isNotEmpty;

      if (!nameChanged && !hasZipChanges) {
        _showSnack('No changes detected', isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      final request = UpdatePlaceRequest(
        placeName: _nameController.text.trim(),
        updateZipCodeLinkIds: diff.updateZipCodes,
        insertZipCodeLinkIds: diff.insertZipIds,
      );

      debugPrint('[EditPlacePage] Payload: ${request.toJson()}');

      final notifier = ref.read(placeProvider.notifier);
      final success = await notifier.updatePlace(widget.place.placeId, request);

      if (!mounted) return;

      if (success) {
        _showSnack('Place updated successfully', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnack('Failed to update place', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  List<Widget> _buildGroupedZipCodeTiles(ThemeData theme) {
    final form = ref.watch(editPlaceFormProvider);
    final formNotifier = ref.read(editPlaceFormProvider.notifier);

    final Map<int, List<EditZipCodeItem>> grouped = {};

    for (final item in form.zipCodeItems) {
      grouped.putIfAbsent(item.postOfficeId, () => []).add(item);
    }

    if (grouped.isEmpty) return const [];

    return grouped.entries.map((entry) {
      final officeId = entry.key;
      final items = entry.value;
      final officeName = items.first.postOfficeName;

      final unlinkedAsync = ref.watch(
        unlinkedZipCodesProvider((
          postOfficeId: officeId,
          placeId: widget.place.placeId,
        )),
      );

      return unlinkedAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(8),
          child: LinearProgressIndicator(),
        ),
        error: (_, __) => const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Failed to load zipcodes'),
        ),
        data: (unlinkedZips) {
          // Get backend linked count
          int backendLinkedCount = 0;
          for (final office in widget.place.postOffices) {
            if (office.postOfficeId == officeId) {
              backendLinkedCount = office.zipCodes.length;
              break;
            }
          }

          final allLinked = formNotifier.isOfficeFullyLinked(
            officeId,
            backendLinkedCount,
            unlinkedZips.length,
          );

          final rows = <Widget>[];

          // Existing
          for (final item in items) {
            rows.add(_buildExistingZipRow(theme, item));
          }

          // Unlinked
          for (final zip in unlinkedZips) {
            if (!form.selectedZipIds.contains(zip.zipCodeLinkId)) {
              rows.add(_buildUnlinkedZipRow(theme, officeId, officeName, zip));
            }
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ExpansionTile(
              leading: Checkbox(
                value: allLinked,
                onChanged: (value) {
                  if (value == true) {
                    formNotifier.selectAllOffice(
                      officeId,
                      officeName,
                      unlinkedZips,
                    );
                  } else {
                    formNotifier.deselectOffice(officeId);
                  }
                },
              ),
              title: Text(
                officeName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${rows.length} zip codes'),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: rows,
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildExistingZipRow(ThemeData theme, EditZipCodeItem item) {
    final formNotifier = ref.read(editPlaceFormProvider.notifier);

    Color borderColor;

    if (item.isNew) {
      // NEW items never show orange
      borderColor = item.isActive ? Colors.green : theme.dividerColor;
    } else {
      // EXISTING items
      borderColor = item.isActive ? Colors.green : Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isActive,
            onChanged: (value) {
              if (value == null) return;
              formNotifier.toggleZip(item.zipCodeLinkId);
            },
          ),
          Expanded(
            child: Text(
              item.zipCode,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlinkedZipRow(
    ThemeData theme,
    int postOfficeId,
    String postOfficeName,
    ZipCodeLookup zip,
  ) {
    final formNotifier = ref.read(editPlaceFormProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor, width: 1.0),
      ),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {
              if (value != true) return;
              formNotifier.addNewZip(
                postOfficeId: postOfficeId,
                zipCodeLinkId: zip.zipCodeLinkId,
                zipCode: zip.zipCode,
                postOfficeName: postOfficeName,
              );
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zip.zipCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(postOfficeName, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    CustomSnackbar.show(
      context,
      message: msg,
      type: isError ? SnackBarType.error : SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = ref.watch(editPlaceFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Place'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FormLabel('Place Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter place name',
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 24),
            const _FormLabel('Zip Codes'),
            const SizedBox(height: 8),
            if (form.zipCodeItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('No zip codes linked')),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group zip codes by post office showing existing
                    // and unlinked zip codes for each office.
                    ..._buildGroupedZipCodeTiles(theme),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Add More Zip Codes Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddMoreZipCodesPage(placeId: widget.place.placeId),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add More Zip Codes'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );
  }
}
