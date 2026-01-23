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
  final TextEditingController _zipController = TextEditingController();

  bool _isSubmitting = false;

  // Country State
  List<Country> _countryList = [];
  bool _isLoadingCountries = true;
  Country? _selectedCountry; // Nullable until selected

  @override
  void initState() {
    super.initState();
    if (widget.postOffice != null) {
      _nameController.text = widget.postOffice!.name;
      _zipController.text = widget.postOffice!.zipCodes
          .map((z) => z.code)
          .join(", ");
    }
    _fetchCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  // --- API: FETCH COUNTRIES ---
  Future<void> _fetchCountries() async {
    final url = Uri.parse('http://192.168.0.202:8010/api/country/lookup');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final List<dynamic> data =
            jsonMap['data'] ?? []; // Your API returns list inside 'data'

        if (mounted) {
          setState(() {
            _countryList = data.map((json) => Country.fromJson(json)).toList();
            _isLoadingCountries = false;

            if (widget.postOffice != null) {
              // Find country by ID if editing
              try {
                _selectedCountry = _countryList.firstWhere(
                  (c) => c.id == widget.postOffice!.countryId,
                );
              } catch (e) {
                // Fallback if country ID doesn't match
                if (_countryList.isNotEmpty) {
                  _selectedCountry = _countryList.firstWhere(
                    (c) => c.isoCode == 'US',
                    orElse: () => _countryList.first,
                  );
                }
              }
            } else if (_countryList.isNotEmpty) {
              // Default to US for new additions
              _selectedCountry = _countryList.firstWhere(
                (c) => c.isoCode == 'US',
                orElse: () => _countryList.first,
              );
            }
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

  // --- API: SUBMIT FORM ---
  Future<void> _submitPostOffice() async {
    if (_nameController.text.isEmpty ||
        _zipController.text.isEmpty ||
        _selectedCountry == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields and select a country'),
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final isEdit = widget.postOffice != null;
    final url = isEdit
        ? Uri.parse(
            'http://192.168.0.202:8010/api/post-office/${widget.postOffice!.id}',
          )
        : Uri.parse('http://192.168.0.202:8010/api/post-office');

    // Build Zip Code List for Payload
    final inputZipStrings = _zipController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    List<Map<String, dynamic>> zipPayload = [];

    if (isEdit) {
      final existingZips = widget.postOffice!.zipCodes;
      final Set<int> processedIds = {};

      // 1. Handle Updates (Keep Existing) & Creates (New)
      for (final newZip in inputZipStrings) {
        // Find if this zip string matches an existing one
        final match = existingZips.cast<PostOfficeZipCode?>().firstWhere(
          (z) => z!.code == newZip,
          orElse: () => null,
        );

        if (match != null) {
          // It exists and is still in the list -> Active
          processedIds.add(match.id);
          zipPayload.add({
            "zipCodeId": match.id,
            "zipCode": newZip,
            "active": true,
          });
        } else {
          // It's not in the existing list -> New -> Active
          zipPayload.add({"zipCodeId": 0, "zipCode": newZip, "active": true});
        }
      }

      // 2. Handle Deletes (Soft delete missing ones)
      for (final oldZip in existingZips) {
        if (!processedIds.contains(oldZip.id)) {
          // Was in existing but not in new input -> Inactive
          zipPayload.add({
            "zipCodeId": oldZip.id,
            "zipCode": oldZip.code,
            "active": false,
          });
        }
      }
    } else {
      // New Post Office: All active
      zipPayload = inputZipStrings
          .map((z) => {"zipCode": z, "active": true})
          .toList();
    }

    // Construct Body
    final Map<String, dynamic> bodyMap = {
      "postOfficeName": _nameController.text,
      "countryId": _selectedCountry!.id,
      "zipCodes": isEdit ? zipPayload : inputZipStrings,
    };

    if (isEdit) {
      bodyMap['isActive'] = true; // PATCH requires isActive
    }

    try {
      final response = isEdit
          ? await http.patch(
              url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(bodyMap),
            )
          : await http.post(
              url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(bodyMap),
            );

      final jsonMap = jsonDecode(response.body);
      final String msg = jsonMap['Message'] ?? jsonMap['message'] ?? 'Unknown';
      // Some APIs return 200 HTTP both for success and business logic errors.
      // We check the internal statusCode if available.
      final int internalCode =
          jsonMap['StatusCode'] ?? jsonMap['statusCode'] ?? 0;

      if (!mounted) return;

      // Check HTTP status AND Internal status (if present)
      final bool isHttpSuccess =
          (response.statusCode >= 200 && response.statusCode < 300);
      final bool isInternalSuccess =
          (internalCode == 0) || (internalCode >= 200 && internalCode < 300);

      if (isHttpSuccess && isInternalSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isEdit ? "Updated" : "Added"}: $msg'),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _zipController.clear();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $msg'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: theme.iconTheme.color,
              ),
            ),
          ),
        ),
        title: Text(
          widget.postOffice != null ? "Edit Post Office" : "Add Post Office",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Visual Context Card
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
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: NetworkImage("https://placeholder.pics/svg/300"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.primaryColor.withOpacity(0.2),
                            const Color(0xFF101622).withOpacity(0.8),
                          ],
                        ),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Define the organizational location details to enable voice-activated logistics tracking.",
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields
            const SizedBox(height: 8),
            const _FormLabel("Post Office Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "e.g. Central Hub",
                prefixIcon: Icon(Icons.location_on, color: theme.primaryColor),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 20),
            const _FormLabel("Country"),
            const SizedBox(height: 8),
            _CountrySelector(
              selectedCountry: _selectedCountry,
              countries: _countryList,
              isLoading: _isLoadingCountries,
              onCountryChanged: (c) => setState(() => _selectedCountry = c),
            ),

            const SizedBox(height: 20),
            const _FormLabel("Zip / Pin Code"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _zipController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: "e.g. 683511, 683502",
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: theme.scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPostOffice,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.postOffice != null
                              ? "Update Post Office"
                              : "Add Post Office",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              "VOICEFIRST ENTERPRISE EDITION",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets
// -----------------------------------------------------------------------------

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).hintColor.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
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

  void _showCountryPicker(BuildContext context) {
    // If fetching failed or still loading, don't open
    if (countries.isEmpty && !isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No countries loaded. Please check connection."),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Select Country",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: countries.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final country = countries[index];
                          return ListTile(
                            leading: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(country.name),
                            trailing: Text(
                              country.dialCode,
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            onTap: () {
                              onCountryChanged(country);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showCountryPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            // Flag or Loader
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                selectedCountry?.flag ?? "🌐",
                style: const TextStyle(fontSize: 24),
              ),

            const SizedBox(width: 12),

            // Name or Placeholder
            Expanded(
              child: Text(
                selectedCountry?.name ?? "Select Country...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selectedCountry == null
                      ? theme.hintColor
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Icon(Icons.expand_more, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}
