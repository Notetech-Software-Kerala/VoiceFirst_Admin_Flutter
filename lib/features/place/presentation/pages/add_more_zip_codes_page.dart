import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/place/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/place/presentation/providers/edit_place_form_provider.dart';
import 'package:voice_first_admin/features/place/presentation/providers/lookup/lookup_provider.dart';
import 'package:voice_first_admin/core/widgets/paginated_search_dropdown.dart';
import 'package:voice_first_admin/features/place/widgets/place_form_label.dart';

class AddMoreZipCodesPage extends ConsumerStatefulWidget {
  final int placeId;

  const AddMoreZipCodesPage({super.key, required this.placeId});

  @override
  ConsumerState<AddMoreZipCodesPage> createState() =>
      _AddMoreZipCodesPageState();
}

class _AddMoreZipCodesPageState extends ConsumerState<AddMoreZipCodesPage> {
  late TextEditingController _searchController;

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

  // POST OFFICES (for Add More Zip Codes section)
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Ensure a fresh edit form hierarchy each time this page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editPlaceFormProvider.notifier).clearHierarchy();
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

    _searchController.clear();

    _loadCountries();
    _postOfficeScrollController.addListener(_onPostOfficeScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _postOfficeScrollController.dispose();
    _openDropdownId.dispose();
    super.dispose();
  }

  // ================= COUNTRY (Paginated) =================
  Future<void> _loadCountries() async {
    if (_isLoadingCountries || !_hasMoreCountries) return;

    setState(() {
      _isLoadingCountries = true;
    });

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getCountriesPaginated(
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
      debugPrint('[AddMoreZipCodes] Error loading countries: $e');
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  // ================= DIVISION 1 (Paginated) =================
  Future<void> _loadDivisionOne() async {
    final form = ref.read(editPlaceFormProvider);
    final countryId = form.countryId;
    if (countryId == null) return;

    if (_divOneCountryId != countryId) {
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

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getDivisionOnePaginated(
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
      debugPrint('[AddMoreZipCodes] Error loading division 1: $e');
      setState(() {
        _isLoadingDivOne = false;
      });
    }
  }

  // ================= DIVISION 2 (Paginated) =================
  Future<void> _loadDivisionTwo() async {
    final form = ref.read(editPlaceFormProvider);
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

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getDivisionTwoPaginated(
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
      debugPrint('[AddMoreZipCodes] Error loading division 2: $e');
      setState(() {
        _isLoadingDivTwo = false;
      });
    }
  }

  // ================= DIVISION 3 (Paginated) =================
  Future<void> _loadDivisionThree() async {
    final form = ref.read(editPlaceFormProvider);
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

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getDivisionThreePaginated(
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
      debugPrint('[AddMoreZipCodes] Error loading division 3: $e');
      setState(() {
        _isLoadingDivThree = false;
      });
    }
  }

  void _onPostOfficeScroll() {
    if (!_postOfficeScrollController.hasClients) return;
    final position = _postOfficeScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      _loadPostOffices();
    }
  }

  Future<void> _loadPostOffices() async {
    final filter = ref.read(postOfficeFilterForEditProvider(widget.placeId));
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

    final repository = ref.read(placeLookupRepositoryProvider);

    try {
      final response = await repository.getPostOfficesPaginated(
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
      debugPrint('[AddMoreZipCodes] Error loading post offices: $e');
      setState(() {
        _isLoadingPostOffices = false;
      });
    }
  }

  Future<void> _loadZipCodesForOffice(int officeId) async {
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
      debugPrint(
        '[AddMoreZipCodes] Error loading zip codes for office $officeId: $e',
      );
      setState(() {
        _isLoadingZipByOffice[officeId] = false;
      });
    }
  }

  Widget _buildSelectedZipSection(
    ThemeData theme,
    List<PostOfficeLookup> offices,
  ) {
    final form = ref.watch(editPlaceFormProvider);

    // ✅ Only NEWLY added + ACTIVE zip codes
    final newActiveZips = form.zipCodeItems
        .where((z) => z.isNew && z.isActive)
        .toList();

    if (newActiveZips.isEmpty) {
      return const SizedBox();
    }

    // Group by post office
    final Map<int, List<EditZipCodeItem>> grouped = {};

    for (final item in newActiveZips) {
      grouped.putIfAbsent(item.postOfficeId, () => []).add(item);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle, size: 18),
              const SizedBox(width: 6),
              Text(
                "Newly Added Zip Codes (${newActiveZips.length})",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...grouped.entries.map((entry) {
            final officeName = entry.value.first.postOfficeName;

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
                    children: entry.value
                        .map(
                          (item) => Chip(
                            label: Text(item.zipCode),
                            visualDensity: VisualDensity.compact,
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              ref
                                  .read(editPlaceFormProvider.notifier)
                                  .removeNewZip(item.zipCodeLinkId);
                            },
                          ),
                        )
                        .toList(),
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
    final filter = ref.watch(postOfficeFilterForEditProvider(widget.placeId));
    final offices = const <PostOfficeLookup>[];

    final theme = Theme.of(context);
    final form = ref.watch(editPlaceFormProvider);
    final notifier = ref.read(editPlaceFormProvider.notifier);

    // Resolve labels from selected country in the locally cached list
    final CountryLookup? selectedCountry = _countries
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
            _buildSelectedZipSection(theme, offices),

            const PlaceFormLabel('Select Hierarchy'),
            const SizedBox(height: 8),

            // ================= COUNTRY (Paginated dropdown) =================
            PaginatedSearchDropdown<CountryLookup>(
              id: 'add_more_country',
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

                  // Clear post office section when hierarchy root changes
                  _postOffices = [];
                  _postOfficePage = 1;
                  _hasMorePostOffices = true;
                  _zipCodesByOffice.clear();
                  _isLoadingZipByOffice.clear();
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

            const SizedBox(height: 12),

            // ================= DIVISION ONE (Paginated dropdown) =================
            if (form.countryId != null)
              PaginatedSearchDropdown<DivisionOneLookup>(
                id: 'add_more_div1',
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

                    // Clear post office section when division changes
                    _postOffices = [];
                    _postOfficePage = 1;
                    _hasMorePostOffices = true;
                    _zipCodesByOffice.clear();
                    _isLoadingZipByOffice.clear();
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

            const SizedBox(height: 12),

            // ================= DIVISION TWO (Paginated dropdown) =================
            if (form.divOneId != null)
              PaginatedSearchDropdown<DivisionTwoLookup>(
                id: 'add_more_div2',
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

                    // Clear post office section when division changes
                    _postOffices = [];
                    _postOfficePage = 1;
                    _hasMorePostOffices = true;
                    _zipCodesByOffice.clear();
                    _isLoadingZipByOffice.clear();
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

            const SizedBox(height: 12),

            // ================= DIVISION THREE (Paginated dropdown) =================
            if (form.divTwoId != null)
              PaginatedSearchDropdown<DivisionThreeLookup>(
                id: 'add_more_div3',
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

                  // When the deepest level of hierarchy changes, reset
                  // post office paging state and load offices for the
                  // selected hierarchy (same behavior as Add Place page).
                  setState(() {
                    _postOffices = [];
                    _postOfficePage = 1;
                    _hasMorePostOffices = true;
                    _zipCodesByOffice.clear();
                    _isLoadingZipByOffice.clear();
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

            // ================= AVAILABLE POST OFFICES =================
            const PlaceFormLabel('Available Post Offices'),
            const SizedBox(height: 12),

            // Search Field
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
                    height: 400,
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
                                  final existingIndex = form.zipCodeItems
                                      .indexWhere(
                                        (z) =>
                                            z.zipCodeLinkId ==
                                            zip.zipCodeLinkId,
                                      );
                                  final isChecked = existingIndex >= 0
                                      ? form
                                            .zipCodeItems[existingIndex]
                                            .isActive
                                      : false;

                                  return CheckboxListTile(
                                    value: isChecked,
                                    title: Text(zip.zipCode),
                                    onChanged: (_) {
                                      if (existingIndex == -1) {
                                        notifier.addNewZip(
                                          postOfficeId: office.postOfficeId,
                                          zipCodeLinkId: zip.zipCodeLinkId,
                                          zipCode: zip.zipCode,
                                          postOfficeName: office.postOfficeName,
                                        );
                                      } else {
                                        notifier.toggleZip(zip.zipCodeLinkId);
                                      }
                                    },
                                  );
                                }),
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
