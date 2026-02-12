import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'place_notifier.dart';
import 'place_state.dart';

final placeProvider = NotifierProvider<PlaceNotifier, PlaceState>(
  PlaceNotifier.new,
);
