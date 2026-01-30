import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post_office_model.dart';
import '../providers/post_office_provider.dart';

// --- MAIN SCREEN ---
class AddPostOfficePage extends ConsumerStatefulWidget {
  final PostOffice? postOffice; // If provided, we are in Edit Mode

  const AddPostOfficePage({super.key, this.postOffice});

  @override
  ConsumerState<AddPostOfficePage> createState() => _AddPostOfficePageState();
}

class _AddPostOfficePageState extends ConsumerState<AddPostOfficePage> {
  final TextEditingController _nameController = TextEditingController();

  // Zip Codes State
  final List<_ZipChipData> _zipChips = [];
  final TextEditingController _zipInputController = TextEditingController();

  bool _isSubmitting = false;

  // --- CASCADING STATE ---
  List<dynamic> _countryList = [];
  bool _isLoadingCountries = true;
  Country? _selectedCountry;

  // Division lists (store as generic Maps since we just need Id and Name)
  List<dynamic> _div1List = [];
  List<dynamic> _div2List = [];
  List<dynamic> _div3List = [];

  // Selected Division IDs (nullable)
  String? _selectedDiv1Id;
  String? _selectedDiv2Id;
  String? _selectedDiv3Id;

  bool _loadingDiv1 = false;
  bool _loadingDiv2 = false;
  bool _loadingDiv3 = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    // 1. Initial Edit Mode Setup (if needed)
    if (widget.postOffice != null) {
      _nameController.text = widget.postOffice!.name;
      // Populate Zips
      for (final z in widget.postOffice!.zipCodes) {
        _zipChips.add(
          _ZipChipData(
            id: z.id,
            code: z.code,
            isActive: z.active,
            isNew: false,
          ),
        );
      }
      // Note: We don't have Division IDs in the PostOffice model yet?
      // Assuming existing record might have them, but since user just requested the change,
      // the model likely doesn't have these fields reflected yet.
      // We will init divisions to null unless we update the model later.
    }

