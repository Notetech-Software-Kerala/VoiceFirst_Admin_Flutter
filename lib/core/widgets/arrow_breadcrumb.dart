import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
    this.isActive = false,
  });
}

class ArrowBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final EdgeInsetsGeometry padding;

  const ArrowBreadcrumb({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _BreadcrumbChip(item: items[i]),
            if (i < items.length - 1) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 18, color: theme.hintColor),
              const SizedBox(width: 6),
            ],
          ],
        ],
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  final BreadcrumbItem item;
  const _BreadcrumbChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final text = Text(
      item.label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w500,
        color: item.isActive
            ? theme.textTheme.bodyMedium?.color
            : theme.hintColor,
      ),
    );

    if (item.onTap == null || item.isActive) {
      return text;
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: text,
      ),
    );
  }
}
