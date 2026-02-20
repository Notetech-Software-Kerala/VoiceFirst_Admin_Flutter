import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/Country_Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country_Management/division1/models/division1_model.dart';

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
    final theme = Theme.of(context);
    final label = country.divisionOneLabel?.trim().isNotEmpty == true
        ? country.divisionOneLabel!.trim()
        : 'Division 1';
    final isActive = divisionOne.status;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('$label Details'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // PRIMARY INFO CARD (Name + Status)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: _Label('$label NAME')),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Text(
                        divisionOne.name,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  height: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(flex: 1, child: _Label('STATUS')),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // COUNTRY INFORMATION
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text(
                        'Country Information',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RowItem(label: 'Country', value: country.country),
                  Divider(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  _RowItem(label: 'Country Code', value: country.countryCode),
                  Divider(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  _RowItem(
                    label: 'ISO Code',
                    value: country.countryIsoCode ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // DIVISION 1 INFORMATION
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map_outlined),
                      const SizedBox(width: 8),
                      Text(
                        '$label Information',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RowItem(label: label, value: divisionOne.name),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────── UI HELPERS ─────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  const _RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
