import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/core/network/network_info.dart';

class NetworkGuard {
  final NetworkInfo networkInfo;

  NetworkGuard(this.networkInfo);

  Future<void> ensureConnected() async {
    final connected = await networkInfo.isConnected;

    if (!connected) {
      throw NetworkException('No internet connection.');
    }
  }
}
