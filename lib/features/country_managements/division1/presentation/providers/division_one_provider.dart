import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/country_managements/division1/presentation/providers/division_one_notifier.dart';
import 'package:voice_first_admin/features/country_managements/division1/presentation/providers/division_one_state.dart';

/// Notifier provider family for DivisionOne state keyed by `countryId`.
final divisionOneProvider =
    NotifierProvider.family<DivisionOneNotifier, DivisionOneState, int>(
      DivisionOneNotifier.new,
    );
