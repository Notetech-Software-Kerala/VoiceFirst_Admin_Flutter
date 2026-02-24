import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    SnackBarAction? action,
    Duration? duration,
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);

    // Auto duration logic
    final resolvedDuration =
        duration ??
        (action != null
            ? const Duration(seconds: 6) // With action → 5–8 sec
            : _getDefaultDuration(type));

    ScaffoldMessenger.of(context).showSnackBar(
      // SnackBar(
      //   content: Row(
      //     children: [
      //       Icon(icon, color: Colors.white),
      //       const SizedBox(width: 12),
      //       Expanded(child: Text(message)),
      //       IconButton(
      //         icon: const Icon(Icons.close, color: Colors.white),
      //         tooltip: 'Close',
      //         onPressed: () {
      //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //         },
      //         padding: EdgeInsets.zero,
      //         constraints: const BoxConstraints(),
      //       ),
      //     ],
      //   ),
      //   backgroundColor: color,
      //   duration: resolvedDuration,
      //   action: action,
      //   behavior: SnackBarBehavior.floating,
      //   margin: const EdgeInsets.all(16),
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // ),
      SnackBar(
        content: SizedBox(
          height: message.length > 60 ? 64 : 48, // Standard Material height
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        duration: resolvedDuration,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ), // remove vertical padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Duration _getDefaultDuration(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Duration(seconds: 3); // 2–3 sec
      case SnackBarType.info:
        return const Duration(seconds: 4); // 3–4 sec
      case SnackBarType.warning:
        return const Duration(seconds: 4); // 4 sec
      case SnackBarType.error:
        return const Duration(seconds: 5); // 4–6 sec
    }
  }

  static Color _getColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green.shade600;
      case SnackBarType.error:
        return Colors.red.shade600;
      case SnackBarType.info:
        return Colors.blue.shade600;
      case SnackBarType.warning:
        return Colors.orange.shade600;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
    }
  }
}
