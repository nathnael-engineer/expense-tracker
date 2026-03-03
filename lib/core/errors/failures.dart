abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = "Server Failure"]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = "Cache Failure"]);
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "Network Failure"]);
}

/// Auth failures
abstract class AuthFailure extends Failure {
  const AuthFailure([super.message = "Authentication Failure"]);
}

/// Specific auth failures
class LoginFailure extends AuthFailure {
  const LoginFailure([super.message = "Login Failure"]);
}

class RegisterFailure extends AuthFailure {
  const RegisterFailure([super.message = "Register Failure"]);
}

class SendEmailVerificationFailure extends AuthFailure {
  const SendEmailVerificationFailure([
    super.message = "Failed to send verification email",
  ]);
}

class ReloadUserFailure extends AuthFailure {
  const ReloadUserFailure([super.message = "Failed to refresh user session"]);
}

class LogoutFailure extends AuthFailure {
  const LogoutFailure([super.message = "Logout Failure"]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = "User not authenticated"]);
}
