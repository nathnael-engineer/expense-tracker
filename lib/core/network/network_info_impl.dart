import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:expense_tracker/core/network/network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  /// 🔹 One-time check (used by NetworkGuard)
  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 4));

      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 🔹 Debounced + distinct connection stream (production-level)
  @override
  Stream<bool> get onConnectionChanged async* {
    // Emit initial value
    yield await isConnected;

    // Listen to changes
    yield* connectivity.onConnectivityChanged
        .debounceTime(const Duration(milliseconds: 800))
        .asyncMap((_) => isConnected)
        .distinct();
  }
}
