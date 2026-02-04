import 'package:flutter/material.dart';

class StandardPaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const StandardPaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: currentPage > 1
                  ? theme.iconTheme.color
                  : theme.disabledColor,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "Page $currentPage of $totalPages",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: currentPage < totalPages
                  ? theme.iconTheme.color
                  : theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
