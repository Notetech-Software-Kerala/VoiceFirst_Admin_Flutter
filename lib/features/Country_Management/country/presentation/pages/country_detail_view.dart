import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/country_management/country/data/models/country_model.dart';
import 'package:voice_first_admin/features/country_management/country/presentation/providers/country_provider.dart';

class CountryDetailPage extends ConsumerWidget {
  final int countryId;

  const CountryDetailPage({super.key, required this.countryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(countryProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Country Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Country Details')),
        body: Center(child: Text('Error: ${state.error}')),
      );
    }

    CountryModel? country;
    for (final c in state.items) {
      if (c.id == countryId) {
        country = c;
        break;
      }
    }

    if (country == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Country Details')),
        body: const Center(child: Text('Country not found')),
      );
    }

    final isActive = country.status;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Country Details'),
        elevation: 0,
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
                    const Expanded(flex: 1, child: _Label('COUNTRY NAME')),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Text(
                        country.country,
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

          // BASIC INFORMATION
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
                        'Basic Information',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

          // DIVISION LABELS (if available)
          if (country.divisionOneLabel != null ||
              country.divisionTwoLabel != null ||
              country.divisionThreeLabel != null)
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
                        Icon(Icons.map_outlined),
                        SizedBox(width: 8),
                        Text(
                          'Division Labels',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (country.divisionOneLabel != null)
                      _RowItem(
                        label: 'Division 1',
                        value: country.divisionOneLabel!,
                      ),
                    if (country.divisionTwoLabel != null) ...[
                      Divider(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                        height: 1,
                      ),
                      _RowItem(
                        label: 'Division 2',
                        value: country.divisionTwoLabel!,
                      ),
                    ],
                    if (country.divisionThreeLabel != null) ...[
                      if (country.divisionOneLabel != null ||
                          country.divisionTwoLabel != null)
                        Divider(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                          height: 1,
                        ),
                      _RowItem(
                        label: 'Division 3',
                        value: country.divisionThreeLabel!,
                      ),
                    ],
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
