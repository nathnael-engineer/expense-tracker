import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/features/auth/data/models/user_model.dart';
import 'package:expense_tracker/core/network/request_handler.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> authStateChanges();

  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password);
  Future<void> logout();
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseDatabase firebaseDatabase;
  final RequestHandler requestHandler;

  AuthRemoteDataSourceImpl(
    this.firebaseAuth,
    this.firebaseDatabase,
    this.requestHandler,
  );

  @override
  Stream<UserModel?> authStateChanges() {
    return firebaseAuth.userChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        emailVerified: firebaseUser.emailVerified,
      );
    });
  }

  @override
  Future<void> sendEmailVerification() async {
    return requestHandler.execute(() async {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('User not authenticated.');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    });
  }

  @override
  Future<void> reloadUser() async {
    return requestHandler.execute(() async {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('User not authenticated.');
      }

      await user.reload();
      await user.getIdToken(true);
    });
  }

  @override
  Future<UserModel> login(String email, String password) async {
    return requestHandler.execute(() async {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw AuthException('Login failed. User is null.');
      }

      await user.reload();

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        emailVerified: user.emailVerified,
      );
    });
  }

  @override
  Future<UserModel> register(String email, String password) async {
    return requestHandler.execute(() async {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw AuthException('User is null after registration');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      final userRef = firebaseDatabase.ref('users/${user.uid}');

      await userRef.update({
        'email': user.email,
        'createdAt': ServerValue.timestamp,
        'lastLogin': ServerValue.timestamp,
      });

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        emailVerified: user.emailVerified,
      );
    });
  }

  @override
  Future<void> logout() async {
    return requestHandler.execute(() async {
      await firebaseAuth.signOut();
    });
  }
}
