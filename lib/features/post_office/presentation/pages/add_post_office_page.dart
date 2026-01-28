import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/post_office_model.dart';

// --- MAIN SCREEN ---

class AddPostOfficePage extends StatefulWidget {
  final PostOffice? postOffice; // If provided, we are in Edit Mode

  const AddPostOfficePage({super.key, this.postOffice});

  @override
  State<AddPostOfficePage> createState() => _AddPostOfficePageState();
}

class _AddPostOfficePageState extends State<AddPostOfficePage> {
  final TextEditingController _nameController = TextEditingController();

  // Refactored State for Zip Codes (Web Style)
  // We track all zips: Active (Blue), Inactive (Grey), New (Blue)
  final List<_ZipChipData> _zipChips = [];
  final TextEditingController _zipInputController = TextEditingController();

  bool _isSubmitting = false;

  // Country State
  List<Country> _countryList = [];
  bool _isLoadingCountries = true;
  Country? _selectedCountry; // Nullable until selected

  // API Configuration
  // Ideally this should be in a global config/constant file
  static const String _baseUrl = 'http://192.168.0.202:8010/api';

  @override
  void initState() {
    super.initState();
    if (widget.postOffice != null) {
      _nameController.text = widget.postOffice!.name;
      // Populate ALL zips (Active and Inactive)
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
    }
    _fetchCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zipInputController.dispose();
    super.dispose();
  }

  // --- API: FETCH COUNTRIES ---
  Future<void> _fetchCountries() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/country/lookup'));

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final List<dynamic> data = jsonMap['data'] ?? [];

