import 'package:flutter/material.dart';

void showRecoveryBottomSheet({
  required BuildContext context,
  required String itemName,
  required VoidCallback onRecover,
  String title = "RECOVER RECORD?",
  String questionText = "Are you sure you want to restore this record?",
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor:
        Colors.transparent, // Important for the custom rounded corners
    builder: (context) => _RecoveryConfirmationSheet(
      itemName: itemName,
      onRecover: onRecover,
      title: title,
      questionText: questionText,
    ),
  );
}

class _RecoveryConfirmationSheet extends StatelessWidget {
  final String itemName;
  final VoidCallback onRecover;
  final String title;
  final String questionText;

  const _RecoveryConfirmationSheet({
    required this.itemName,
    required this.onRecover,
    required this.title,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define Tailwind Colors or use Theme primary if preferred.
    // User specified Green-500 for recovery.
    const primary = Color(0xFF22C55E);

    // Custom Colors based on Tailwind Config from design
    final sheetBg = isDark ? const Color(0xFF181111) : Colors.white;
    final cardBg = isDark
        ? const Color(0xFF221A1A)
        : const Color(0xFFF9FAFB); // gray-50
    final borderColor = isDark
        ? primary.withValues(alpha: 0.05)
        : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.grey[900];
    final subTextColor = isDark ? const Color(0xFF9C8484) : Colors.grey[500];

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3D2C2C) : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Main Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restore_from_trash_rounded,
                color: primary,
                size: 40,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Section Header
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subTextColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Target Record Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              itemName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Text(
              questionText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),

          // Action Buttons
          ElevatedButton(
            onPressed: () {
              onRecover();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: primary.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 24),
                SizedBox(width: 8),
                Text(
                  "Recover Record",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey[400] : Colors.grey[500],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
