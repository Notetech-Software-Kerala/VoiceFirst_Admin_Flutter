import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'password_notifier.dart';
import 'password_state.dart';

final passwordProvider = NotifierProvider<PasswordNotifier, PasswordState>(
  PasswordNotifier.new,
);
