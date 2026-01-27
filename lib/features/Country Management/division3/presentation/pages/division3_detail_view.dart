import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/models/DivisionTwoModel';
import 'package:voice_first_admin/features/Country%20Management/division3/models/division_three_model.dart';

class Division3DetailPage extends StatelessWidget {
  final CountryModel country;
  final DivisionOneModel divisionOne;
  final DivisionTwoModel divisionTwo;
  final DivisionThreeModel divisionThree;

  const Division3DetailPage({
    super.key,
    required this.country,
    required this.divisionOne,
    required this.divisionTwo,
    required this.divisionThree,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0D7FF2);
    final label = country.divisionThreeLabel?.trim().isNotEmpty == true
        ? country.divisionThreeLabel!.trim()
        : 'Division 3';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          '$label Details',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryColor.withAlpha(40),
                    child: Icon(
                      Icons.account_tree,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      divisionThree.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _Section(
                    title: 'Country Information',
                    primaryColor: primaryColor,
                    children: [
                      _Item('Country', country.country),
                      _Item('Country Code', country.countryCode),
                      _Item('ISO Code', country.countryIsoCode ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _Section(
                    title:
                        '${country.divisionOneLabel ?? 'Division 1'} Information',
                    primaryColor: primaryColor,
                    children: [
                      _Item(
                        country.divisionOneLabel ?? 'Division 1',
                        divisionOne.name,
                      ),
                      _Item('Division 1 ID', divisionOne.id),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _Section(
                    title:
                        '${country.divisionTwoLabel ?? 'Division 2'} Information',
                    primaryColor: primaryColor,
                    children: [
                      _Item(
                        country.divisionTwoLabel ?? 'Division 2',
                        divisionTwo.name,
                      ),
                      _Item('Division 2 ID', divisionTwo.id),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _Section(
                    title: '$label Information',
                    primaryColor: primaryColor,
                    children: [
                      _Item(label, divisionThree.name),
                      _Item('Division 3 ID', divisionThree.id),
                      _Item('Division 2 ID', divisionThree.divisionTwoId),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.primaryColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children
                .map(
                  (e) => Column(
                    children: [
                      Padding(padding: const EdgeInsets.all(16), child: e),
                      Divider(height: 1, color: Colors.grey.shade200),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;

  const _Item(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
