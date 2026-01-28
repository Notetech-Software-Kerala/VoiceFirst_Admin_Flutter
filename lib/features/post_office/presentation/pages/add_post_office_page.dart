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

  // Refactored State for Zip Codes (Web Style)
  final List<_ZipChipData> _zipChips = [];
  final TextEditingController _zipInputController = TextEditingController();

  bool _isSubmitting = false;

  // Country State
  List<dynamic> _countryList =
      []; // dynamic for now as we just need basic fields
  bool _isLoadingCountries = true;
  Country? _selectedCountry; // Mapped to local model

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

    // Use a simpler approach: Match by ID if editing, else default to 'US' or first
    final typedList = _countryList.cast<Country>();

    if (widget.postOffice != null) {
      try {
        _selectedCountry = typedList.firstWhere(
          (c) => c.id == widget.postOffice!.countryId,
        );
      } catch (_) {
        _selectedCountry = typedList.firstWhere(
          (c) => c.isoCode == 'US',
          orElse: () => typedList.first,
        );
      }
    } else {
      _selectedCountry = typedList.firstWhere(
        (c) => c.isoCode == 'US',
        orElse: () => typedList.first,
      );
    }
  }

  // --- API: SUBMIT LOGIC ---
  Future<void> _submitPostOffice() async {
    // 1. Validation
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
      bool success;

      if (isEdit) {
        success = await _handleEditFlow();
      } else {
        success = await _handleCreateFlow();
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

  // --- CREATE FLOW ---
  Future<bool> _handleCreateFlow() async {
    final List<String> activeZips = _zipChips
        .where((z) => z.isActive)
        .map((z) => z.code)
        .toList();

    final body = {
      "postOfficeName": _nameController.text,
      "countryId": _selectedCountry!.id,
      "active": true,
      "zipCodes": activeZips,
    };

    return await ref.read(postOfficeProvider.notifier).createPostOffice(body);
  }

  // --- EDIT FLOW ---
  Future<bool> _handleEditFlow() async {
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

    final body = {
      "postOfficeName": _nameController.text,
      "countryId": _selectedCountry!.id,
      "active": true,
      "zipCodes": consolidatedZips,
    };

    return await ref
        .read(postOfficeProvider.notifier)
        .updatePostOffice(poId, body);
  }

  // --- HELPERS ---

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
              countries: _countryList.cast<Country>(),
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
                                chip.isActive = true;
                              } else {
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
