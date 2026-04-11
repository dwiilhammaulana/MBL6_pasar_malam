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

  Future<void> logout();
}