class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  });

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  });

  Future<bool> loginWithGoogle();

  Future<bool> verifyTokenToBackend();

  Future<bool> checkEmailVerified();

  Future<void> resendVerificationEmail();

  Future<void> resetPassword(String email);

  Future<void> logout();
}
