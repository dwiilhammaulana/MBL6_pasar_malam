import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import 'biometric_exception.dart';

class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return _auth.getAvailableBiometrics();
    } on LocalAuthException {
      return const <BiometricType>[];
    } on PlatformException {
      return const <BiometricType>[];
    }
  }

  Future<bool> authenticate({
    String reason = 'Verifikasi identitas Anda untuk membuka aplikasi',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw const BiometricException(
          code: BiometricErrorCode.noBiometricHardware,
          message: 'Biometric authentication is not available.',
          userMessage: 'Perangkat tidak mendukung autentikasi biometrik.',
        );
      }

      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        throw const BiometricException(
          code: BiometricErrorCode.notEnrolled,
          message: 'No biometric credentials are enrolled.',
          userMessage:
              'Belum ada biometrik yang terdaftar. Daftarkan sidik jari atau wajah di Pengaturan.',
        );
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Verifikasi Diperlukan',
            signInHint: 'Tempelkan jari atau arahkan wajah',
            cancelButton: 'Batal',
          ),
        ],
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );

      if (!didAuthenticate) {
        throw const BiometricException(
          code: BiometricErrorCode.userCanceled,
          message: 'Authentication returned false.',
          userMessage: 'Autentikasi dibatalkan.',
        );
      }

      return true;
    } on BiometricException {
      rethrow;
    } on LocalAuthException catch (error) {
      throw BiometricException.fromLocalAuthException(error);
    } on PlatformException catch (error) {
      throw BiometricException(
        code: BiometricErrorCode.unknown,
        message: error.message ?? error.code,
        userMessage: 'Autentikasi biometrik gagal. Coba lagi.',
      );
    } catch (error) {
      throw BiometricException(
        code: BiometricErrorCode.unknown,
        message: error.toString(),
        userMessage: 'Autentikasi biometrik gagal. Coba lagi.',
      );
    }
  }
}
