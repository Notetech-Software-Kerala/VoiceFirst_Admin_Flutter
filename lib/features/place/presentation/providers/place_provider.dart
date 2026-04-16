import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/place/presentation/providers/place_notifier.dart';
import 'package:voice_first_admin/features/place/presentation/providers/place_state.dart';

final placeProvider = NotifierProvider<PlaceNotifier, PlaceState>(
  PlaceNotifier.new,
);
