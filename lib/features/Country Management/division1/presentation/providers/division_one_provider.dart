import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/providers/division_one_notifier.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/providers/division_one_state.dart';

final divisionOneProvider = Provider.family<DivisionOneNotifier, String>((
  ref,
  countryId,
) {
  final notifier = DivisionOneNotifier();
  notifier.initialize(countryId);
  return notifier;
});
