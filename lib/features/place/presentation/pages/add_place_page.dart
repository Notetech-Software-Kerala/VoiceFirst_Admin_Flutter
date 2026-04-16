import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/place/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/place/data/models/place_requests.dart';
import 'package:voice_first_admin/features/place/presentation/providers/add_place_provider.dart';
import 'package:voice_first_admin/features/place/presentation/providers/lookup/lookup_provider.dart';
import 'package:voice_first_admin/core/widgets/paginated_search_dropdown.dart';
import 'package:voice_first_admin/features/place/presentation/providers/place_provider.dart';
import 'package:voice_first_admin/features/place/widgets/place_form_label.dart';

// Minimal per-dropdown paging container to reduce duplication (file-local)
class _Paging<T> {
  List<T> items = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  String search = '';

  void reset() {
    items = [];
    isLoading = false;
    hasMore = true;
    page = 1;
    search = '';
  }
}

class AddPlacePage extends ConsumerStatefulWidget {
  const AddPlacePage({super.key});

  @override
  ConsumerState<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends ConsumerState<AddPlacePage> {
  final _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Ensure only one hierarchy dropdown is open at a time
  final ValueNotifier<String?> _openDropdownId = ValueNotifier<String?>(null);

  // COUNTRY (uses _Paging helper)
  final _Paging<CountryLookup> _countryPaging = _Paging<CountryLookup>();

  // DIVISION 1
  final _Paging<DivisionOneLookup> _divOnePaging = _Paging<DivisionOneLookup>();
  int? _divOneCountryId;

  // DIVISION 2
  final _Paging<DivisionTwoLookup> _divTwoPaging = _Paging<DivisionTwoLookup>();
  int? _divTwoDivOneId;

  // DIVISION 3
  final _Paging<DivisionThreeLookup> _divThreePaging =
      _Paging<DivisionThreeLookup>();
  int? _divThreeDivTwoId;

  // POST OFFICES (ZIP SECTION)
  final ScrollController _postOfficeScrollController = ScrollController();
  final _Paging<PostOfficeLookup> _postOfficePaging =
      _Paging<PostOfficeLookup>();
  int? _filterCountryId;
  int? _filterDivOneId;
  int? _filterDivTwoId;
  int? _filterDivThreeId;
  int? _filterPlaceId;

  // ZIP CODES PER POST OFFICE (lazy-loaded)
  final Map<int, List<ZipCodeLookup>> _zipCodesByOffice = {};
  final Map<int, bool> _isLoadingZipByOffice = {};

  // SUMMARY CACHE FOR SELECTED ZIP CODES (persists across hierarchy changes)
  final Map<int, _SummaryZip> _selectedZipSummaries = {};

  @override
  void initState() {
    super.initState();
    // Ensure a fresh form every time this page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addPlaceFormProvider.notifier).clear();
    });

    // Reset local paging/search state
    _countryPaging.reset();

    _divOnePaging.reset();
    _divOneCountryId = null;

    _divTwoPaging.reset();
    _divTwoDivOneId = null;

    _divThreePaging.reset();
    _divThreeDivTwoId = null;

    _postOfficePaging.reset();
    _filterCountryId = null;
    _filterDivOneId = null;
    _filterDivTwoId = null;
    _filterDivThreeId = null;
    _filterPlaceId = null;
    _zipCodesByOffice.clear();
    _isLoadingZipByOffice.clear();
    _selectedZipSummaries.clear();
    _nameController.clear();
    _searchController.clear();

