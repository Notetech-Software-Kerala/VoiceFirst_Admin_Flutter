import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';

class Division1DetailPage extends StatelessWidget {
  final CountryModel country;
  final DivisionOneModel divisionOne;

  const Division1DetailPage({
    super.key,
    required this.country,
    required this.divisionOne,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0D7FF2);
    final label = country.divisionOneLabel?.trim().isNotEmpty == true
        ? country.divisionOneLabel!.trim()
        : 'Division 1';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          '$label Details',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
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
                      color: primaryColor.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          divisionOne.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: divisionOne.status
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            divisionOne.status ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: divisionOne.status
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailSection(
                    title: 'Country Information',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Country',
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

                  _DetailSection(
                    title: '$label Information',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: label,
                        value: divisionOne.name,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Division ID',
                        value: divisionOne.id,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Country ID',
                        value: divisionOne.countryId,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _DetailSection(
                    title: 'Status',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Current Status',
                        value: divisionOne.status ? 'Active' : 'Inactive',
                        primaryColor: primaryColor,
                        valueColor: divisionOne.status
                            ? Colors.green
                            : Colors.red,
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
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: children[index],
                  ),
                  if (index < children.length - 1)
                    Divider(height: 1, color: Colors.grey.shade200),
                ],
              ),
            ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
