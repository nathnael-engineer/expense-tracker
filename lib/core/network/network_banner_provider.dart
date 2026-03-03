import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/network/network_info_provider.dart';

enum NetworkBannerType { hidden, offline, online }

final networkBannerProvider =
    StreamNotifierProvider<NetworkBannerNotifier, NetworkBannerType>(
      NetworkBannerNotifier.new,
    );

class NetworkBannerNotifier extends StreamNotifier<NetworkBannerType> {
  @override
  Stream<NetworkBannerType> build() async* {
    final networkInfo = ref.read(networkInfoProvider);

    bool? previous;

    await for (final connected in networkInfo.onConnectionChanged) {
      if (previous == null) {
        previous = connected;
        if (!connected) yield NetworkBannerType.offline;
        continue;
      }

      if (previous != connected) {
        previous = connected;

        if (!connected) {
          yield NetworkBannerType.offline;
        } else {
          yield NetworkBannerType.online;
          await Future.delayed(const Duration(seconds: 2));
          yield NetworkBannerType.hidden;
        }
      }
    }
  }
}
