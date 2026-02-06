import 'package:flutter/material.dart';

/// Standard primary action button for editing or saving details.
class StandardEditButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  final bool isLoading;

  const StandardEditButton({
    super.key,
    required this.onPressed,
    this.label = 'Edit',
    this.icon = Icons.edit_outlined,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      // icon: Icon(icon, size: 20),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Standard destructive action button for delete flows.
class StandardDeleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final bool isLoading;
  const StandardDeleteButton({
    super.key,
    required this.onPressed,
    this.label = 'Delete',
    this.icon = Icons.delete_outline,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextButton.icon(
      // onPressed: onPressed,
      onPressed: isLoading ? null : onPressed,
      // icon: Icon(icon, color: cs.error),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.error),
            )
          : Icon(icon, color: cs.error),

      label: Text(
        label,
        style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: cs.error.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Standard recovery/restore button for bringing back soft-deleted items.
class StandardRecoveryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final bool isLoading;

  const StandardRecoveryButton({
    super.key,
    required this.onPressed,
    this.label = 'Recover',
    this.icon = Icons.restore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      // icon: Icon(icon, color: Colors.green),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.green,
              ),
            )
          : Icon(icon, color: Colors.green),

      label: Text(label, style: const TextStyle(color: Colors.green)),
      style: OutlinedButton.styleFrom(
        backgroundColor: theme.cardColor,
        side: const BorderSide(color: Colors.green),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
