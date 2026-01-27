import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import '../providers/country_provider.dart';
import '../providers/country_state.dart';

class CountryDetailPage extends ConsumerWidget {
  final String countryId;

  const CountryDetailPage({super.key, required this.countryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = const Color(0xFF0D7FF2);
    final state = ref.watch(countryProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Country Details'),
          backgroundColor: primaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Country Details'),
          backgroundColor: primaryColor,
        ),
        body: Center(child: Text('Error: ${state.error}')),
      );
    }

    CountryModel? country;
    for (final c in state.countries) {
      if (c.id == countryId) {
        country = c;
        break;
      }
    }

    if (country == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Country Details'),
          backgroundColor: primaryColor,
        ),
        body: const Center(child: Text('Country not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Country Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.public, size: 40, color: primaryColor),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.country,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: country.status
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            country.status ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: country.status
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailSection(
                    title: 'Basic Information',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Country Name',
                        value: country.country,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Country Code',
                        value: country.countryCode,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'ISO Code',
                        value: country.countryIsoCode ?? 'N/A',
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (country.divisionOneLabel != null ||
                      country.divisionTwoLabel != null ||
                      country.divisionThreeLabel != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailSection(
                          title: 'Division Labels',
                          primaryColor: primaryColor,
                          children: [
                            if (country.divisionOneLabel != null)
                              _DetailItem(
                                label: 'Division 1',
                                value: country.divisionOneLabel!,
                                primaryColor: primaryColor,
                              ),
                            if (country.divisionTwoLabel != null)
                              _DetailItem(
                                label: 'Division 2',
                                value: country.divisionTwoLabel!,
                                primaryColor: primaryColor,
                              ),
                            if (country.divisionThreeLabel != null)
                              _DetailItem(
                                label: 'Division 3',
                                value: country.divisionThreeLabel!,
                                primaryColor: primaryColor,
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  _DetailSection(
                    title: 'Status',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Status',
                        value: country.status ? 'Active' : 'Inactive',
                        primaryColor: primaryColor,
                        valueColor: country.status ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.primaryColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 0, color: Colors.grey.shade200),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color primaryColor;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.primaryColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