    _loadCountries();
    _postOfficeScrollController.addListener(_onPostOfficeScroll);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _postOfficeScrollController.dispose();
    _openDropdownId.dispose();
    super.dispose();
  }

  void _onPostOfficeScroll() {
    if (!_postOfficeScrollController.hasClients) return;
    final position = _postOfficeScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      if (_postOfficePaging.isLoading || !_postOfficePaging.hasMore) return;
      _loadPostOffices();
    }
  }

  // ================= COUNTRY =================
  Future<void> _loadCountries() async {
    if (_countryPaging.isLoading || !_countryPaging.hasMore) return;

    setState(() {
      _countryPaging.isLoading = true;
    });

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getCountriesPaginated(
        pageNumber: _countryPaging.page,
        searchText: _countryPaging.search.isEmpty
            ? null
            : _countryPaging.search,
      );

      setState(() {
        _countryPaging.items.addAll(response.items);
        _countryPaging.hasMore = response.currentPage < response.totalPages;
        _countryPaging.page = response.currentPage + 1;
        _countryPaging.isLoading = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading countries: $e');
      setState(() {
        _countryPaging.isLoading = false;
      });
    }
  }

  // ================= DIVISION 1 =================
  Future<void> _loadDivisionOne() async {
    final form = ref.read(addPlaceFormProvider);
    final countryId = form.countryId;
    if (countryId == null) return;
    if (_divOneCountryId != countryId) {
      _divOneCountryId = countryId;
      _divOnePaging.reset();
    }

    if (_divOnePaging.isLoading || !_divOnePaging.hasMore) return;

    setState(() {
      _divOnePaging.isLoading = true;
    });

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getDivisionOnePaginated(
        countryId: countryId,
        pageNumber: _divOnePaging.page,
        searchText: _divOnePaging.search.isEmpty ? null : _divOnePaging.search,
      );

      setState(() {
        _divOnePaging.items.addAll(response.items);
        _divOnePaging.hasMore = response.currentPage < response.totalPages;
        _divOnePaging.page = response.currentPage + 1;
        _divOnePaging.isLoading = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading division 1: $e');
      setState(() {
        _divOnePaging.isLoading = false;
      });
    }
  }

  // ================= DIVISION 2 =================
  Future<void> _loadDivisionTwo() async {
    final form = ref.read(addPlaceFormProvider);
    final divOneId = form.divOneId;
    if (divOneId == null) return;
    if (_divTwoDivOneId != divOneId) {
      _divTwoDivOneId = divOneId;
      _divTwoPaging.reset();
    }

    if (_divTwoPaging.isLoading || !_divTwoPaging.hasMore) return;

    setState(() {
      _divTwoPaging.isLoading = true;
    });

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getDivisionTwoPaginated(
        divOneId: divOneId,
        pageNumber: _divTwoPaging.page,
        searchText: _divTwoPaging.search.isEmpty ? null : _divTwoPaging.search,
      );

      setState(() {
        _divTwoPaging.items.addAll(response.items);
        _divTwoPaging.hasMore = response.currentPage < response.totalPages;
        _divTwoPaging.page = response.currentPage + 1;
        _divTwoPaging.isLoading = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading division 2: $e');
      setState(() {
        _divTwoPaging.isLoading = false;
      });
    }
  }

  // ================= DIVISION 3 =================
  Future<void> _loadDivisionThree() async {
    final form = ref.read(addPlaceFormProvider);
    final divTwoId = form.divTwoId;
    if (divTwoId == null) return;
    if (_divThreeDivTwoId != divTwoId) {
      _divThreeDivTwoId = divTwoId;
      _divThreePaging.reset();
    }

    if (_divThreePaging.isLoading || !_divThreePaging.hasMore) return;

    setState(() {
      _divThreePaging.isLoading = true;
    });

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getDivisionThreePaginated(
        divTwoId: divTwoId,
        pageNumber: _divThreePaging.page,
        searchText: _divThreePaging.search.isEmpty
            ? null
            : _divThreePaging.search,
      );

      setState(() {
        _divThreePaging.items.addAll(response.items);
        _divThreePaging.hasMore = response.currentPage < response.totalPages;
        _divThreePaging.page = response.currentPage + 1;
        _divThreePaging.isLoading = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading division 3: $e');
      setState(() {
        _divThreePaging.isLoading = false;
      });
    }
  }

  // ================= POST OFFICES (ZIP SECTION) =================
  Future<void> _loadPostOffices() async {
    final filter = ref.read(postOfficeFilterProvider);
    if (!filter.isReady) return;

    final countryId = filter.countryId!;
    final divOneId = filter.divOneId!;
    final divTwoId = filter.divTwoId!;
    final divThreeId = filter.divThreeId!;
    final placeId = filter.placeId;

    final changed =
        _filterCountryId != countryId ||
        _filterDivOneId != divOneId ||
        _filterDivTwoId != divTwoId ||
        _filterDivThreeId != divThreeId ||
        _filterPlaceId != placeId;

    if (changed) {
      _filterCountryId = countryId;
      _filterDivOneId = divOneId;
      _filterDivTwoId = divTwoId;
      _filterDivThreeId = divThreeId;
      _filterPlaceId = placeId;
      _postOfficePaging.reset();
      _zipCodesByOffice.clear();
      _isLoadingZipByOffice.clear();
    }

    if (_postOfficePaging.isLoading || !_postOfficePaging.hasMore) return;

    setState(() {
      _postOfficePaging.isLoading = true;
    });

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getPostOfficesPaginated(
        countryId: countryId,
        divOneId: divOneId,
        divTwoId: divTwoId,
        divThreeId: divThreeId,
        placeId: placeId,
        pageNumber: _postOfficePaging.page,
        searchText: _postOfficePaging.search.isEmpty
            ? null
            : _postOfficePaging.search,
      );

      setState(() {
        _postOfficePaging.items.addAll(response.items);
        _postOfficePaging.hasMore = response.currentPage < response.totalPages;
        _postOfficePaging.page = response.currentPage + 1;
        _postOfficePaging.isLoading = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading post offices: $e');
      setState(() {
        _postOfficePaging.isLoading = false;
      });
    }
  }

  Future<void> _loadZipCodesForOffice(int officeId) async {
    // Already loading or loaded
    if (_isLoadingZipByOffice[officeId] == true ||
        _zipCodesByOffice.containsKey(officeId)) {
      return;
    }

    setState(() {
      _isLoadingZipByOffice[officeId] = true;
    });

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final zips = await repository.getZipCodesByPostOfficeIds(
        postOfficeIds: [officeId],
      );

      setState(() {
        _zipCodesByOffice[officeId] = zips;
        _isLoadingZipByOffice[officeId] = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading zip codes for office $officeId: $e');
      setState(() {
        _isLoadingZipByOffice[officeId] = false;
      });
    }
  }

  void _toggleZipFromOffice({
    required ZipCodeLookup zip,
    required PostOfficeLookup office,
  }) {
    final notifier = ref.read(addPlaceFormProvider.notifier);
    final form = ref.read(addPlaceFormProvider);
    final id = zip.zipCodeLinkId;
    final wasSelected = form.zipCodeIds.contains(id);

    notifier.toggleZip(id);

    setState(() {
      if (!wasSelected) {
        _selectedZipSummaries[id] = _SummaryZip(
          zipCodeLinkId: id,
          zipCode: zip.zipCode,
          officeId: office.postOfficeId,
          officeName: office.postOfficeName,
        );
      } else {
        _selectedZipSummaries.remove(id);
      }
    });
  }

  /// Build grouped zip code summary by post office
  /// Uses _selectedZipSummaries so it persists across hierarchy changes.
  Widget _buildSelectedZipSection(ThemeData theme) {
    final form = ref.watch(addPlaceFormProvider);

    if (form.zipCodeIds.isEmpty) {
      return const SizedBox();
    }

    // Only keep summaries that are still selected in the form state
    final activeEntries = _selectedZipSummaries.entries
        .where((e) => form.zipCodeIds.contains(e.key))
        .toList();

    if (activeEntries.isEmpty) return const SizedBox();

    // postOfficeId -> list of summary zips
    final Map<int, List<_SummaryZip>> groupedByOffice = {};
    for (final entry in activeEntries) {
      final sz = entry.value;
      groupedByOffice.putIfAbsent(sz.officeId, () => []).add(sz);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 18),
              const SizedBox(width: 6),
              Text(
                "Selected Zip Codes (${form.zipCodeIds.length})",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...groupedByOffice.entries.map((entry) {
            final officeZips = entry.value;
            if (officeZips.isEmpty) return const SizedBox();

            final officeName = officeZips.first.officeName;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    officeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: officeZips.map((sz) {
                      final selected = form.zipCodeIds.contains(
                        sz.zipCodeLinkId,
                      );

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selected,
                            onChanged: (_) {
                              // Uncheck removes from form state and summary
                              if (selected) {
                                ref
                                    .read(addPlaceFormProvider.notifier)
                                    .toggleZip(sz.zipCodeLinkId);
                                setState(() {
                                  _selectedZipSummaries.remove(
                                    sz.zipCodeLinkId,
                                  );
                                });
                              }
                            },
                          ),
                          Text(
                            sz.zipCode,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
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

    final CountryLookup? selectedCountry = _countryPaging.items
        .cast<CountryLookup?>()
        .firstWhere((c) => c?.id == form.countryId, orElse: () => null);

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

    return Scaffold(
      appBar: AppBar(title: const Text("Add Place")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PLACE NAME
            const PlaceFormLabel("Place Name"),
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
            _buildSelectedZipSection(theme),
            const SizedBox(height: 20),

            /// COUNTRY (Paginated + server search)
            PaginatedSearchDropdown<CountryLookup>(
              id: 'add_place_country',
              openGroup: _openDropdownId,
              label: 'Country',
              hintText: 'Search country...',
              asyncItems:
                  _countryPaging.isLoading && _countryPaging.items.isEmpty
                  ? const AsyncValue<List<CountryLookup>>.loading()
                  : AsyncValue<List<CountryLookup>>.data(_countryPaging.items),
              selectedItem: _countryPaging.items
                  .where((c) => c.id == form.countryId)
                  .cast<CountryLookup?>()
                  .firstOrNull,
              displayText: (c) => c.name,
              itemId: (c) => c.id,
              onItemSelected: (country) {
                notifier.setCountry(country.id);

                setState(() {
                  // Reset dependent levels using _Paging helper
                  _divOnePaging.reset();
                  _divOneCountryId = country.id;

                  _divTwoPaging.reset();
                  _divTwoDivOneId = null;

                  _divThreePaging.reset();
                  _divThreeDivTwoId = null;

                  _postOfficePaging.reset();
                  _filterCountryId = null;
                  _filterDivOneId = null;
                  _filterDivTwoId = null;
                  _filterDivThreeId = null;
                  _filterPlaceId = null;
                });

                _loadDivisionOne();
              },
              onSearch: (value) {
                setState(() {
                  _countryPaging.search = value.trim();
                  _countryPaging.items = [];
                  _countryPaging.page = 1;
                  _countryPaging.hasMore = true;
                });
                _loadCountries();
              },
              onLoadMore: _loadCountries,
            ),

            /// DIVISION 1
            if (form.countryId != null)
              PaginatedSearchDropdown<DivisionOneLookup>(
                id: 'add_place_div1',
                openGroup: _openDropdownId,
                label: div1Label,
                hintText: 'Search division...',
                asyncItems:
                    _divOnePaging.isLoading && _divOnePaging.items.isEmpty
                    ? const AsyncValue<List<DivisionOneLookup>>.loading()
                    : AsyncValue<List<DivisionOneLookup>>.data(
                        _divOnePaging.items,
                      ),
                selectedItem: _divOnePaging.items
                    .where((d) => d.id == form.divOneId)
                    .cast<DivisionOneLookup?>()
                    .firstOrNull,
                displayText: (d) => d.name,
                itemId: (d) => d.id,
                onItemSelected: (division) {
                  notifier.setDivOne(division.id);

                  setState(() {
                    _divTwoPaging.reset();
                    _divTwoDivOneId = null;

                    _divThreePaging.reset();
                    _divThreeDivTwoId = null;

                    _postOfficePaging.reset();
                  });

                  _loadDivisionTwo();
                },
                onSearch: (value) {
                  setState(() {
                    _divOnePaging.search = value.trim();
                    _divOnePaging.items = [];
                    _divOnePaging.page = 1;
                    _divOnePaging.hasMore = true;
                  });
                  _loadDivisionOne();
                },
                onLoadMore: _loadDivisionOne,
              ),

            /// DIVISION 2
            if (form.divOneId != null)
              PaginatedSearchDropdown<DivisionTwoLookup>(
                id: 'add_place_div2',
                openGroup: _openDropdownId,
                label: div2Label,
                hintText: 'Search division...',
                asyncItems:
                    _divTwoPaging.isLoading && _divTwoPaging.items.isEmpty
                    ? const AsyncValue<List<DivisionTwoLookup>>.loading()
                    : AsyncValue<List<DivisionTwoLookup>>.data(
                        _divTwoPaging.items,
                      ),
                selectedItem: _divTwoPaging.items
                    .where((d) => d.id == form.divTwoId)
                    .cast<DivisionTwoLookup?>()
                    .firstOrNull,
                displayText: (d) => d.name,
                itemId: (d) => d.id,
                onItemSelected: (division) {
                  notifier.setDivTwo(division.id);

                  setState(() {
                    _divThreePaging.reset();
                    _divThreeDivTwoId = null;

                    _postOfficePaging.reset();
                  });

                  _loadDivisionThree();
                },
                onSearch: (value) {
                  setState(() {
                    _divTwoPaging.search = value.trim();
                    _divTwoPaging.items = [];
                    _divTwoPaging.page = 1;
                    _divTwoPaging.hasMore = true;
                  });
                  _loadDivisionTwo();
                },
                onLoadMore: _loadDivisionTwo,
              ),

            /// DIVISION 3
            if (form.divTwoId != null)
              PaginatedSearchDropdown<DivisionThreeLookup>(
                id: 'add_place_div3',
                openGroup: _openDropdownId,
                label: div3Label,
                hintText: 'Search division...',
                asyncItems:
                    _divThreePaging.isLoading && _divThreePaging.items.isEmpty
                    ? const AsyncValue<List<DivisionThreeLookup>>.loading()
                    : AsyncValue<List<DivisionThreeLookup>>.data(
                        _divThreePaging.items,
                      ),
                selectedItem: _divThreePaging.items
                    .where((d) => d.id == form.divThreeId)
                    .cast<DivisionThreeLookup?>()
                    .firstOrNull,
                displayText: (d) => d.name,
                itemId: (d) => d.id,
                onItemSelected: (division) {
                  notifier.setDivThree(division.id);

                  setState(() {
                    _postOfficePaging.reset();
                  });

                  _loadPostOffices();
                },
                onSearch: (value) {
                  setState(() {
                    _divThreePaging.search = value.trim();
                    _divThreePaging.items = [];
                    _divThreePaging.page = 1;
                    _divThreePaging.hasMore = true;
                  });
                  _loadDivisionThree();
                },
                onLoadMore: _loadDivisionThree,
              ),

            const SizedBox(height: 24),

            // ================= ZIP CODES SECTION =================
            const PlaceFormLabel("Zip Codes"),
            const SizedBox(height: 12),

            // Search Field (server-side filtering for post offices/zips)
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search post offices or zip codes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _postOfficePaging.search = '';
                            _postOfficePaging.items = [];
                            _postOfficePaging.page = 1;
                            _postOfficePaging.hasMore = true;
                            _zipCodesByOffice.clear();
                            _isLoadingZipByOffice.clear();
                          });
                          if (filter.isReady) {
                            _loadPostOffices();
                          }
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _postOfficePaging.search = value.trim();
                  _postOfficePaging.items = [];
                  _postOfficePaging.page = 1;
                  _postOfficePaging.hasMore = true;
                  _zipCodesByOffice.clear();
                  _isLoadingZipByOffice.clear();
                });
                if (filter.isReady) {
                  _loadPostOffices();
                }
              },
            ),

            const SizedBox(height: 12),

            // Scrollable Post Office List
            if (!filter.isReady)
              const SizedBox()
            else if (_postOfficePaging.isLoading &&
                _postOfficePaging.items.isEmpty)
              const LinearProgressIndicator()
            else if (_postOfficePaging.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'No post offices found for selected hierarchy',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    height: 400, // Fixed height for scrollable area
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      controller: _postOfficeScrollController,
                      itemCount: _postOfficePaging.items.length,
                      itemBuilder: (context, index) {
                        final office = _postOfficePaging.items[index];
                        final officeId = office.postOfficeId;
                        final officeZips =
                            _zipCodesByOffice[officeId] ?? <ZipCodeLookup>[];
                        final isLoadingZips =
                            _isLoadingZipByOffice[officeId] ?? false;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ExpansionTile(
                            title: Text(office.postOfficeName),
                            subtitle: Text(
                              officeZips.isEmpty
                                  ? (isLoadingZips
                                        ? 'Loading zip codes...'
                                        : 'Tap to load zip codes')
                                  : '${officeZips.length} zip codes',
                            ),
                            onExpansionChanged: (expanded) {
                              if (expanded) {
                                _loadZipCodesForOffice(officeId);
                              }
                            },
                            children: [
                              if (isLoadingZips && officeZips.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(),
                                )
                              else if (officeZips.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    'No zip codes found',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                ...officeZips.map((zip) {
                                  final selected = form.zipCodeIds.contains(
                                    zip.zipCodeLinkId,
                                  );

                                  return CheckboxListTile(
                                    value: selected,
                                    title: Text(zip.zipCode),
                                    onChanged: (_) => _toggleZipFromOffice(
                                      zip: zip,
                                      office: office,
                                    ),
                                  );
                                }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (_postOfficePaging.isLoading &&
                      _postOfficePaging.items.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(),
                    ),
                ],
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

class _SummaryZip {
  final int zipCodeLinkId;
  final String zipCode;
  final int officeId;
  final String officeName;

  const _SummaryZip({
    required this.zipCodeLinkId,
    required this.zipCode,
    required this.officeId,
    required this.officeName,
  });
}
