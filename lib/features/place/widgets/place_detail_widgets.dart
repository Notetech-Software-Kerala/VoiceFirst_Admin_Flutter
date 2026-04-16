import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/place/data/models/place_model.dart';

class PlaceSectionLabel extends StatelessWidget {
  final String text;

  const PlaceSectionLabel(this.text, {super.key});

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

class PlaceInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const PlaceInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceHistorySection extends StatelessWidget {
  final PlaceModel place;
  final String Function(DateTime?) formatDate;

  const PlaceHistorySection({
    super.key,
    required this.place,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _HistoryExpansionTile(
        icon: Icons.flag_circle_outlined,
        title: 'Created Info',
        subtitle: 'Created by ${_formatUser(place.createdUser)}',
        initiallyExpanded: true,
        entries: [
          _HistoryEntry(
            label: 'Created By',
            value: _formatUser(place.createdUser),
          ),
          _HistoryEntry(
            label: 'Created Date',
            value: formatDate(place.createdDate),
          ),
        ],
      ),
    ];

    final hasModifiedUser =
        place.modifiedUser != null && place.modifiedUser!.trim().isNotEmpty;
    final hasModified = hasModifiedUser || place.modifiedDate != null;
    final hasDeleted = place.deletedUser != null || place.deletedDate != null;

    if (hasModified) {
      tiles.add(
        _HistoryExpansionTile(
          icon: Icons.update,
          title: 'Modified Info',
          subtitle: 'Modified by ${_formatUser(place.modifiedUser)}',
          entries: [
            _HistoryEntry(
              label: 'Modified By',
              value: _formatUser(place.modifiedUser),
            ),
            _HistoryEntry(
              label: 'Modified Date',
              value: formatDate(place.modifiedDate),
            ),
          ],
        ),
      );
    }

    if (hasDeleted) {
      tiles.add(
        _HistoryExpansionTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Deleted Info',
          subtitle: 'Deleted by ${_formatUser(place.deletedUser)}',
          entries: [
            _HistoryEntry(
              label: 'Deleted By',
              value: _formatUser(place.deletedUser),
            ),
            _HistoryEntry(
              label: 'Deleted Date',
              value: formatDate(place.deletedDate),
            ),
          ],
        ),
      );
    }

    return Column(children: tiles);
  }

  String _formatUser(String? value) {
    if (value == null || value.trim().isEmpty) return 'Unknown';
    return value;
  }
}

class _HistoryExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_HistoryEntry> entries;
  final bool initiallyExpanded;

  const _HistoryExpansionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.entries,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: entries.map((entry) => entry).toList(),
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryEntry({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
