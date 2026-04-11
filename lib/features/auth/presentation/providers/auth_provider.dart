import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepositoryImpl();

  // ─── State ───────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _errorMessage;

  // ─── Getters ─────────────────────────────────────────────
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  // ─── Register ────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      _firebaseUser = FirebaseAuth.instance.currentUser;
      await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      _firebaseUser = FirebaseAuth.instance.currentUser;
      _status = AuthStatus.emailNotVerified;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan. Coba lagi.');
      return false;
    }
  }

  // ─── Login Email ─────────────────────────────────────────
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final success = await _repository.loginWithEmail(
        email: email,
        password: password,
      );
      _firebaseUser = FirebaseAuth.instance.currentUser;
      if (!success) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan. Coba lagi.');
      return false;
    }
  }

  // ─── Login Google ─────────────────────────────────────────
  Future<bool> loginWithGoogle() async {
    _setLoading();
    try {
      final success = await _repository.loginWithGoogle();
      _firebaseUser = FirebaseAuth.instance.currentUser;
      if (!success) {
        _setError('Login Google dibatalkan');
        return false;
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal login dengan Google: $e');
      return false;
    }
  }

  // ─── Check Email Verified ─────────────────────────────────
  Future<bool> checkEmailVerified() async {
    try {
      final success = await _repository.checkEmailVerified();
      if (success) {
        _firebaseUser = FirebaseAuth.instance.currentUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ─── Resend Verification Email ────────────────────────────
  Future<void> resendVerificationEmail() async {
    await _repository.resendVerificationEmail();
  }

  // ─── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _repository.logout();
    _firebaseUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Private Helpers ──────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(String code) => switch (code) {
        'email-already-in-use' => 'Email sudah terdaftar. Gunakan email lain.',
        'user-not-found' => 'Akun tidak ditemukan. Silakan daftar.',
        'wrong-password' => 'Password salah. Coba lagi.',
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Password terlalu lemah. Minimal 6 karakter.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        _ => 'Terjadi kesalahan. Coba lagi.',
      };
}