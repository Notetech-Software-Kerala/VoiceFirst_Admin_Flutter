import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/country_managements/division2/presentation/providers/division_two_notifier.dart';
import 'package:voice_first_admin/features/country_managements/division2/presentation/providers/division_two_state.dart';

/// Notifier provider family for DivisionTwo state keyed by `divisionOneId`.
final divisionTwoProvider =
    NotifierProvider.family<DivisionTwoNotifier, DivisionTwoState, int>(
      DivisionTwoNotifier.new,
    );
