import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/models/place_model.dart';
import 'package:voice_first_admin/features/Place_management/data/models/place_requests.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/editPlaceFormProvider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
import '../providers/place_provider.dart';

class EditPlacePage extends ConsumerStatefulWidget {
  final PlaceModel place;

  const EditPlacePage({super.key, required this.place});

  @override
  ConsumerState<EditPlacePage> createState() => _EditPlacePageState();
}

class _EditPlacePageState extends ConsumerState<EditPlacePage> {
  late TextEditingController _nameController;
  late List<_ZipCodeItem> _zipCodeItems;
  late Set<int> _selectedZipIds;

  bool _isSubmitting = false;

  @override
  // void initState() {
  //   super.initState();
  //   _nameController = TextEditingController(text: widget.place.placeName);
  //   // Initialize zip codes from all post offices
  //   _zipCodeItems = [];
  //   for (final office in widget.place.postOffices) {
  //     for (final zip in office.zipCodes) {
  //       _zipCodeItems.add(
  //         _ZipCodeItem(
  //           zipCodeLinkId: zip.zipCodeLinkId,
  //           zipCode: zip.zipCode,
  //           postOfficeName: office.postOfficeName,
  //           isActive: zip.active,
  //           isNew: false,
  //         ),
  //       );
  //     }
  //   }
  //   _selectedZipIds = _zipCodeItems.map((e) => e.zipCodeLinkId).toSet();
  // }
  void initState() {
    super.initState();
    // Always start with a fresh edit form state, but
    // delay the mutation until after the first frame
    Future.microtask(() {
      ref.read(editPlaceFormProvider.notifier).reset();
    });
    _nameController = TextEditingController(text: widget.place.placeName);

    _zipCodeItems = [];

    for (final office in widget.place.postOffices) {
      for (final zip in office.zipCodes) {
        _zipCodeItems.add(
          _ZipCodeItem(
            zipCodeLinkId: zip.zipCodeLinkId,
            zipCode: zip.zipCode,
            postOfficeName: office.postOfficeName,
            isActive: zip.active,
            isNew: false,
          ),
        );
      }
    }

    // ✅ PERFORMANCE BOOST
    _selectedZipIds = _zipCodeItems.map((e) => e.zipCodeLinkId).toSet();
  }

