import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showDeleteBottomSheet({
  required BuildContext context,
  required String itemName,
  required VoidCallback onDelete,
  String title = "DELETE RECORD?",
  String warningText = "Are you sure you want to remove this record?",
  String subWarningText = "This action cannot be undone.",
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows sheet to size itself
    backgroundColor: Colors.transparent, // Transparent to show rounded corners
    builder: (context) => _DeleteConfirmationSheet(
      itemName: itemName,
      onDelete: onDelete,
      title: title,
      warningText: warningText,
      subWarningText: subWarningText,
    ),
  );
}

class _DeleteConfirmationSheet extends StatelessWidget {
  final String itemName;
  final VoidCallback onDelete;
  final String title;
  final String warningText;
  final String subWarningText;

  const _DeleteConfirmationSheet({
    required this.itemName,
    required this.onDelete,
    required this.title,
    required this.warningText,
    required this.subWarningText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Custom Colors
    const primary = Color(0xFFEC1313);
    final sheetBg = isDark ? const Color(0xFF181111) : Colors.white;
    final cardBg = isDark ? const Color(0xFF2A1A1A) : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : Colors.grey[900];
    final subTextColor = isDark ? const Color(0xFFB99D9D) : Colors.grey[500];

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        40,
      ), // Bottom padding for safety
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink to fit content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF543B3B) : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever, color: primary, size: 32),
            ),
          ),
          const SizedBox(height: 16),

          // Header Text
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Highlight Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? primary.withValues(alpha: 0.1)
                    : Colors.grey[200]!,
              ),
            ),
            child: Text(
              itemName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),

          // Body Text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 15,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: "$warningText\n"),
                  TextSpan(
                    text: subWarningText,
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          ElevatedButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context); // Close sheet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: primary.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, size: 20),
                SizedBox(width: 8),
                Text(
                  "Delete Record",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Keep it",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
