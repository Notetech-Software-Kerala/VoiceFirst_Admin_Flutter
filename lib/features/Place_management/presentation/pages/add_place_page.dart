import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/add_place_provider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
import '../../data/models/lookup_models.dart';
import '../../data/models/place_requests.dart';
import '../providers/place_provider.dart';
import '../providers/lookup/enterprise_lookup_providers.dart';

class AddPlacePage extends ConsumerStatefulWidget {
  const AddPlacePage({super.key});

  @override
  ConsumerState<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends ConsumerState<AddPlacePage> {
  final _nameController = TextEditingController();

  int _postOfficePage = 1;

  bool _isCountryOpen = false;

  final TextEditingController _countrySearchController =
      TextEditingController();

  final ScrollController _countryScrollController = ScrollController();

  Timer? _countryDebounce;

  bool _isDivisionOneOpen = false;

  final TextEditingController _divisionOneSearchController =
      TextEditingController();

  final ScrollController _divisionOneScrollController = ScrollController();

  Timer? _divisionOneDebounce;

  bool _isPostOfficeOpen = false;

  final TextEditingController _postOfficeSearchController =
      TextEditingController();

  final ScrollController _postOfficeScrollController = ScrollController();

  Timer? _postOfficeDebounce;

  bool _isDivisionTwoOpen = false;

  final TextEditingController _divisionTwoSearchController =
      TextEditingController();

  final ScrollController _divisionTwoScrollController = ScrollController();

  Timer? _divisionTwoDebounce;

  bool _isDivisionThreeOpen = false;
  final TextEditingController _divisionThreeSearchController =
      TextEditingController();
  final ScrollController _divisionThreeScrollController = ScrollController();
  Timer? _divisionThreeDebounce;

  @override
  void initState() {
    super.initState();

    _countryScrollController.addListener(() {
      final lookupState = ref.read(countryLookupProvider);

      if (lookupState.value == null) return;

      final state = lookupState.value!;

      if (_countryScrollController.position.extentAfter < 200 &&
          !state.isLoading &&
          state.hasMore) {
        ref.read(countryLookupProvider.notifier).loadNextPage();
      }
    });

    _divisionOneScrollController.addListener(() {
      // final lookupState = ref.read(divisionOneLookupProvider);
      final form = ref.read(addPlaceFormProvider);
      if (form.countryId == null) return;

      final lookupState = ref.read(divisionOneLookupProvider(form.countryId!));

      if (lookupState.value == null) return;

      final state = lookupState.value!;

      if (_divisionOneScrollController.position.extentAfter < 200 &&
          !state.isLoading &&
          state.hasMore) {
        // ref.read(divisionOneLookupProvider.notifier).loadNextPage();
        ref
            .read(divisionOneLookupProvider(form.countryId!).notifier)
            .loadNextPage();
      }
    });

    _divisionTwoScrollController.addListener(() {
      // final lookupState = ref.read(divisionTwoLookupProvider);
      final form = ref.read(addPlaceFormProvider);
      if (form.divOneId == null) return;

      final lookupState = ref.read(divisionTwoLookupProvider(form.divOneId!));
      if (lookupState.value == null) return;

      final state = lookupState.value!;

      if (_divisionTwoScrollController.position.extentAfter < 200 &&
          !state.isLoading &&
          state.hasMore) {
        // ref.read(divisionTwoLookupProvider.notifier).loadNextPage();
        ref
            .read(divisionTwoLookupProvider(form.divOneId!).notifier)
            .loadNextPage();
      }
    });

    _divisionThreeScrollController.addListener(() {
      // final lookupState = ref.read(divisionThreeLookupProvider);
      final form = ref.read(addPlaceFormProvider);
      if (form.divTwoId == null) return;

      final lookupState = ref.read(divisionThreeLookupProvider(form.divTwoId!));

      if (lookupState.value == null) return;

      final state = lookupState.value!;

      if (_divisionThreeScrollController.position.extentAfter < 200 &&
          !state.isLoading &&
          state.hasMore) {
        ref
            .read(divisionThreeLookupProvider(form.divTwoId!).notifier)
            .loadNextPage();
      }
    });

    _postOfficeScrollController.addListener(() {
      final lookupState = ref.read(
        postOfficeLookupProvider((
          ref.read(postOfficeFilterProvider),
          _postOfficePage,
          _postOfficeSearchController.text.trim(),
        )),
      );

      if (lookupState.value == null) return;

      final state = lookupState.value!;

      if (_postOfficeScrollController.position.extentAfter < 200 &&
          state.currentPage < state.totalPages) {
        setState(() {
          _postOfficePage++;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _postOfficeSearchController.dispose();
    // _scrollController.dispose();
    _countrySearchController.dispose();
    _countryScrollController.dispose();
    _countryDebounce?.cancel();
    _divisionOneSearchController.dispose();
    _divisionOneScrollController.dispose();
    _divisionOneDebounce?.cancel();
    _divisionTwoSearchController.dispose();
    _divisionTwoScrollController.dispose();
    _divisionTwoDebounce?.cancel();
    _divisionThreeSearchController.dispose();
    _divisionThreeScrollController.dispose();
    _divisionThreeDebounce?.cancel();
    _postOfficeDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final form = ref.watch(addPlaceFormProvider);
    // final filter = ref.watch(postOfficeFilterProvider);

    // final postOfficeAsync = ref.watch(
    //   postOfficeLookupProvider((
    //     filter,
    //     _postOfficePage,
    //     _postOfficeSearchController.text.trim(),
    //   )),
    // );

    return Scaffold(
      appBar: AppBar(title: const Text("Add Place")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(),

            const SizedBox(height: 20),

            const _FormLabel("Country"),
            const SizedBox(height: 8),

            InkWell(
              onTap: () {
                setState(() {
                  _isCountryOpen = !_isCountryOpen;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      form.countryId == null
                          ? "Select country"
                          : ref
                                    .watch(countryLookupProvider)
                                    .value
                                    ?.items
                                    .firstWhere(
                                      (c) => c.id == form.countryId,
                                      orElse: () =>
                                          CountryLookup(id: 0, name: ''),
                                    )
                                    .name ??
                                "Select country",
                    ),
                    Icon(
                      _isCountryOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isCountryOpen
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            /// SEARCH
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                controller: _countrySearchController,
                                onChanged: (value) {
                                  _countryDebounce?.cancel();

                                  _countryDebounce = Timer(
                                    const Duration(milliseconds: 400),
                                    () {
                                      ref
                                          .read(countryLookupProvider.notifier)
                                          .search(value.trim());
                                    },
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: "Search country...",
                                  prefixIcon: const Icon(Icons.search),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            /// LIST
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final lookupAsync = ref.watch(
                                    countryLookupProvider,
                                  );

                                  return lookupAsync.when(
                                    loading: () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    error: (_, _) => const Center(
                                      child: Text("Failed to load countries"),
                                    ),
                                    data: (state) {
                                      return Stack(
                                        children: [
                                          Scrollbar(
                                            thumbVisibility: true,
                                            controller:
                                                _countryScrollController,
                                            child: ListView.builder(
                                              controller:
                                                  _countryScrollController,
                                              itemCount: state.items.length,
                                              itemBuilder: (context, index) {
                                                final country =
                                                    state.items[index];

                                                final isSelected =
                                                    form.countryId ==
                                                    country.id;

                                                return ListTile(
                                                  title: Text(country.name),
                                                  trailing: isSelected
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                        )
                                                      : null,

                                                  onTap: () {
                                                    final previousCountryId =
                                                        form.countryId;

                                                    ref
                                                        .read(
                                                          addPlaceFormProvider
                                                              .notifier,
                                                        )
                                                        .setCountry(country.id);

                                                    // 🔥 Invalidate old Division providers
                                                    if (previousCountryId !=
                                                        null) {
                                                      ref.invalidate(
                                                        divisionOneLookupProvider(
                                                          previousCountryId,
                                                        ),
                                                      );
                                                    }

                                                    ref.invalidate(
                                                      divisionTwoLookupProvider,
                                                    );
                                                    ref.invalidate(
                                                      divisionThreeLookupProvider,
                                                    );

                                                    setState(() {
                                                      _isCountryOpen = false;
                                                      _isDivisionOneOpen =
                                                          false;
                                                      _isDivisionTwoOpen =
                                                          false;
                                                      _isDivisionThreeOpen =
                                                          false;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),

                                          if (state.isLoading)
                                            const Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: LinearProgressIndicator(
                                                minHeight: 2,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),

            if (form.countryId != null) ...[
              const SizedBox(height: 20),
              const _FormLabel("Division 1"),
              const SizedBox(height: 8),

              InkWell(
                onTap: () {
                  setState(() {
                    _isDivisionOneOpen = !_isDivisionOneOpen;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        form.divOneId == null
                            ? "Select division"
                            : ref
                                      .watch(
                                        divisionOneLookupProvider(
                                          form.countryId!,
                                        ),
                                      )
                                      .value
                                      ?.items
                                      .firstWhere(
                                        (d) => d.id == form.divOneId,
                                        orElse: () =>
                                            DivisionOneLookup(id: 0, name: ''),
                                      )
                                      .name ??
                                  "Select division",
                      ),
                      Icon(
                        _isDivisionOneOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isDivisionOneOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 350),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              /// SEARCH
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _divisionOneSearchController,
                                  onChanged: (value) {
                                    _divisionOneDebounce?.cancel();

                                    _divisionOneDebounce = Timer(
                                      const Duration(milliseconds: 400),
                                      () {
                                        ref
                                            .read(
                                              divisionOneLookupProvider(
                                                form.countryId!,
                                              ).notifier,
                                            )
                                            .search(value.trim());
                                      },
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Search division...",
                                    prefixIcon: const Icon(Icons.search),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),

                              /// LIST
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final lookupAsync = ref.watch(
                                      divisionOneLookupProvider(
                                        form.countryId!,
                                      ),
                                    );

                                    return lookupAsync.when(
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      error: (_, __) => const Center(
                                        child: Text("Failed to load divisions"),
                                      ),
                                      data: (state) {
                                        return Stack(
                                          children: [
                                            Scrollbar(
                                              thumbVisibility: true,
                                              controller:
                                                  _divisionOneScrollController,
                                              child: ListView.builder(
                                                controller:
                                                    _divisionOneScrollController,
                                                itemCount: state.items.length,
                                                itemBuilder: (context, index) {
                                                  final division =
                                                      state.items[index];

                                                  final isSelected =
                                                      form.divOneId ==
                                                      division.id;

                                                  return ListTile(
                                                    title: Text(division.name),
                                                    trailing: isSelected
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.green,
                                                          )
                                                        : null,

                                                    onTap: () {
                                                      final previousDivOneId =
                                                          form.divOneId;

                                                      ref
                                                          .read(
                                                            addPlaceFormProvider
                                                                .notifier,
                                                          )
                                                          .setDivOne(
                                                            division.id,
                                                          );

                                                      if (previousDivOneId !=
                                                          null) {
                                                        ref.invalidate(
                                                          divisionTwoLookupProvider(
                                                            previousDivOneId,
                                                          ),
                                                        );
                                                      }

                                                      ref.invalidate(
                                                        divisionThreeLookupProvider,
                                                      );

                                                      setState(() {
                                                        _isDivisionOneOpen =
                                                            false;
                                                        _isDivisionTwoOpen =
                                                            false;
                                                        _isDivisionThreeOpen =
                                                            false;
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),

                                            if (state.isLoading)
                                              const Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: LinearProgressIndicator(
                                                  minHeight: 2,
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],

            if (form.divOneId != null) ...[
              const SizedBox(height: 20),
              const _FormLabel("Division 2"),
              const SizedBox(height: 8),

              InkWell(
                onTap: () {
                  setState(() {
                    _isDivisionTwoOpen = !_isDivisionTwoOpen;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        form.divTwoId == null
                            ? "Select division"
                            : ref
                                      .watch(
                                        divisionTwoLookupProvider(
                                          form.divOneId!,
                                        ),
                                      )
                                      .value
                                      ?.items
                                      .firstWhere(
                                        (d) => d.id == form.divTwoId,
                                        orElse: () =>
                                            DivisionTwoLookup(id: 0, name: ''),
                                      )
                                      .name ??
                                  "Select division",
                      ),
                      Icon(
                        _isDivisionTwoOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isDivisionTwoOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 350),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              /// SEARCH
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _divisionTwoSearchController,
                                  onChanged: (value) {
                                    _divisionTwoDebounce?.cancel();

                                    _divisionTwoDebounce = Timer(
                                      const Duration(milliseconds: 400),
                                      () {
                                        ref
                                            .read(
                                              divisionTwoLookupProvider(
                                                form.divOneId!,
                                              ).notifier,
                                            )
                                            .search(value.trim());
                                      },
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Search division...",
                                    prefixIcon: const Icon(Icons.search),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),

                              /// LIST
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final lookupAsync = ref.watch(
                                      divisionTwoLookupProvider(form.divOneId!),
                                    );

                                    return lookupAsync.when(
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      error: (_, __) => const Center(
                                        child: Text("Failed to load divisions"),
                                      ),
                                      data: (state) {
                                        return Stack(
                                          children: [
                                            Scrollbar(
                                              thumbVisibility: true,
                                              controller:
                                                  _divisionTwoScrollController,
                                              child: ListView.builder(
                                                controller:
                                                    _divisionTwoScrollController,
                                                itemCount: state.items.length,
                                                itemBuilder: (context, index) {
                                                  final division =
                                                      state.items[index];

                                                  final isSelected =
                                                      form.divTwoId ==
                                                      division.id;

                                                  return ListTile(
                                                    title: Text(division.name),
                                                    trailing: isSelected
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.green,
                                                          )
                                                        : null,

                                                    onTap: () {
                                                      final previousDivTwoId =
                                                          form.divTwoId;

                                                      ref
                                                          .read(
                                                            addPlaceFormProvider
                                                                .notifier,
                                                          )
                                                          .setDivTwo(
                                                            division.id,
                                                          );

                                                      if (previousDivTwoId !=
                                                          null) {
                                                        ref.invalidate(
                                                          divisionThreeLookupProvider(
                                                            previousDivTwoId,
                                                          ),
                                                        );
                                                      }

                                                      setState(() {
                                                        _isDivisionTwoOpen =
                                                            false;
                                                        _isDivisionThreeOpen =
                                                            false;
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),

                                            if (state.isLoading)
                                              const Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: LinearProgressIndicator(
                                                  minHeight: 2,
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],

            if (form.divTwoId != null) ...[
              const SizedBox(height: 20),
              const _FormLabel("Division 3"),
              const SizedBox(height: 8),

              InkWell(
                onTap: () {
                  setState(() {
                    _isDivisionThreeOpen = !_isDivisionThreeOpen;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        form.divThreeId == null
                            ? "Select division"
                            : ref
                                      .watch(
                                        divisionThreeLookupProvider(
                                          form.divTwoId!,
                                        ),
                                      )
                                      .value
                                      ?.items
                                      .firstWhere(
                                        (d) => d.id == form.divThreeId,
                                        orElse: () => DivisionThreeLookup(
                                          id: 0,
                                          name: '',
                                        ),
                                      )
                                      .name ??
                                  "Select division",
                      ),
                      Icon(
                        _isDivisionThreeOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isDivisionThreeOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 350),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _divisionThreeSearchController,
                                  onChanged: (value) {
                                    _divisionThreeDebounce?.cancel();
                                    _divisionThreeDebounce = Timer(
                                      const Duration(milliseconds: 400),
                                      () {
                                        ref
                                            .read(
                                              divisionThreeLookupProvider(
                                                form.divTwoId!,
                                              ).notifier,
                                            )
                                            .search(value.trim());
                                      },
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Search division...",
                                    prefixIcon: const Icon(Icons.search),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final lookupAsync = ref.watch(
                                      divisionThreeLookupProvider(
                                        form.divTwoId!,
                                      ),
                                    );

                                    return lookupAsync.when(
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      error: (_, _) => const Center(
                                        child: Text("Failed to load"),
                                      ),
                                      data: (state) {
                                        return ListView.builder(
                                          controller:
                                              _divisionThreeScrollController,
                                          itemCount: state.items.length,
                                          itemBuilder: (context, index) {
                                            final division = state.items[index];

                                            final isSelected =
                                                form.divThreeId == division.id;

                                            return ListTile(
                                              title: Text(division.name),
                                              trailing: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    )
                                                  : null,
                                              onTap: () {
                                                ref
                                                    .read(
                                                      addPlaceFormProvider
                                                          .notifier,
                                                    )
                                                    .setDivThree(division.id);

                                                setState(() {
                                                  _isDivisionThreeOpen = false;
                                                });
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],

            // const SizedBox(height: 12),
            const SizedBox(height: 20),
            _buildPostOfficeDropdown(),
            _buildSelectedZipSummary(),

            _buildSaveButton(form),
          ],
        ),
      ),
    );
  }

  

  Widget _buildTextField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "Place Name",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPostOfficeDropdown() {
    final theme = Theme.of(context);
    final filter = ref.watch(postOfficeFilterProvider);

    if (!filter.isReady) return const SizedBox();

    final postOfficeAsync = ref.watch(
      postOfficeLookupProvider((
        filter,
        _postOfficePage,
        _postOfficeSearchController.text.trim(),
      )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormLabel("Post Offices"),
        const SizedBox(height: 8),

        InkWell(
          onTap: () {
            setState(() {
              _isPostOfficeOpen = !_isPostOfficeOpen;
              if (_isPostOfficeOpen) {
                _postOfficePage = 1;
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Post Offices"),
                Icon(
                  _isPostOfficeOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _isPostOfficeOpen
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        /// SEARCH
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _postOfficeSearchController,
                            onChanged: (value) {
                              _postOfficeDebounce?.cancel();
                              _postOfficeDebounce = Timer(
                                const Duration(milliseconds: 400),
                                () {
                                  setState(() {
                                    _postOfficePage = 1;
                                  });
                                },
                              );
                            },
                            decoration: InputDecoration(
                              hintText: "Search post offices...",
                              prefixIcon: const Icon(Icons.search),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        /// LIST
                        Expanded(
                          child: postOfficeAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, __) =>
                                const Center(child: Text("Error loading")),
                            data: (response) {
                              return ListView.builder(
                                controller: _postOfficeScrollController,
                                itemCount: response.items.length,
                                itemBuilder: (context, index) {
                                  final office = response.items[index];

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: ExpansionTile(
                                      title: Text(office.postOfficeName),
                                      children: [
                                        _ZipList(officeId: office.postOfficeId),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  // Widget _buildSelectedZipSummary() {}
  Widget _buildSelectedZipSummary() {
    final form = ref.watch(addPlaceFormProvider);

    if (form.zipCodeIds.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _FormLabel("Selected Zip Codes"),
            Text(
              "${form.zipCodeIds.length} selected",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Consumer(
          builder: (context, ref, _) {
            final filter = ref.watch(postOfficeFilterProvider);

            if (!filter.isReady) return const SizedBox();

            final postOfficeAsync = ref.watch(
              postOfficeLookupProvider((filter, 1, "")),
            );

            return postOfficeAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (response) {
                final offices = response.items;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: offices.map((office) {
                    return _EnterpriseOfficeSummary(
                      officeId: office.postOfficeId,
                      officeName: office.postOfficeName,
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(AddPlaceFormState form) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (_nameController.text.isEmpty || form.zipCodeIds.isEmpty) return;

          final request = CreatePlaceRequest(
            placeName: _nameController.text,
            zipCodeLinkIds: form.zipCodeIds.toList(),
          );

          await ref.read(placeProvider.notifier).createPlace(request);

          if (mounted) Navigator.pop(context, true);
        },
        child: const Text("Save Place"),
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

class _ZipList extends ConsumerWidget {
  final int officeId;

  const _ZipList({required this.officeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPlaceFormProvider);
    final notifier = ref.read(addPlaceFormProvider.notifier);

    final zipAsync = ref.watch(
      unlinkedZipCodesProvider((postOfficeId: officeId, placeId: 0)),
    );

    return zipAsync.when(
      data: (zips) {
        return Column(
          children: zips.map((zip) {
            final selected = form.zipCodeIds.contains(zip.zipCodeLinkId);

            return CheckboxListTile(
              value: selected,
              title: Text(zip.zipCode),
              onChanged: (_) => notifier.toggleZip(zip.zipCodeLinkId),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(),
      ),
      error: (_, __) => const Text("Error"),
    );
  }
}

class _EnterpriseOfficeSummary extends ConsumerWidget {
  final int officeId;
  final String officeName;

  const _EnterpriseOfficeSummary({
    required this.officeId,
    required this.officeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPlaceFormProvider);
    final notifier = ref.read(addPlaceFormProvider.notifier);

    final zipAsync = ref.watch(
      unlinkedZipCodesProvider((postOfficeId: officeId, placeId: 0)),
    );

    return zipAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (zips) {
        final selectedZips = zips
            .where((zip) => form.zipCodeIds.contains(zip.zipCodeLinkId))
            .toList();

        if (selectedZips.isEmpty) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                officeName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),

              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: selectedZips.map((zip) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (_) {
                          notifier.toggleZip(zip.zipCodeLinkId);
                        },
                      ),
                      Text(zip.zipCode, style: const TextStyle(fontSize: 13)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
