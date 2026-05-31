import 'package:local_auth/local_auth.dart';

enum BiometricErrorCode {
  noBiometricHardware,
  notEnrolled,
  temporaryLockout,
  biometricLockout,
  userCanceled,
  systemCanceled,
  unknown,
}

class BiometricException implements Exception {
  final BiometricErrorCode code;
  final String message;
  final String userMessage;

  const BiometricException({
    required this.code,
    required this.message,
    required this.userMessage,
  });

  factory BiometricException.fromLocalAuthException(LocalAuthException error) {
    return switch (error.code) {
      LocalAuthExceptionCode.noBiometricHardware => const BiometricException(
        code: BiometricErrorCode.noBiometricHardware,
        message: 'No biometric hardware is available.',
        userMessage: 'Perangkat tidak memiliki sensor biometrik.',
      ),
      LocalAuthExceptionCode.noBiometricsEnrolled => const BiometricException(
        code: BiometricErrorCode.notEnrolled,
        message: 'No biometrics are enrolled on this device.',
        userMessage:
            'Belum ada biometrik yang terdaftar. Daftarkan sidik jari atau wajah di Pengaturan.',
      ),
      LocalAuthExceptionCode.temporaryLockout => const BiometricException(
        code: BiometricErrorCode.temporaryLockout,
        message: 'Biometric authentication is temporarily locked.',
        userMessage:
            'Autentikasi biometrik terkunci sementara. Tunggu sebentar lalu coba lagi.',
      ),
      LocalAuthExceptionCode.biometricLockout => const BiometricException(
        code: BiometricErrorCode.biometricLockout,
        message: 'Biometric authentication is locked.',
        userMessage:
            'Biometrik terkunci. Buka kunci perangkat dengan PIN, pola, atau password terlebih dahulu.',
      ),
      LocalAuthExceptionCode.userCanceled => const BiometricException(
        code: BiometricErrorCode.userCanceled,
        message: 'User canceled biometric authentication.',
        userMessage: 'Autentikasi dibatalkan.',
      ),
      LocalAuthExceptionCode.systemCanceled => const BiometricException(
        code: BiometricErrorCode.systemCanceled,
        message: 'System canceled biometric authentication.',
        userMessage: 'Autentikasi dibatalkan oleh sistem. Coba lagi.',
      ),
      _ => BiometricException(
        code: BiometricErrorCode.unknown,
        message: error.description ?? error.toString(),
        userMessage: 'Autentikasi biometrik gagal. Coba lagi.',
      ),
    };
  }

  bool get isRetryable =>
      code == BiometricErrorCode.userCanceled ||
      code == BiometricErrorCode.systemCanceled ||
      code == BiometricErrorCode.temporaryLockout ||
      code == BiometricErrorCode.unknown;

  bool get requiresSettings => code == BiometricErrorCode.notEnrolled;

  bool get requiresFallback =>
      code == BiometricErrorCode.noBiometricHardware ||
      code == BiometricErrorCode.biometricLockout;

  @override
  String toString() => 'BiometricException($code, $message)';
}
