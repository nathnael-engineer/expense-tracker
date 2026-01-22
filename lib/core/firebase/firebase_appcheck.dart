import 'package:firebase_app_check/firebase_app_check.dart';

class FirebaseAppCheckService {
  static Future<void> activate() async {
    await FirebaseAppCheck.instance.activate();
  }
}
