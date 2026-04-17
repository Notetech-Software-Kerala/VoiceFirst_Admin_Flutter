import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/country_management/country/data/models/country_model.dart';
import 'package:voice_first_admin/features/country_management/division1/data/models/division1_model.dart';
import 'package:voice_first_admin/features/country_management/division2/data/models/division_two_model.dart';
import 'package:voice_first_admin/features/country_management/division3/data/models/division_three_model.dart';

class Division3DetailPage extends StatelessWidget {
  final CountryModel country;
  final DivisionOneModel divisionOne;
  final DivisionTwoModel divisionTwo;
  final DivisionThreeModel divisionThree;

  const Division3DetailPage({
    super.key,
    required this.country,
    required this.divisionOne,
    required this.divisionTwo,
    required this.divisionThree,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = country.divisionThreeLabel?.trim().isNotEmpty == true
        ? country.divisionThreeLabel!.trim()
        : 'Division 3';
    final isActive = divisionThree.status;

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
                        divisionThree.name,
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
                        isActive ? 'Active' : 'Suspended',
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
          _InfoSection(
            title: 'Country Information',
            children: [
              _RowItem(label: 'Country', value: country.country),
              _DividerLine(),
              _RowItem(label: 'Country Code', value: country.countryCode),
              _DividerLine(),
              _RowItem(
                label: 'ISO Code',
                value: country.countryIsoCode ?? 'N/A',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // DIVISION 1 INFORMATION
          _InfoSection(
            title: '${country.divisionOneLabel ?? 'Division 1'} Information',
            leadingIcon: Icons.map_outlined,
            children: [
              _RowItem(
                label: country.divisionOneLabel ?? 'Division 1',
                value: divisionOne.name,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // DIVISION 2 INFORMATION
          _InfoSection(
            title: '${country.divisionTwoLabel ?? 'Division 2'} Information',
            leadingIcon: Icons.layers,
            children: [
              _RowItem(
                label: country.divisionTwoLabel ?? 'Division 2',
                value: divisionTwo.name,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // DIVISION 3 INFORMATION
          _InfoSection(
            title: '$label Information',
            leadingIcon: Icons.account_tree,
            children: [_RowItem(label: label, value: divisionThree.name)],
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

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(color: theme.dividerColor.withValues(alpha: 0.5), height: 1);
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? leadingIcon;
  const _InfoSection({
    required this.title,
    required this.children,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
                if (leadingIcon != null) ...[
                  Icon(leadingIcon),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
