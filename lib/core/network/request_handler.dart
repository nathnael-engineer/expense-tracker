import 'dart:async';
import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/core/network/network_guard.dart';
import 'package:firebase_core/firebase_core.dart';

class RequestHandler {
  final NetworkGuard networkGuard;

  RequestHandler(this.networkGuard);

  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      await networkGuard.ensureConnected();

      return await request().timeout(const Duration(seconds: 10));
    } on NetworkException {
      rethrow;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw NetworkException('Connection timed out.');
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw NetworkException('No internet connection.');
      }

      throw ServerException(e.message ?? 'Server error occurred.');
    } catch (_) {
      throw ServerException('Unexpected error occurred.');
    }
  }
}
