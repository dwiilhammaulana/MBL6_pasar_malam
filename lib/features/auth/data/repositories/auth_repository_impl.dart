import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/secure_storage.dart';
import '../models/auth_response_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _tempEmail;
  String? _tempPassword;

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.sendEmailVerification();
    _tempEmail = email;
    _tempPassword = password;
    return true;
  }

  @override
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!(credential.user?.emailVerified ?? false)) {
      return false;
    }
    return verifyTokenToBackend();
  }

  @override
  Future<bool> loginWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    return verifyTokenToBackend();
  }

  @override
  Future<bool> verifyTokenToBackend() async {
    try {
      final firebaseToken = await _auth.currentUser?.getIdToken();
      if (firebaseToken == null) return false;

      final response = await DioClient.instance.post(
        ApiConstants.verifyToken,
        data: {'firebase_token': firebaseToken},
      );
      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (authResponse.accessToken.isEmpty) return false;

      await SecureStorageService.saveToken(authResponse.accessToken);
      return true;
    } catch (e) {
      debugPrint('Error verifyTokenToBackend: $e');
      return false;
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;
    if (user?.emailVerified ?? false) {
      if (_tempEmail != null && _tempPassword != null) {
        await _auth.signInWithEmailAndPassword(
          email: _tempEmail!,
          password: _tempPassword!,
        );
        _tempEmail = null;
        _tempPassword = null;
      }
      return verifyTokenToBackend();
    }
    return false;
  }

  @override
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await SecureStorageService.clearAll();
  }
}
