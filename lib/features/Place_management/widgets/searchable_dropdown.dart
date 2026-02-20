import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;

  /// 🔥 Required for custom object comparison
  final Object Function(T) itemId;

  final void Function(T?) onChanged;
  final String? hint;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.itemId,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(8);
    final outlineBorder = OutlineInputBorder(borderRadius: borderRadius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        DropdownSearch<T>(
          items: (filter, loadProps) {
            if (filter.isEmpty) return items;

            return items
                .where((e) =>
                    itemLabel(e).toLowerCase().contains(filter.toLowerCase()))
                .toList();
          },

          selectedItem: value,

          // 🔥 THIS FIXES YOUR ERROR
          compareFn: (a, b) => itemId(a) == itemId(b),

          itemAsString: itemLabel,
          onChanged: onChanged,

          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: hint ?? "Select $label",
              border: outlineBorder,
              enabledBorder: outlineBorder,
              focusedBorder: outlineBorder.copyWith(
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              filled: true,
              fillColor: theme.cardColor,
            ),
          ),

          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            itemBuilder: (context, item, isSelected, isDisabled) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(itemLabel(item)),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
