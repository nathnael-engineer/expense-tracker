import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/features/auth/application/notifiers/auth_notifier.dart';
import 'package:expense_tracker/features/auth/application/state/auth_state.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
