import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker/core/config/app_env.dart';
import 'dart:io';

class FirebaseEmulatorConfig {
  static const String physicalDeviceHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '',
  );

  static Future<void> connect() async {
    if (!AppEnv.useFirebaseEmulator) return;

    final host = _resolveHost();

    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
    FirebaseDatabase.instance.useDatabaseEmulator(host, 9000);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);

    debugPrint('🔥 Firebase emulators connected');
    debugPrint('Platform: ${_platform()}');
    debugPrint('Host: $host');
    debugPrint(
      'USE_FIREBASE_EMULATOR = ${const bool.fromEnvironment('USE_FIREBASE_EMULATOR')}',
    );
    debugPrint(
      'DISABLE_EMAIL_VERIFICATION = ${const bool.fromEnvironment('DISABLE_EMAIL_VERIFICATION')}',
    );
  }

  static String _resolveHost() {
    if (kIsWeb) return 'localhost';

    if (Platform.isAndroid) return '10.0.2.2';

    if (Platform.isIOS) return 'localhost';

    if (physicalDeviceHost.isNotEmpty) return physicalDeviceHost;

    return 'localhost';
  }

  static String _platform() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }
}
