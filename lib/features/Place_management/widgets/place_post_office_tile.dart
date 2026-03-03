import 'package:flutter/material.dart';

import '../data/models/place_model.dart';

class PlacePostOfficeTile extends StatelessWidget {
  final PlacePostOffice office;
  final bool expanded;
  final void Function(bool expanded) onExpansionChanged;
  final void Function(PlacePostOffice office) onPostOfficeInfo;
  final void Function(PlaceZipCodeLink zip) onZipInfo;

  const PlacePostOfficeTile({
    super.key,
    required this.office,
    required this.expanded,
    required this.onExpansionChanged,
    required this.onPostOfficeInfo,
    required this.onZipInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: onExpansionChanged,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          office.postOfficeName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.blue,
              ),
              tooltip: 'Post office info',
              onPressed: () => onPostOfficeInfo(office),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        subtitle: Text(
          '${office.zipCodes.where((z) => z.active).length} zip codes',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          if (office.zipCodes.where((z) => z.active).isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No active zip codes'),
            )
          else
            ...office.zipCodes
                .where((zip) => zip.active)
                .map(
                  (zip) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                zip.zipCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.blue,
                              ),
                              tooltip: 'Zip code info',
                              onPressed: () => onZipInfo(zip),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
