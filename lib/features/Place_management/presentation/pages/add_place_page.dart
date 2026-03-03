import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/add_place_provider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';
import 'package:voice_first_admin/core/widgets/paginated_search_dropdown.dart';
import 'package:voice_first_admin/features/Place_management/widgets/place_form_label.dart';
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
  final TextEditingController _searchController = TextEditingController();

  // Ensure only one hierarchy dropdown is open at a time
  final ValueNotifier<String?> _openDropdownId = ValueNotifier<String?>(null);

  // COUNTRY
  List<CountryLookup> _countries = [];
  bool _isLoadingCountries = false;
  bool _hasMoreCountries = true;
  int _countryPage = 1;
  String _countrySearchText = '';

  // DIVISION 1
  List<DivisionOneLookup> _divOneItems = [];
  bool _isLoadingDivOne = false;
  bool _hasMoreDivOne = true;
  int _divOnePage = 1;
  String _divOneSearchText = '';
  int? _divOneCountryId;

  // DIVISION 2
  List<DivisionTwoLookup> _divTwoItems = [];
  bool _isLoadingDivTwo = false;
  bool _hasMoreDivTwo = true;
  int _divTwoPage = 1;
  String _divTwoSearchText = '';
  int? _divTwoDivOneId;

  // DIVISION 3
  List<DivisionThreeLookup> _divThreeItems = [];
  bool _isLoadingDivThree = false;
  bool _hasMoreDivThree = true;
  int _divThreePage = 1;
  String _divThreeSearchText = '';
  int? _divThreeDivTwoId;

  // POST OFFICES (ZIP SECTION)
  final ScrollController _postOfficeScrollController = ScrollController();
  List<PostOfficeLookup> _postOffices = [];
  bool _isLoadingPostOffices = false;
  bool _hasMorePostOffices = true;
  int _postOfficePage = 1;
  String _postOfficeSearchText = '';
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
    _countries = [];
    _isLoadingCountries = false;
    _hasMoreCountries = true;
    _countryPage = 1;
    _countrySearchText = '';

    _divOneItems = [];
    _isLoadingDivOne = false;
    _hasMoreDivOne = true;
    _divOnePage = 1;
    _divOneSearchText = '';
    _divOneCountryId = null;

    _divTwoItems = [];
    _isLoadingDivTwo = false;
    _hasMoreDivTwo = true;
    _divTwoPage = 1;
    _divTwoSearchText = '';
    _divTwoDivOneId = null;

    _divThreeItems = [];
    _isLoadingDivThree = false;
    _hasMoreDivThree = true;
    _divThreePage = 1;
    _divThreeSearchText = '';
    _divThreeDivTwoId = null;

    _postOffices = [];
    _isLoadingPostOffices = false;
    _hasMorePostOffices = true;
    _postOfficePage = 1;
    _postOfficeSearchText = '';
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
      _loadPostOffices();
    }
  }

  // ================= COUNTRY =================
  Future<void> _loadCountries() async {
    if (_isLoadingCountries || !_hasMoreCountries) return;

    setState(() {
      _isLoadingCountries = true;
    });

    final service = ref.read(placeLookupServiceProvider);

    try {
      final response = await service.getCountriesPaginated(
        pageNumber: _countryPage,
        searchText: _countrySearchText.isEmpty ? null : _countrySearchText,
      );

      setState(() {
        _countries.addAll(response.items);
        _hasMoreCountries = response.currentPage < response.totalPages;
        _countryPage = response.currentPage + 1;
        _isLoadingCountries = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading countries: $e');
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  // ================= DIVISION 1 =================
  Future<void> _loadDivisionOne() async {
    final form = ref.read(addPlaceFormProvider);
    final countryId = form.countryId;
    if (countryId == null) return;

    if (_divOneCountryId != countryId) {
      // Country changed externally, reset state
      _divOneCountryId = countryId;
      _divOneItems = [];
      _divOnePage = 1;
      _hasMoreDivOne = true;
      _divOneSearchText = '';
    }

    if (_isLoadingDivOne || !_hasMoreDivOne) return;

    setState(() {
      _isLoadingDivOne = true;
    });

    final service = ref.read(placeLookupServiceProvider);

    try {
      final response = await service.getDivisionOnePaginated(
        countryId: countryId,
        pageNumber: _divOnePage,
        searchText: _divOneSearchText.isEmpty ? null : _divOneSearchText,
      );

      setState(() {
        _divOneItems.addAll(response.items);
        _hasMoreDivOne = response.currentPage < response.totalPages;
        _divOnePage = response.currentPage + 1;
        _isLoadingDivOne = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading division 1: $e');
      setState(() {
        _isLoadingDivOne = false;
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
      _divTwoItems = [];
      _divTwoPage = 1;
      _hasMoreDivTwo = true;
      _divTwoSearchText = '';
    }

    if (_isLoadingDivTwo || !_hasMoreDivTwo) return;

    setState(() {
      _isLoadingDivTwo = true;
    });

    final service = ref.read(placeLookupServiceProvider);

    try {
      final response = await service.getDivisionTwoPaginated(
        divOneId: divOneId,
        pageNumber: _divTwoPage,
        searchText: _divTwoSearchText.isEmpty ? null : _divTwoSearchText,
      );

      setState(() {
        _divTwoItems.addAll(response.items);
        _hasMoreDivTwo = response.currentPage < response.totalPages;
        _divTwoPage = response.currentPage + 1;
        _isLoadingDivTwo = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading division 2: $e');
      setState(() {
        _isLoadingDivTwo = false;
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
      _divThreeItems = [];
      _divThreePage = 1;
      _hasMoreDivThree = true;
      _divThreeSearchText = '';
    }

    if (_isLoadingDivThree || !_hasMoreDivThree) return;

    setState(() {
      _isLoadingDivThree = true;
    });

    final service = ref.read(placeLookupServiceProvider);

    try {
      final response = await service.getDivisionThreePaginated(
        divTwoId: divTwoId,
        pageNumber: _divThreePage,
        searchText: _divThreeSearchText.isEmpty ? null : _divThreeSearchText,
      );

      setState(() {
        _divThreeItems.addAll(response.items);
        _hasMoreDivThree = response.currentPage < response.totalPages;
        _divThreePage = response.currentPage + 1;
        _isLoadingDivThree = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading division 3: $e');
      setState(() {
        _isLoadingDivThree = false;
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
      _postOffices = [];
      _postOfficePage = 1;
      _hasMorePostOffices = true;
      _zipCodesByOffice.clear();
      _isLoadingZipByOffice.clear();
    }

    if (_isLoadingPostOffices || !_hasMorePostOffices) return;

    setState(() {
      _isLoadingPostOffices = true;
    });

    final service = ref.read(placeLookupServiceProvider);

    try {
      final response = await service.getPostOfficesPaginated(
        countryId: countryId,
        divOneId: divOneId,
        divTwoId: divTwoId,
        divThreeId: divThreeId,
        placeId: placeId,
        pageNumber: _postOfficePage,
        searchText: _postOfficeSearchText.isEmpty
            ? null
            : _postOfficeSearchText,
      );

      setState(() {
        _postOffices.addAll(response.items);
        _hasMorePostOffices = response.currentPage < response.totalPages;
        _postOfficePage = response.currentPage + 1;
        _isLoadingPostOffices = false;
      });
    } catch (e) {
      debugPrint('[AddPlace] Error loading post offices: $e');
      setState(() {
        _isLoadingPostOffices = false;
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

    final service = ref.read(placeLookupServiceProvider);

    try {
      final zips = await service.getZipCodesByPostOfficeIds(
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

    CountryLookup? selectedCountry;
    for (final c in _countries) {
      if (c.id == form.countryId) {
        selectedCountry = c;
        break;
      }
    }

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
              asyncItems: _isLoadingCountries && _countries.isEmpty
                  ? const AsyncValue<List<CountryLookup>>.loading()
                  : AsyncValue<List<CountryLookup>>.data(_countries),
              selectedItem: _countries
                  .where((c) => c.id == form.countryId)
                  .cast<CountryLookup?>()
                  .firstOrNull,
              displayText: (c) => c.name,
              itemId: (c) => c.id,
              onItemSelected: (country) {
                notifier.setCountry(country.id);

                setState(() {
                  // Reset dependent levels
                  _divOneItems = [];
                  _divOnePage = 1;
                  _hasMoreDivOne = true;
                  _divOneSearchText = '';
                  _divOneCountryId = country.id;

                  _divTwoItems = [];
                  _divTwoPage = 1;
                  _hasMoreDivTwo = true;
                  _divTwoSearchText = '';
                  _divTwoDivOneId = null;

                  _divThreeItems = [];
                  _divThreePage = 1;
                  _hasMoreDivThree = true;
                  _divThreeSearchText = '';
                  _divThreeDivTwoId = null;

                  _postOffices = [];
                  _postOfficePage = 1;
                  _hasMorePostOffices = true;
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
                  _countrySearchText = value.trim();
                  _countries = [];
                  _countryPage = 1;
                  _hasMoreCountries = true;
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
                asyncItems: _isLoadingDivOne && _divOneItems.isEmpty
                    ? const AsyncValue<List<DivisionOneLookup>>.loading()
                    : AsyncValue<List<DivisionOneLookup>>.data(_divOneItems),
                selectedItem: _divOneItems
                    .where((d) => d.id == form.divOneId)
                    .cast<DivisionOneLookup?>()
                    .firstOrNull,
                displayText: (d) => d.name,
                itemId: (d) => d.id,
                onItemSelected: (division) {
                  notifier.setDivOne(division.id);

                  setState(() {
                    _divTwoItems = [];
                    _divTwoPage = 1;
                    _hasMoreDivTwo = true;
                    _divTwoSearchText = '';
                    _divTwoDivOneId = null;

                    _divThreeItems = [];
                    _divThreePage = 1;
                    _hasMoreDivThree = true;
                    _divThreeSearchText = '';
                    _divThreeDivTwoId = null;

                    _postOffices = [];
                    _postOfficePage = 1;
                    _hasMorePostOffices = true;
                  });

                  _loadDivisionTwo();
                },
                onSearch: (value) {
                  setState(() {
                    _divOneSearchText = value.trim();
                    _divOneItems = [];
                    _divOnePage = 1;
                    _hasMoreDivOne = true;
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
                asyncItems: _isLoadingDivTwo && _divTwoItems.isEmpty
                    ? const AsyncValue<List<DivisionTwoLookup>>.loading()
                    : AsyncValue<List<DivisionTwoLookup>>.data(_divTwoItems),
                selectedItem: _divTwoItems
                    .where((d) => d.id == form.divTwoId)
                    .cast<DivisionTwoLookup?>()
                    .firstOrNull,
                displayText: (d) => d.name,
                itemId: (d) => d.id,
                onItemSelected: (division) {
                  notifier.setDivTwo(division.id);

                  setState(() {
                    _divThreeItems = [];
                    _divThreePage = 1;
                    _hasMoreDivThree = true;
                    _divThreeSearchText = '';
                    _divThreeDivTwoId = null;

                    _postOffices = [];
                    _postOfficePage = 1;
                    _hasMorePostOffices = true;
                  });

                  _loadDivisionThree();
                },
                onSearch: (value) {
                  setState(() {
                    _divTwoSearchText = value.trim();
                    _divTwoItems = [];
                    _divTwoPage = 1;
                    _hasMoreDivTwo = true;
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
                asyncItems: _isLoadingDivThree && _divThreeItems.isEmpty
                    ? const AsyncValue<List<DivisionThreeLookup>>.loading()
                    : AsyncValue<List<DivisionThreeLookup>>.data(
                        _divThreeItems,
                      ),
                selectedItem: _divThreeItems
                    .where((d) => d.id == form.divThreeId)
                    .cast<DivisionThreeLookup?>()
                    .firstOrNull,
                displayText: (d) => d.name,
                itemId: (d) => d.id,
                onItemSelected: (division) {
                  notifier.setDivThree(division.id);

                  setState(() {
                    _postOffices = [];
                    _postOfficePage = 1;
                    _hasMorePostOffices = true;
                  });

                  _loadPostOffices();
                },
                onSearch: (value) {
                  setState(() {
                    _divThreeSearchText = value.trim();
                    _divThreeItems = [];
                    _divThreePage = 1;
                    _hasMoreDivThree = true;
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
                            _postOfficeSearchText = '';
                            _postOffices = [];
                            _postOfficePage = 1;
                            _hasMorePostOffices = true;
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
                  _postOfficeSearchText = value.trim();
                  _postOffices = [];
                  _postOfficePage = 1;
                  _hasMorePostOffices = true;
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
            else if (_isLoadingPostOffices && _postOffices.isEmpty)
              const LinearProgressIndicator()
            else if (_postOffices.isEmpty)
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
                      itemCount: _postOffices.length,
                      itemBuilder: (context, index) {
                        final office = _postOffices[index];
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
                                }).toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isLoadingPostOffices && _postOffices.isNotEmpty)
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
