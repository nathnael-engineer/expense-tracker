import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/injection.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return sl<NetworkInfo>();
});