  @override
  void dispose() {
    // ref.read(editPlaceFormProvider.notifier).clear();
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
      // Build update zip code list (modified existing zips)
      final updateZipCodes = <ZipCodeLinkUpdate>[];
      final insertZipIds = <int>[];

      for (final item in _zipCodeItems) {
        // Find original state
        final originalItem = _findOriginalZip(item.zipCodeLinkId);

        if (item.isNew) {
          // New zip codes
          if (item.isActive) {
            insertZipIds.add(item.zipCodeLinkId);
          }
        } else {
          // Existing zip codes - track if status changed
          if (originalItem != null && originalItem.isActive != item.isActive) {
            updateZipCodes.add(
              ZipCodeLinkUpdate(
                zipCodeLinkId: item.zipCodeLinkId,
                active: item.isActive,
              ),
            );
          }
        }
      }

      debugPrint('[EditPlacePage] updateZipCodes: ${updateZipCodes.length}');
      debugPrint('[EditPlacePage] insertZipIds: ${insertZipIds.length}');

      // ⭐⭐⭐ ENTERPRISE DIFF CHECK
      final original = widget.place;

      final bool nameChanged =
          _nameController.text.trim() != original.placeName;

      final bool hasZipChanges =
          updateZipCodes.isNotEmpty || insertZipIds.isNotEmpty;

      if (!nameChanged && !hasZipChanges) {
        _showSnack('No changes detected', isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      final request = UpdatePlaceRequest(
        placeName: _nameController.text.trim(),
        updateZipCodeLinkIds: updateZipCodes,
        insertZipCodeLinkIds: insertZipIds,
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

  _ZipCodeItem? _findOriginalZip(int zipCodeLinkId) {
    for (final office in widget.place.postOffices) {
      for (final zip in office.zipCodes) {
        if (zip.zipCodeLinkId == zipCodeLinkId) {
          return _ZipCodeItem(
            zipCodeLinkId: zip.zipCodeLinkId,
            zipCode: zip.zipCode,
            postOfficeName: office.postOfficeName,
            isActive: zip.active,
            isNew: false,
          );
        }
      }
    }
    return null;
  }

  void _toggleZipCode(int zipCodeLinkId) {
    setState(() {
      final index = _zipCodeItems.indexWhere(
        (z) => z.zipCodeLinkId == zipCodeLinkId,
      );
      if (index >= 0) {
        _zipCodeItems[index].isActive = !_zipCodeItems[index].isActive;
      }
    });
  }

  // void _removeZipCode(int zipCodeLinkId) {
  //   setState(() {
  //     _zipCodeItems.removeWhere((z) => z.zipCodeLinkId == zipCodeLinkId);
  //   });
  // }
  void _removeZipCode(int zipCodeLinkId) {
    setState(() {
      _zipCodeItems.removeWhere((z) => z.zipCodeLinkId == zipCodeLinkId);

      _selectedZipIds.remove(zipCodeLinkId);
    });
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(
      postOfficeFilterForEditProvider(widget.place.placeId),
    );

    final postOfficesAsync = filter.isReady
        ? ref.watch(postOfficeLookupProvider(filter))
        : const AsyncValue.data([]);

    final theme = Theme.of(context);
    // ✅ WATCH EDIT FORM
    final form = ref.watch(editPlaceFormProvider);

    final notifier = ref.read(editPlaceFormProvider.notifier);

    // ✅ LOOKUPS
    final countriesAsync = ref.watch(countryLookupProvider);

    final divOneAsync = form.countryId == null
        ? null
        : ref.watch(divisionOneLookupProvider(form.countryId!));

    final divTwoAsync = form.divOneId == null
        ? null
        : ref.watch(divisionTwoLookupProvider(form.divOneId!));

    final divThreeAsync = form.divTwoId == null
        ? null
        : ref.watch(divisionThreeLookupProvider(form.divTwoId!));

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
            if (_zipCodeItems.isEmpty)
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
                  children: _zipCodeItems.map((item) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: item.isActive ? Colors.green : Colors.orange,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.zipCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.postOfficeName,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (item.isActive ? Colors.green : Colors.orange)
                                      .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: item.isActive
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'toggle') {
                                _toggleZipCode(item.zipCodeLinkId);
                              } else if (value == 'remove') {
                                _removeZipCode(item.zipCodeLinkId);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'toggle',
                                child: Text(
                                  item.isActive ? 'Deactivate' : 'Activate',
                                ),
                              ),
                              if (item.isNew)
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 32),
            const SizedBox(height: 24),
            const _FormLabel('Add Zip Codes'),
            const SizedBox(height: 8),

            // ================= COUNTRY =================
            countriesAsync.when(
              data: (countries) {
                final validValue = countries.any((c) => c.id == form.countryId)
                    ? form.countryId
                    : null;
                return DropdownButtonFormField<int>(
                  value: validValue,
                  decoration: const InputDecoration(labelText: 'Country'),
                  items: countries
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      notifier.setCountry(val);
                    }
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load countries'),
            ),

            const SizedBox(height: 12),

            // ================= DIVISION ONE =================
            if (divOneAsync != null)
              divOneAsync.when(
                data: (divs) {
                  final validValue = divs.any((d) => d.id == form.divOneId)
                      ? form.divOneId
                      : null;
                  return DropdownButtonFormField<int>(
                    value: validValue,
                    decoration: const InputDecoration(
                      labelText: 'State / Division 1',
                    ),
                    items: divs
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        notifier.setDivOne(val);
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load division'),
              ),

            const SizedBox(height: 12),

            // ================= DIVISION TWO =================
            if (divTwoAsync != null)
              divTwoAsync.when(
                data: (divs) {
                  final validValue = divs.any((d) => d.id == form.divTwoId)
                      ? form.divTwoId
                      : null;

                  return DropdownButtonFormField<int>(
                    value: validValue,
                    decoration: const InputDecoration(
                      labelText: 'District / Division 2',
                    ),
                    items: divs
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        notifier.setDivTwo(val);
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load division'),
              ),

            const SizedBox(height: 12),

            // ================= DIVISION THREE =================
            if (divThreeAsync != null)
              divThreeAsync.when(
                data: (divs) {
                  final validValue = divs.any((d) => d.id == form.divThreeId)
                      ? form.divThreeId
                      : null;
                  return DropdownButtonFormField<int>(
                    value: validValue,
                    decoration: const InputDecoration(
                      labelText: 'City / Division 3',
                    ),
                    items: divs
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) notifier.setDivThree(val);
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load division'),
              ),

            const SizedBox(height: 20),

            postOfficesAsync.when(
              data: (offices) {
                // if (!filter.isReady || offices.isEmpty) {
                //   return const SizedBox();
                // }
                if (!filter.isReady) {
                  return const SizedBox(); // show nothing
                }

                if (offices.isEmpty) {
                  return const Text('No zipcodes found for selected hierarchy');
                }

                return Card(
                  child: Column(
                    children: offices.map<Widget>((office) {
                      return ExpansionTile(
                        title: Text(office.postOfficeName),
                        children: office.zipCodes.map<Widget>((zip) {
                          final alreadyAdded = _selectedZipIds.contains(
                            zip.zipCodeLinkId,
                          );

                          return CheckboxListTile(
                            value: alreadyAdded,
                            title: Text(zip.zipCode),
                            onChanged: alreadyAdded
                                ? null
                                : (_) {
                                    setState(() {
                                      _zipCodeItems.add(
                                        _ZipCodeItem(
                                          zipCodeLinkId: zip.zipCodeLinkId,
                                          zipCode: zip.zipCode,
                                          postOfficeName: office.postOfficeName,
                                          isActive: true,
                                          isNew: true,
                                        ),
                                      );
                                      _selectedZipIds.add(zip.zipCodeLinkId);
                                    });
                                  },
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load zipcodes'),
            ),

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

class _ZipCodeItem {
  final int zipCodeLinkId;
  final String zipCode;
  final String postOfficeName;
  bool isActive;
  final bool isNew;

  _ZipCodeItem({
    required this.zipCodeLinkId,
    required this.zipCode,
    required this.postOfficeName,
    required this.isActive,
    required this.isNew,
  });
}
