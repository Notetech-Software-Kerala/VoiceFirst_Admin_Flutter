import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/post_office_provider.dart';

// Specific widget for Post Office Location filtering
// This will be passed as 'extraContent' to the GlobalFilterBottomSheet
class PostOfficeLocationFilter extends ConsumerStatefulWidget {
  const PostOfficeLocationFilter({super.key});

  @override
  ConsumerState<PostOfficeLocationFilter> createState() =>
      _PostOfficeLocationFilterState();
}

class _PostOfficeLocationFilterState
    extends ConsumerState<PostOfficeLocationFilter> {
  List<dynamic> _countries = [];
  List<dynamic> _states = [];
  bool _isLoadingCountries = false;
  bool _isLoadingStates = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    // Pre-load states if country is already selected in provider
    final filter = ref.read(postOfficeProvider).filter;
    if (filter.countryId != null) {
      _loadStates(filter.countryId.toString());
    }
  }

  Future<void> _loadCountries() async {
    setState(() => _isLoadingCountries = true);
    try {
      final repo = ref.read(postOfficeRepositoryProvider);
      final countries = await repo.getCountries();
      if (mounted) {
        setState(() {
          _countries = countries;
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCountries = false);
    }
  }

  Future<void> _loadStates(String countryId) async {
    setState(() => _isLoadingStates = true);
    try {
      final repo = ref.read(postOfficeRepositoryProvider);
      final states = await repo.getDivisionOne(countryId);
      if (mounted) {
        setState(() {
          _states = states;
          _isLoadingStates = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStates = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to reflect current selection
    final filter = ref.watch(postOfficeProvider).filter;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Selection
        Text(
          "COUNTRY",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingCountries)
          const Center(child: CircularProgressIndicator())
        else if (_countries.isEmpty)
          const Text("No countries available")
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _countries.map((c) {
              final id = c['countryId'];
              final name = c['countryName'] ?? 'Unknown';
              final isSelected = filter.countryId == id;
              return _FilterChip(
                label: name,
                isSelected: isSelected,
                onTap: () {
                  final notifier = ref.read(postOfficeProvider.notifier);
                  if (isSelected) {
                    // Clear Country
                    notifier.setFilter(
                      filter.copyWith(countryId: null, divisionOneId: null),
                    );
                    setState(() => _states = []);
                  } else {
                    // Set Country
                    notifier.setFilter(
                      filter.copyWith(countryId: id, divisionOneId: null),
                    );
                    _loadStates(id.toString());
                  }
                },
              );
            }).toList(),
          ),

        const SizedBox(height: 24),

        // State Selection
        if (filter.countryId != null) ...[
          Text(
            "STATE / REGION",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingStates)
            const Center(child: CircularProgressIndicator())
          else if (_states.isEmpty)
            const Text("No states available")
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _states.map((s) {
                final id = s['divisionId'];
                final name = s['divisionName'] ?? 'Unknown';
                final isSelected = filter.divisionOneId == id;
                return _FilterChip(
                  label: name,
                  isSelected: isSelected,
                  onTap: () {
                    final notifier = ref.read(postOfficeProvider.notifier);
                    notifier.setFilter(
                      filter.copyWith(divisionOneId: isSelected ? null : id),
                    );
                  },
                );
              }).toList(),
            ),
        ],
      ],
    );
  }
}

// Re-using simplified chip for this internal widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.primaryColor
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
