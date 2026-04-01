import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/reset_password/presentation/providers/password_notifier.dart';
import 'package:voice_first_admin/features/reset_password/presentation/providers/password_state.dart';


final passwordProvider = NotifierProvider<PasswordNotifier, PasswordState>(
  PasswordNotifier.new,
);
