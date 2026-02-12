import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/data/models/post_office_lookup_filter.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
import '../providers/add_place_provider.dart';

class AddPlacePage extends ConsumerStatefulWidget {
  const AddPlacePage({super.key});

  @override
  ConsumerState<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends ConsumerState<AddPlacePage> {
  final TextEditingController _nameController = TextEditingController();

  CountryLookup? selectedCountry;
  DivisionOneLookup? selectedDiv1;
  DivisionTwoLookup? selectedDiv2;
  DivisionThreeLookup? selectedDiv3;
  PostOfficeLookup? selectedOffice;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final addState = ref.watch(addPlaceProvider);
    final notifier = ref.read(addPlaceProvider.notifier);

    /// LOOKUPS
    final countryAsync = ref.watch(countryLookupProvider);

    final div1Async = selectedCountry == null
        ? null
        : ref.watch(divisionOneLookupProvider(selectedCountry!.id));

    final div2Async = selectedDiv1 == null
        ? null
        : ref.watch(divisionTwoLookupProvider(selectedDiv1!.id));

    final div3Async = selectedDiv2 == null
        ? null
        : ref.watch(divisionThreeLookupProvider(selectedDiv2!.id));

    /// FILTER (Equatable)
    final filter = PostOfficeLookupFilter(
      countryId: selectedCountry?.id,
      divOneId: selectedDiv1?.id,
      divTwoId: selectedDiv2?.id,
      divThreeId: selectedDiv3?.id,
    );

    final officesAsync = filter.isReady
        ? ref.watch(postOfficeLookupProvider(filter))
        : null;

    final zipAsync = selectedOffice != null
        ? ref.watch(zipCodeLookupProvider(selectedOffice!.id))
        : null;

    return StandardPageLayout(
      title: "Add Place",
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              /// PLACE NAME
              _card(
                theme,
                TextField(
                  controller: _nameController,
                  onChanged: notifier.setName,
                  decoration: const InputDecoration(labelText: "Place Name"),
                ),
              ),

              const SizedBox(height: 16),

              /// COUNTRY
              _card(
                theme,
                countryAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Text("Failed to load countries"),
                  data: (countries) => DropdownButtonFormField<CountryLookup>(
                    initialValue: selectedCountry,
                    hint: const Text("Select Country"),
                    items: countries
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCountry = val;

                        /// RESET CASCADE
                        selectedDiv1 = null;
                        selectedDiv2 = null;
                        selectedDiv3 = null;
                        selectedOffice = null;
                      });

                      notifier.clearZips();
                    },
                  ),
                ),
              ),

              /// DIVISION 1
              if (div1Async != null) ...[
                const SizedBox(height: 16),
                _card(
                  theme,
                  div1Async.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text("Failed to load Division 1"),
                    data: (divisions) {
                      if (divisions.isEmpty) {
                        return const Text("No divisions found");
                      }

                      return DropdownButtonFormField<DivisionOneLookup>(
                        initialValue: selectedDiv1,
                        hint: const Text("Select Division 1"),
                        items: divisions
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDiv1 = val;

                            /// RESET BELOW
                            selectedDiv2 = null;
                            selectedDiv3 = null;
                            selectedOffice = null;
                          });

                          notifier.clearZips();
                        },
                      );
                    },
                  ),
                ),
              ],

              /// DIVISION 2
              if (div2Async != null) ...[
                const SizedBox(height: 16),
                _card(
                  theme,
                  div2Async.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text("Failed to load Division 2"),
                    data: (divisions) {
                      if (divisions.isEmpty) {
                        return const Text("No divisions found");
                      }

                      return DropdownButtonFormField<DivisionTwoLookup>(
                        initialValue: selectedDiv2,
                        hint: const Text("Select Division 2"),
                        items: divisions
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDiv2 = val;

                            selectedDiv3 = null;
                            selectedOffice = null;
                          });

                          notifier.clearZips();
                        },
                      );
                    },
                  ),
                ),
              ],

              /// DIVISION 3
              if (div3Async != null) ...[
                const SizedBox(height: 16),
                _card(
                  theme,
                  div3Async.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text("Failed to load Division 3"),
                    data: (divisions) {
                      if (divisions.isEmpty) {
                        return const Text("No divisions found");
                      }

                      return DropdownButtonFormField<DivisionThreeLookup>(
                        initialValue: selectedDiv3,
                        hint: const Text("Select Division 3"),
                        items: divisions
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDiv3 = val;
                            selectedOffice = null;
                          });

                          notifier.clearZips();
                        },
                      );
                    },
                  ),
                ),
              ],

              /// POST OFFICES
              if (officesAsync != null) ...[
                const SizedBox(height: 16),
                _card(
                  theme,
                  officesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text("Failed to load post offices"),
                    data: (offices) {
                      if (offices.isEmpty) {
                        return const Text("No post offices found");
                      }

                      return DropdownButtonFormField<PostOfficeLookup>(
                        initialValue: selectedOffice,
                        hint: const Text("Select Post Office"),
                        items: offices
                            .map(
                              (o) => DropdownMenuItem(
                                value: o,
                                child: Text(o.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedOffice = val);
                          notifier.clearZips();
                        },
                      );
                    },
                  ),
                ),
              ],

              /// ZIP CODES
              if (zipAsync != null) ...[
                const SizedBox(height: 16),
                _card(
                  theme,
                  zipAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text("Failed to load zip codes"),
                    data: (zips) {
                      if (zips.isEmpty) {
                        return const Text("No zip codes");
                      }

                      return Column(
                        children: zips.map((zip) {
                          final selected = addState.selectedZipCodes.any(
                            (z) => z.zipCodeLinkId == zip.zipCodeLinkId,
                          );

                          return CheckboxListTile(
                            value: selected,
                            title: Text(zip.zipCode),
                            onChanged: (checked) {
                              final sel = SelectedZipCodeLink(
                                zipCodeLinkId: zip.zipCodeLinkId,
                                label:
                                    "${zip.zipCode} • ${selectedOffice!.name}",
                              );

                              checked == true
                                  ? notifier.addZip(sel)
                                  : notifier.removeZip(zip.zipCodeLinkId);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              /// ERROR
              if (addState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    addState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              /// SUBMIT BUTTON
              ElevatedButton(
                onPressed: addState.isSubmitting
                    ? null
                    : () async {
                        final result = await notifier.submit();

                        if (result != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Place created successfully"),
                            ),
                          );

                          Navigator.pop(context);
                        }
                      },
                child: addState.isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text("Create Place"),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _card(ThemeData theme, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }
}
