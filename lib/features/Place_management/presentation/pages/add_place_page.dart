import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/add_place_provider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
import 'package:voice_first_admin/features/Place_management/widgets/searchable_dropdown.dart';
import '../../data/models/lookup_models.dart';
import '../../data/models/place_requests.dart';
import '../providers/place_provider.dart';

class AddPlacePage extends ConsumerStatefulWidget {
  const AddPlacePage({super.key});

  @override
  ConsumerState<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends ConsumerState<AddPlacePage> {
  final _nameController = TextEditingController();
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Build grouped zip code summary by post office
  Widget _buildZipCodeSummary(ThemeData theme, List<PostOfficeLookup> offices) {
    final form = ref.watch(addPlaceFormProvider);

    if (form.zipCodeIds.isEmpty) {
      return const SizedBox();
    }

    // Build map of postOfficeId -> selected zips
    final Map<int, List<String>> groupedByOffice = {};
    final Map<int, String> officeNames = {};

    for (final office in offices) {
      officeNames[office.postOfficeId] = office.postOfficeName;
      final selectedZips = office.zipCodes
          .where((zip) => form.zipCodeIds.contains(zip.zipCodeLinkId))
          .map((zip) => zip.zipCode)
          .toList();

      if (selectedZips.isNotEmpty) {
        groupedByOffice[office.postOfficeId] = selectedZips;
      }
    }

    if (groupedByOffice.isEmpty) {
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
            "Selected Zip Codes",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...groupedByOffice.entries.map((entry) {
            final officeId = entry.key;
            final zips = entry.value;
            final officeName = officeNames[officeId] ?? "Unknown";

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    officeName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: zips
                        .map((zip) => Chip(label: Text(zip)))
                        .toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = ref.watch(addPlaceFormProvider);
    final notifier = ref.read(addPlaceFormProvider.notifier);
    final filter = ref.watch(postOfficeFilterProvider);

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

    final postOfficesAsync = ref.watch(postOfficeLookupProvider(filter));

    return Scaffold(
      appBar: AppBar(title: const Text("Add Place")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PLACE NAME
            const _FormLabel("Place Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Enter Place Name",
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            /// COUNTRY
            countriesAsync.when(
              data: (countries) {
                final selected = countries
                    .where((c) => c.id == form.countryId)
                    .cast<CountryLookup?>()
                    .firstOrNull;

                return SearchableDropdown<CountryLookup>(
                  label: "Country",
                  value: selected,
                  items: countries,
                  itemLabel: (c) => c.name,
                  itemId: (c) => c.id,
                  onChanged: (c) {
                    if (c != null) notifier.setCountry(c.id);
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Failed to load countries"),
            ),

            /// DIVISION 1
            if (divOneAsync != null)
              divOneAsync.when(
                data: (divs) {
                  final selected = divs
                      .where((d) => d.id == form.divOneId)
                      .cast<DivisionOneLookup?>()
                      .firstOrNull;

                  return SearchableDropdown<DivisionOneLookup>(
                    label: div1Label,
                    value: selected,
                    items: divs,
                    itemLabel: (d) => d.name,
                    itemId: (d) => d.id,
                    onChanged: (d) {
                      if (d != null) notifier.setDivOne(d.id);
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Failed"),
              ),

            /// DIVISION 2
            if (divTwoAsync != null)
              divTwoAsync.when(
                data: (divs) {
                  final selected = divs
                      .where((d) => d.id == form.divTwoId)
                      .cast<DivisionTwoLookup?>()
                      .firstOrNull;

                  return SearchableDropdown<DivisionTwoLookup>(
                    label: div2Label,
                    value: selected,
                    items: divs,
                    itemLabel: (d) => d.name,
                    itemId: (d) => d.id,
                    onChanged: (d) {
                      if (d != null) notifier.setDivTwo(d.id);
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Failed"),
              ),

            /// DIVISION 3
            if (divThreeAsync != null)
              divThreeAsync.when(
                data: (divs) {
                  final selected = divs
                      .where((d) => d.id == form.divThreeId)
                      .cast<DivisionThreeLookup?>()
                      .firstOrNull;

                  return SearchableDropdown<DivisionThreeLookup>(
                    label: div3Label,
                    value: selected,
                    items: divs,
                    itemLabel: (d) => d.name,
                    itemId: (d) => d.id,
                    onChanged: (d) {
                      if (d != null) notifier.setDivThree(d.id);
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Failed"),
              ),

            const SizedBox(height: 24),

            // ================= ZIP CODES SECTION =================
            const _FormLabel("Zip Codes"),
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
                if (!filter.isReady || offices.isEmpty) {
                  return const SizedBox();
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

                return Column(
                  children: [
                    Container(
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
                              subtitle: Text(
                                '${office.zipCodes.length} zip codes',
                              ),
                              children: office.zipCodes.map<Widget>((zip) {
                                final selected = form.zipCodeIds.contains(
                                  zip.zipCodeLinkId,
                                );

                                return CheckboxListTile(
                                  value: selected,
                                  title: Text(zip.zipCode),
                                  onChanged: (_) =>
                                      notifier.toggleZip(zip.zipCodeLinkId),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildZipCodeSummary(theme, offices),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Failed to load post offices"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty || form.zipCodeIds.isEmpty) {
                    CustomSnackbar.show(
                      context,
                      message: "Fill all required fields",
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  final request = CreatePlaceRequest(
                    placeName: _nameController.text,
                    zipCodeLinkIds: form.zipCodeIds.toList(),
                  );

                  await ref.read(placeProvider.notifier).createPlace(request);

                  if (context.mounted) {
                    CustomSnackbar.show(
                      context,
                      message: "Place created successfully",
                      type: SnackBarType.success,
                    );
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Save Place"),
              ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
