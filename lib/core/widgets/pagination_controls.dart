import 'package:flutter/material.dart';

/// Reusable pagination controls widget
///
/// Example usage:
/// ```dart
/// PaginationControls(
///   currentPage: state.currentPage,
///   totalCount: state.totalCount,
///   pageSize: 10,
///   isLoading: state.isLoading,
///   hasMoreData: state.hasMoreData,
///   onPageChanged: (page) => _goToPage(page),
///   primaryColor: const Color(0xFF0D7FF2),
/// )
/// ```
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalCount;
  final int pageSize;
  final bool isLoading;
  final bool hasMoreData;
  final ValueChanged<int> onPageChanged;
  final Color? primaryColor;
  final double? spacing;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalCount,
    required this.pageSize,
    required this.isLoading,
    required this.hasMoreData,
    required this.onPageChanged,
    this.primaryColor,
    this.spacing = 8.0,
  });

  int get totalPages => (totalCount / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? Theme.of(context).primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: currentPage > 1 && !isLoading
              ? () => onPageChanged(currentPage - 1)
              : null,
          icon: Icon(
            Icons.chevron_left,
            color: currentPage > 1 ? color : Colors.grey.shade400,
          ),
          iconSize: 24,
        ),

        SizedBox(width: spacing),

        // Page indicator
        Container(
          constraints: const BoxConstraints(minWidth: 60),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  ),
                )
              : Text(
                  '$currentPage / $totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),

        SizedBox(width: spacing),

        // Next button
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: hasMoreData && !isLoading
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: Icon(
            Icons.chevron_right,
            color: hasMoreData ? color : Colors.grey.shade400,
          ),
          iconSize: 24,
        ),

        SizedBox(width: spacing),

        // Page selector dropdown
        PopupMenuButton<int>(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.more_vert, color: color, size: 20),
          iconSize: 20,
          offset: const Offset(0, -10),
          enabled: !isLoading,
          onSelected: onPageChanged,
          itemBuilder: (context) {
            return List.generate(
              totalPages,
              (index) => PopupMenuItem<int>(
                value: index + 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Page ${index + 1}'),
                    if (currentPage == index + 1)
                      Icon(Icons.check, color: color, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