    // 2. Fetch Countries
    await _fetchCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zipInputController.dispose();
    super.dispose();
  }

  // --- FETCHERS ---

  Future<void> _fetchCountries() async {
    try {
      final repo = ref.read(postOfficeRepositoryProvider);
      final data = await repo.getCountries();

      if (mounted) {
        setState(() {
          _countryList = data.map((json) => Country.fromJson(json)).toList();
          _isLoadingCountries = false;
          _selectInitialCountry();
        });
      }
    } catch (e) {
      debugPrint("Error fetching countries: $e");
      if (mounted) setState(() => _isLoadingCountries = false);
    }
  }

  void _selectInitialCountry() {
    if (_countryList.isEmpty) return;

    // Default logic: Select US if creating, or match existing
    final typedList = _countryList.cast<Country>();
    if (widget.postOffice != null) {
      try {
        _selectedCountry = typedList.firstWhere(
          (c) => c.id == widget.postOffice!.countryId,
        );
      } catch (_) {
        _selectedCountry = typedList.isNotEmpty ? typedList.first : null;
      }
    } else {
      _selectedCountry = typedList.firstWhere(
        (c) => c.isoCode == 'US',
        orElse: () => typedList.first,
      );
    }

    // Trigger cascade if country selected
    if (_selectedCountry != null) _onCountryChanged(_selectedCountry!);
  }

  // --- CASCADE LOGIC ---

  void _onCountryChanged(Country? country) {
    if (country == null) return;
    setState(() {
      _selectedCountry = country;
      // Reset downstream
      _selectedDiv1Id = null;
      _div1List = [];
      _selectedDiv2Id = null;
      _div2List = [];
      _selectedDiv3Id = null;
      _div3List = [];
    });
    _fetchDivisionOne(
      country.id.toString(),
    ); // model ID is int, repo expects String usually but let's check.
    // Country model ID is int? Repo method signature `getDivisionOne(String)`?
  }

  Future<void> _fetchDivisionOne(String countryId) async {
    setState(() => _loadingDiv1 = true);
    try {
      final items = await ref
          .read(postOfficeRepositoryProvider)
          .getDivisionOne(countryId);
      if (mounted) setState(() => _div1List = items);
    } catch (e) {
      debugPrint("Error fetching Div 1: $e");
    } finally {
      if (mounted) setState(() => _loadingDiv1 = false);
    }
  }

  void _onDiv1Changed(String? val) {
    setState(() {
      _selectedDiv1Id = val;
      // Reset downstream
      _selectedDiv2Id = null;
      _div2List = [];
      _selectedDiv3Id = null;
      _div3List = [];
    });
    if (val != null) _fetchDivisionTwo(val);
  }

  Future<void> _fetchDivisionTwo(String div1Id) async {
    setState(() => _loadingDiv2 = true);
    try {
      final items = await ref
          .read(postOfficeRepositoryProvider)
          .getDivisionTwo(div1Id);
      if (mounted) setState(() => _div2List = items);
    } catch (e) {
      debugPrint("Error fetching Div 2: $e");
    } finally {
      if (mounted) setState(() => _loadingDiv2 = false);
    }
  }

  void _onDiv2Changed(String? val) {
    setState(() {
      _selectedDiv2Id = val;
      // Reset downstream
      _selectedDiv3Id = null;
      _div3List = [];
    });
    if (val != null) _fetchDivisionThree(val);
  }

  Future<void> _fetchDivisionThree(String div2Id) async {
    setState(() => _loadingDiv3 = true);
    try {
      final items = await ref
          .read(postOfficeRepositoryProvider)
          .getDivisionThree(div2Id);
      if (mounted) setState(() => _div3List = items);
    } catch (e) {
      debugPrint("Error fetching Div 3: $e");
    } finally {
      if (mounted) setState(() => _loadingDiv3 = false);
    }
  }

  // --- SUBMIT ---

  Future<void> _submitPostOffice() async {
    final hasActiveZip = _zipChips.any((z) => z.isActive);

    if (_nameController.text.isEmpty ||
        !hasActiveZip ||
        _selectedCountry == null) {
      _showSnack(
        'Please fill Name, Country and at least one active Zip Code',
        isError: true,
      );
      return;
    }

    // Optional: Validate divisions if they are mandatory?
    // User didn't specify, but usually they are. Assuming optional for now to avoid blocking.

    setState(() => _isSubmitting = true);

    try {
      final isEdit = widget.postOffice != null;
      bool success;

      // Prepare Payload
      // IDs: default to 0 if null as requested ("countryId": 0 etc in JSON example)
      final payloadBase = {
        "postOfficeName": _nameController.text,
        "countryId": _selectedCountry!.id, // int
        "divOneId": int.tryParse(_selectedDiv1Id ?? "0") ?? 0,
        "divTwoId": int.tryParse(_selectedDiv2Id ?? "0") ?? 0,
        "divThreeId": int.tryParse(_selectedDiv3Id ?? "0") ?? 0,
        "active": true,
      };

      if (isEdit) {
        // --- EDIT PAYLOAD ---
        final poId = widget.postOffice!.id;
        List<Map<String, dynamic>> consolidatedZips = [];
        for (final chip in _zipChips) {
          if (!chip.isNew) {
            consolidatedZips.add({
              "zipCodeId": chip.id,
              "zipCode": chip.code,
              "active": chip.isActive,
            });
          } else if (chip.isActive) {
            consolidatedZips.add({
              "zipCodeId": 0,
              "zipCode": chip.code,
              "active": true,
            });
          }
        }
        final body = {...payloadBase, "zipCodes": consolidatedZips};
        success = await ref
            .read(postOfficeProvider.notifier)
            .updatePostOffice(poId, body);
      } else {
        // --- CREATE PAYLOAD ---
        final activeZips = _zipChips
            .where((z) => z.isActive)
            .map((z) => z.code)
            .toList();
        final body = {...payloadBase, "zipCodes": activeZips}; // List<String>
        success = await ref
            .read(postOfficeProvider.notifier)
            .createPostOffice(body);
      }

      if (success && mounted) {
        _showSnack('Saved Successfully!', isError: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- UI HELPERS ---

  String _capitalize(String? s) {
    if (s == null || s.isEmpty) return "";
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
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

  // Generic Dropdown Helper
  Widget _buildDropdown({
    required String label,
    required String? value, // ID
    required List<dynamic> items,
    required bool isLoading,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    // Items are dynamic, usually Map {'id': .., 'name': ..}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        const SizedBox(height: 8),
        isLoading
            ? const LinearProgressIndicator(minHeight: 2)
            : DropdownButtonFormField<String>(
                value: value,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                hint: Text("Select $label"),
                items: items.map<DropdownMenuItem<String>>((item) {
                  final id =
                      (item['id'] ??
                              item['divOneId'] ??
                              item['divTwoId'] ??
                              item['divThreeId'] ??
                              "")
                          .toString();

                  final name =
                      item['name'] ??
                      item['divOneName'] ??
                      item['divTwoName'] ??
                      item['divThreeName'] ??
                      "Unknown";
                  return DropdownMenuItem(
                    value: id,
                    child: Text(name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Labels
    final div1Label = _selectedCountry?.divisionOneLabel != null
        ? _capitalize(_selectedCountry!.divisionOneLabel)
        : "Division One";
    final div2Label = _selectedCountry?.divisionTwoLabel != null
        ? _capitalize(_selectedCountry!.divisionTwoLabel)
        : "Division Two";
    final div3Label = _selectedCountry?.divisionThreeLabel != null
        ? _capitalize(_selectedCountry!.divisionThreeLabel)
        : "Division Three";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.postOffice != null ? "Edit Post Office" : "Add Post Office",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card (omitted for brevity, keep if needed or simplify)

            // Name
            const _FormLabel("Post Office Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Enter Name",
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),

            // Country
            const _FormLabel("Country"),
            const SizedBox(height: 8),
            _CountrySelector(
              selectedCountry: _selectedCountry,
              countries: _countryList.cast<Country>(),
              isLoading: _isLoadingCountries,
              onCountryChanged: _onCountryChanged,
            ),
            const SizedBox(height: 16),

            // --- CASCADING DIVISIONS ---
            if (_selectedCountry != null) ...[
              _buildDropdown(
                label: div1Label,
                value: _selectedDiv1Id,
                items: _div1List,
                isLoading: _loadingDiv1,
                onChanged: _onDiv1Changed,
              ),

              if (_selectedDiv1Id != null)
                _buildDropdown(
                  label: div2Label,
                  value: _selectedDiv2Id,
                  items: _div2List,
                  isLoading: _loadingDiv2,
                  onChanged: _onDiv2Changed,
                ),

              if (_selectedDiv2Id != null)
                _buildDropdown(
                  label: div3Label,
                  value: _selectedDiv3Id,
                  items: _div3List,
                  isLoading: _loadingDiv3,
                  onChanged: (val) => setState(() => _selectedDiv3Id = val),
                ),
            ],

            // Zip Codes
            const _FormLabel("Zip Codes"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (_zipChips.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _zipChips
                          .map((c) => _buildChip(c, theme))
                          .toList(),
                    ),
                  if (_zipChips.isNotEmpty) const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _zipInputController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Type zip code",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) => _addZip(val),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () => _addZip(_zipInputController.text),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: _isSubmitting ? null : _submitPostOffice,
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save Post Office"),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(_ZipChipData chip, ThemeData theme) {
    final isDeleted = !chip.isActive;
    // ... Chip UI logic from before ...
    return InputChip(
      label: Text(
        chip.code,
        style: TextStyle(
          decoration: isDeleted ? TextDecoration.lineThrough : null,
        ),
      ),
      deleteIcon: Icon(isDeleted ? Icons.restore : Icons.close, size: 18),
      onDeleted: () {
        setState(() {
          if (isDeleted)
            chip.isActive = true;
          else if (chip.isNew)
            _zipChips.remove(chip);
          else
            chip.isActive = false;
        });
      },
    );
  }

  void _addZip(String val) {
    if (val.trim().isEmpty) return;
    if (_zipChips.any((z) => z.code == val.trim() && z.isActive)) {
      _showSnack("Zip code exists", isError: true);
      return;
    }
    setState(() {
      _zipChips.add(
        _ZipChipData(id: 0, code: val.trim(), isActive: true, isNew: true),
      );
      _zipInputController.clear();
    });
  }
}

// Helpers
class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}

class _CountrySelector extends StatelessWidget {
  final Country? selectedCountry;
  final List<Country> countries;
  final bool isLoading;
  final ValueChanged<Country> onCountryChanged;
  const _CountrySelector({
    required this.selectedCountry,
    required this.countries,
    required this.isLoading,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LinearProgressIndicator();
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => ListView.builder(
            itemCount: countries.length,
            itemBuilder: (_, i) => ListTile(
              leading: Text(countries[i].flag),
              title: Text(countries[i].name),
              onTap: () {
                onCountryChanged(countries[i]);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              selectedCountry?.flag ?? "🌐",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(selectedCountry?.name ?? "Select Country"),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class _ZipChipData {
  final int id;
  final String code;
  bool isActive;
  final bool isNew;
  _ZipChipData({
    required this.id,
    required this.code,
    required this.isActive,
    required this.isNew,
  });
}
