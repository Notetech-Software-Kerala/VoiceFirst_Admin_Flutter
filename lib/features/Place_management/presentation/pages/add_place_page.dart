import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/add_place_provider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addPlaceFormProvider);
    final notifier = ref.read(addPlaceFormProvider.notifier);

    final filter = ref.watch(postOfficeFilterProvider);

    final countries = ref.watch(countryLookupProvider);

    // Resolve dynamic division labels based on selected country
    List<CountryLookup>? countryList;
    countries.when(
      data: (list) {
        countryList = list;
      },
      loading: () {},
      error: (_, _) {},
    );

    CountryLookup? selectedCountry;
    if (countryList != null && form.countryId != null) {
      for (final c in countryList!) {
        if (c.id == form.countryId) {
          selectedCountry = c;
          break;
        }
      }
    }

    String lableOrFallback
    (String? value, String fallback) {
      if (value == null) return fallback;
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }

    final div1Label = lableOrFallback
    (
      selectedCountry?.divisionOneLabel,
      'Division 1',
    );
    final div2Label = lableOrFallback
    (
      selectedCountry?.divisionTwoLabel,
      'Division 2',
    );
    final div3Label = lableOrFallback
    (
      selectedCountry?.divisionThreeLabel,
      'Division 3',
    );

    final divOne = form.countryId == null
        ? null
        : ref.watch(divisionOneLookupProvider(form.countryId!));

    final divTwo = form.divOneId == null
        ? null
        : ref.watch(divisionTwoLookupProvider(form.divOneId!));

    final divThree = form.divTwoId == null
        ? null
        : ref.watch(divisionThreeLookupProvider(form.divTwoId!));

    final postOfficesAsync = ref.watch(postOfficeLookupProvider(filter));

    return Scaffold(
      appBar: AppBar(title: const Text("Add Place")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// NAME
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

            const SizedBox(height: 16),

            /// COUNTRY
            countries.when(
              data: (list) => _dropdown(
                label: "Country",
                value: form.countryId,
                items: list
                    .map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
                    )
                    .toList(),
                onChanged: (v) => notifier.setCountry(v!),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text("Failed to load countries"),
            ),

            if (divOne != null)
              divOne.when(
                data: (list) => _dropdown(
                  label: div1Label,
                  value: form.divOneId,
                  items: list
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => notifier.setDivOne(v!),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text("Failed"),
              ),

            if (divTwo != null)
              divTwo.when(
                data: (list) => _dropdown(
                  label: div2Label,
                  value: form.divTwoId,
                  items: list
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => notifier.setDivTwo(v!),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text("Failed"),
              ),

            if (divThree != null)
              divThree.when(
                data: (list) => _dropdown(
                  label: div3Label,
                  value: form.divThreeId,
                  items: list
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => notifier.setDivThree(v!),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text("Failed"),
              ),

            const SizedBox(height: 24),

            /// POST OFFICES + ZIPCODES
            postOfficesAsync.when(
              data: (List<PostOfficeLookup> offices) {
                if (!filter.isReady || offices.isEmpty) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormLabel("Zip Codes"),
                    const SizedBox(height: 8),

                    /// GLOBAL SELECT
                    _GlobalSelectTile(offices: offices),

                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.withAlpha(30)),
                      ),
                      child: Column(
                        children: offices
                            .map((office) => _PostOfficeTile(office: office))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text("Failed to load post offices"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty || form.zipCodeIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fill all required fields")),
                    );
                    return;
                  }

                  final request = CreatePlaceRequest(
                    placeName: _nameController.text,
                    zipCodeLinkIds: form.zipCodeIds.toList(),
                  );

                  await ref.read(placeProvider.notifier).createPlace(request);

                  if (context.mounted) {
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

  Widget _dropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          hint: Text("Select $label"),
          items: items,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

/// ================= POST OFFICE TILE =================

class _PostOfficeTile extends ConsumerWidget {
  final PostOfficeLookup office;

  const _PostOfficeTile({required this.office});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPlaceFormProvider);
    final notifier = ref.read(addPlaceFormProvider.notifier);

    final zips = office.zipCodes;
    final ids = zips.map((e) => e.zipCodeLinkId).toList();

    final allSelected =
        ids.isNotEmpty && ids.every((id) => form.zipCodeIds.contains(id));

    return ExpansionTile(
      title: Text(office.postOfficeName),
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (allSelected) {
                    notifier.unselectAllZipCodes(ids);
                  } else {
                    notifier.selectAllZipCodes(ids);
                  }
                },
                child: Text(allSelected ? "Unselect All" : "Select All"),
              ),
            ),

            ...zips.map((zip) {
              final selected = form.zipCodeIds.contains(zip.zipCodeLinkId);

              return CheckboxListTile(
                value: selected,
                title: Text(zip.zipCode),
                onChanged: (_) => notifier.toggleZip(zip.zipCodeLinkId),
              );
            }),
          ],
        ),
      ],
    );
  }
}

/// ================= GLOBAL SELECT =================

class _GlobalSelectTile extends ConsumerWidget {
  final List<PostOfficeLookup> offices;

  const _GlobalSelectTile({required this.offices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPlaceFormProvider);
    final notifier = ref.read(addPlaceFormProvider.notifier);

    final allIds = <int>[];
    for (final office in offices) {
      allIds.addAll(office.zipCodes.map((e) => e.zipCodeLinkId));
    }

    final allSelected =
        allIds.isNotEmpty && allIds.every((id) => form.zipCodeIds.contains(id));

    return CheckboxListTile(
      title: const Text(
        "Select ALL Zip Codes",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      value: allSelected,
      onChanged: (_) async {
        if (allSelected) {
          notifier.unselectAllZipCodes(allIds);
        } else {
          notifier.selectAllZipCodes(allIds);
        }
      },
    );
  }
}

/// ================= LABEL =================

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
