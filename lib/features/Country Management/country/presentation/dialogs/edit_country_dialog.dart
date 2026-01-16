import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import '../providers/country_provider.dart';

class EditCountryDialog {
  static void show(BuildContext context, WidgetRef ref, CountryModel country) {
    final countryController = TextEditingController(text: country.country);
    final countryCodeController = TextEditingController(
      text: country.countryCode,
    );
    final isoCodeController = TextEditingController(
      text: country.countryIsoCode,
    );
    final divisionOneLabelController = TextEditingController(
      text: country.divisionOneLabel ?? '',
    );
    final divisionTwoLabelController = TextEditingController(
      text: country.divisionTwoLabel ?? '',
    );
    final divisionThreeLabelController = TextEditingController(
      text: country.divisionThreeLabel ?? '',
    );

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Country'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'Country Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countryCodeController,
                decoration: const InputDecoration(
                  labelText: 'Country Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: isoCodeController,
                decoration: const InputDecoration(
                  labelText: 'ISO Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: divisionOneLabelController,
                decoration: const InputDecoration(
                  labelText: 'Division 1 Label (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: divisionTwoLabelController,
                decoration: const InputDecoration(
                  labelText: 'Division 2 Label (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: divisionThreeLabelController,
                decoration: const InputDecoration(
                  labelText: 'Division 3 Label (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedCountry = CountryModel(
                id: country.id,
                country: countryController.text,
                countryCode: countryCodeController.text,
                countryIsoCode: isoCodeController.text,
                divisionOneLabel: divisionOneLabelController.text.isEmpty
                    ? null
                    : divisionOneLabelController.text,
                divisionTwoLabel: divisionTwoLabelController.text.isEmpty
                    ? null
                    : divisionTwoLabelController.text,
                divisionThreeLabel: divisionThreeLabelController.text.isEmpty
                    ? null
                    : divisionThreeLabelController.text,
                status: country.status,
              );

              ref.read(countryProvider.notifier).update(updatedCountry);
              Navigator.of(dialogContext).pop();

              CustomSnackbar.show(
                context,
                message: '${updatedCountry.country} updated successfully',
                type: SnackBarType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7FF2),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