        if (mounted) {
          setState(() {
            _countryList = data.map((json) => Country.fromJson(json)).toList();
            _isLoadingCountries = false;
            _selectInitialCountry();
          });
        }
      } else {
        debugPrint("Failed to load countries: ${response.statusCode}");
        if (mounted) setState(() => _isLoadingCountries = false);
      }
    } catch (e) {
      debugPrint("Error fetching countries: $e");
      if (mounted) setState(() => _isLoadingCountries = false);
    }
  }

  void _selectInitialCountry() {
    if (_countryList.isEmpty) return;

    if (widget.postOffice != null) {
      try {
        _selectedCountry = _countryList.firstWhere(
          (c) => c.id == widget.postOffice!.countryId,
        );
      } catch (_) {
        _selectedCountry = _countryList.firstWhere(
          (c) => c.isoCode == 'US',
          orElse: () => _countryList.first,
        );
      }
    } else {
      _selectedCountry = _countryList.firstWhere(
        (c) => c.isoCode == 'US',
        orElse: () => _countryList.first,
      );
    }
  }

  // --- API: SUBMIT LOGIC ---
  Future<void> _submitPostOffice() async {
    // 1. Validation
    // Must have at least one ACTIVE zip code
    final hasActiveZip = _zipChips.any((z) => z.isActive);

    if (_nameController.text.isEmpty ||
        !hasActiveZip ||
        _selectedCountry == null) {
      _showSnack(
        'Please fill all fields and add at least one active zip code',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final isEdit = widget.postOffice != null;
      if (isEdit) {
        await _handleEditFlow();
      } else {
        await _handleCreateFlow();
      }

      if (mounted) {
        _showSnack('Saved Successfully!', isError: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- CREATE FLOW ---
  Future<void> _handleCreateFlow() async {
    // Only send ACTIVE zip codes for creation
    final List<String> activeZips = _zipChips
        .where((z) => z.isActive)
        .map((z) => z.code)
        .toList();

    final body = {
      "postOfficeName": _nameController.text,
      "countryId": _selectedCountry!.id,
      "active": true,
      "zipCodes": activeZips, // List<String> as verified earlier
    };

    debugPrint("Sending Create Body: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse('$_baseUrl/post-office'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    _validateResponse(response, "Create Post Office");
  }

  // --- EDIT FLOW ---
  Future<void> _handleEditFlow() async {
    final poId = widget.postOffice!.id;
    List<Map<String, dynamic>> consolidatedZips = [];

    for (final chip in _zipChips) {
      // 1. Existing Zips (Active or Inactive)
      if (!chip.isNew) {
        consolidatedZips.add({
          "zipCodeId": chip.id,
          "zipCode": chip.code,
          "active": chip.isActive,
        });
      }
      // 2. New Zips (Must be Active to be relevant, ignored if added then 'deleted' before save)
      else if (chip.isActive) {
        consolidatedZips.add({
          "zipCodeId": 0,
          "zipCode": chip.code,
          "active": true,
        });
      }
    }

    final body = {
      "postOfficeName": _nameController.text,
      "countryId": _selectedCountry!.id,
      "active": true,
      "zipCodes": consolidatedZips,
    };

    debugPrint("Sending Unified PATCH Body: ${jsonEncode(body)}");

    final response = await http.patch(
      Uri.parse('$_baseUrl/post-office/$poId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    _validateResponse(response, "Update Post Office");
  }

  // --- HELPERS ---

  void _validateResponse(http.Response response, String action) {
    if (!_isSuccess(response)) {
      throw "$action Failed. Status: ${response.statusCode}. Body: ${response.body}";
    }
  }

  bool _isSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        if (response.body.isEmpty) return true;
        final json = jsonDecode(response.body);
        final internalCode = json['StatusCode'] ?? json['statusCode'] ?? 0;
        return (internalCode == 0 ||
            (internalCode >= 200 && internalCode < 300));
      } catch (_) {
        return true;
      }
    }
    return false;
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            // ... Visual header ...
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: theme.primaryColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.store,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Office Setup",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage location details.",
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
              countries: _countryList,
              isLoading: _isLoadingCountries,
              onCountryChanged: (c) => setState(() => _selectedCountry = c),
            ),
            const SizedBox(height: 16),

            // Zip Codes (Chips UI)
            const _FormLabel("Zip Codes"),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chip Wrap
                  if (_zipChips.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _zipChips.map((chip) {
                        final isDeleted = !chip.isActive;
                        return InputChip(
                          label: Text(
                            chip.code,
                            style: TextStyle(
                              decoration: isDeleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isDeleted
                                  ? theme.disabledColor
                                  : (isDark
                                        ? Colors.white
                                        : theme.primaryColor),
                            ),
                          ),
                          backgroundColor: isDeleted
                              ? theme.disabledColor.withOpacity(0.1)
                              : theme.primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isDeleted
                                  ? theme.disabledColor.withOpacity(0.3)
                                  : theme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          // Icon Logic
                          deleteIcon: Icon(
                            isDeleted ? Icons.restore : Icons.close,
                            size: 18,
                            color: isDeleted
                                ? theme.disabledColor
                                : theme.primaryColor,
                          ),
                          onDeleted: () {
                            setState(() {
                              if (isDeleted) {
                                // Restore
                                chip.isActive = true;
                              } else {
                                // Soft Delete (or Remove if New)
                                if (chip.isNew) {
                                  _zipChips.remove(chip);
                                } else {
                                  chip.isActive = false;
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                  if (_zipChips.isNotEmpty) const SizedBox(height: 12),

                  // Input Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _zipInputController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Type zip code & press enter",
                            border: InputBorder.none,
                            isDense: true,
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
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitPostOffice,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save Post Office"),
          ),
        ),
      ),
    );
  }

  void _addZip(String val) {
    final code = val.trim();
    if (code.isEmpty) return;

    // Duplicates check
    if (_zipChips.any((z) => z.code == code && z.isActive)) {
      _showSnack("Zip code already exists", isError: true);
      return;
    }

    setState(() {
      _zipChips.add(
        _ZipChipData(id: 0, code: code, isActive: true, isNew: true),
      );
      _zipInputController.clear();
    });
  }
}

// --- HELPER CLASSES ---

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
        if (countries.isEmpty) return;
        showModalBottomSheet(
          context: context,
          builder: (ctx) {
            return ListView.builder(
              itemCount: countries.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: Text(countries[i].flag),
                title: Text(countries[i].name),
                onTap: () {
                  onCountryChanged(countries[i]);
                  Navigator.pop(ctx);
                },
              ),
            );
          },
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
