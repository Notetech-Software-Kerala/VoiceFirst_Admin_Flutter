import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/add_place_provider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/editPlaceFormProvider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
import 'package:voice_first_admin/features/Place_management/widgets/searchable_dropdown.dart';

class AddMoreZipCodesPage extends ConsumerStatefulWidget {
  final int placeId;

  const AddMoreZipCodesPage({super.key, required this.placeId});

  @override
  ConsumerState<AddMoreZipCodesPage> createState() =>
      _AddMoreZipCodesPageState();
}

class _AddMoreZipCodesPageState extends ConsumerState<AddMoreZipCodesPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // 🔥 Clear only hierarchy when entering page
    Future.microtask(() {
      ref.read(editPlaceFormProvider.notifier).clearHierarchy();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildActiveZipSummary(ThemeData theme) {
    final form = ref.watch(editPlaceFormProvider);
    final activeItems = form.zipCodeItems.where((z) => z.isActive).toList();

    if (activeItems.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selected Zip Codes Summary",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Total Selected: ${activeItems.length}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: activeItems
                .map((z) => Chip(label: Text(z.zipCode)))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(postOfficeFilterForEditProvider(widget.placeId));

    final postOfficesAsync = filter.isReady
        ? ref.watch(postOfficeLookupProvider(filter))
        : const AsyncValue<List<PostOfficeLookup>>.data(<PostOfficeLookup>[]);

    final theme = Theme.of(context);
    final form = ref.watch(editPlaceFormProvider);
    final notifier = ref.read(editPlaceFormProvider.notifier);

    // ✅ LOOKUPS
    final countriesAsync = ref.watch(countryLookupProvider);
    CountryLookup? selectedCountry;

    countriesAsync.when(
      data: (countries) {
        for (final c in countries) {
          if (c.id == form.countryId) {
            selectedCountry = c;
            break;
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    String resolveLabel(String? label, String fallback) {
      if (label == null) return fallback;
      final trimmed = label.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }

    final div1Label = resolveLabel(
      selectedCountry?.divisionOneLabel,
      "Division 1",
    );

    final div2Label = resolveLabel(
      selectedCountry?.divisionTwoLabel,
      "Division 2",
    );

    final div3Label = resolveLabel(
      selectedCountry?.divisionThreeLabel,
      "Division 3",
    );

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
      appBar: AppBar(
        title: const Text('Add More Zip Codes'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SUMMARY CARD AT TOP =================
            _buildActiveZipSummary(theme),

            const _FormLabel('Select Hierarchy'),
            const SizedBox(height: 8),

            // ================= COUNTRY =================
            countriesAsync.when(
              data: (countries) {
                CountryLookup? selected;

                for (final c in countries) {
                  if (c.id == form.countryId) {
                    selected = c;
                    break;
                  }
                }

                return SearchableDropdown<CountryLookup>(
                  label: "Country",
                  value: selected,
                  items: countries,
                  itemLabel: (c) => c.name,
                  itemId: (c) => c.id,
                  onChanged: (c) {
                    if (c != null) {
                      notifier.setCountry(c.id);
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
                  DivisionOneLookup? selected;

                  for (final d in divs) {
                    if (d.id == form.divOneId) {
                      selected = d;
                      break;
                    }
                  }

                  return SearchableDropdown<DivisionOneLookup>(
                    label: div1Label,
                    value: selected,
                    items: divs,
                    itemLabel: (d) => d.name,
                    itemId: (d) => d.id,
                    onChanged: (d) {
                      if (d != null) {
                        notifier.setDivOne(d.id);
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
                  DivisionTwoLookup? selected;

                  for (final d in divs) {
                    if (d.id == form.divTwoId) {
                      selected = d;
                      break;
                    }
                  }

                  return SearchableDropdown<DivisionTwoLookup>(
                    label: div2Label,
                    value: selected,
                    items: divs,
                    itemLabel: (d) => d.name,
                    itemId: (d) => d.id,
                    onChanged: (d) {
                      if (d != null) {
                        notifier.setDivTwo(d.id);
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
                  DivisionThreeLookup? selected;

                  for (final d in divs) {
                    if (d.id == form.divThreeId) {
                      selected = d;
                      break;
                    }
                  }

                  return SearchableDropdown<DivisionThreeLookup>(
                    label: div3Label,
                    value: selected,
                    items: divs,
                    itemLabel: (d) => d.name,
                    itemId: (d) => d.id,
                    onChanged: (d) {
                      if (d != null) {
                        notifier.setDivThree(d.id);
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load division'),
              ),

            const SizedBox(height: 24),

            // ================= AVAILABLE POST OFFICES =================
            const _FormLabel('Available Post Offices'),
            const SizedBox(height: 12),

            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search post offices...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for filtering
              },
            ),

            const SizedBox(height: 12),

            // Scrollable Post Office List
            postOfficesAsync.when(
              data: (offices) {
                if (!filter.isReady) {
                  return const SizedBox();
                }

                if (offices.isEmpty) {
                  return const Text('No zipcodes found for selected hierarchy');
                }

                // Filter offices based on search query
                final searchQuery = _searchController.text.toLowerCase().trim();
                final filteredOffices = searchQuery.isEmpty
                    ? offices
                    : offices
                          .where(
                            (office) => office.postOfficeName
                                .toLowerCase()
                                .contains(searchQuery),
                          )
                          .toList();

                if (filteredOffices.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'No post offices match your search',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  );
                }

                return Container(
                  height: 400, // Fixed height for scrollable area
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: filteredOffices.length,
                    itemBuilder: (context, index) {
                      final office = filteredOffices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          title: Text(office.postOfficeName),
                          subtitle: Text('${office.zipCodes.length} zip codes'),
                          children: office.zipCodes.map<Widget>((zip) {
                            final alreadyAdded = form.selectedZipIds.contains(
                              zip.zipCodeLinkId,
                            );

                            return CheckboxListTile(
                              value: alreadyAdded,
                              title: Text(zip.zipCode),
                              onChanged: alreadyAdded
                                  ? null
                                  : (_) {
                                      notifier.addNewZip(
                                        postOfficeId: office.postOfficeId,
                                        zipCodeLinkId: zip.zipCodeLinkId,
                                        zipCode: zip.zipCode,
                                        postOfficeName: office.postOfficeName,
                                      );
                                    },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load zipcodes'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Done'),
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
