import 'package:flutter/foundation.dart';

import '../services/biometric_exception.dart';
import '../services/biometric_service.dart';

class BiometricLockProvider extends ChangeNotifier {
  BiometricLockProvider({BiometricService? service})
    : _service = service ?? BiometricService();

  final BiometricService _service;

  bool _isInitialized = false;
  bool _isLocked = false;
  bool _isUnlocking = false;
  bool _isBiometricAvailable = false;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isLocked => _isLocked;
  bool get isUnlocking => _isUnlocking;
  bool get isBiometricAvailable => _isBiometricAvailable;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isBiometricAvailable = await _service.isBiometricAvailable();
    _isInitialized = true;
    notifyListeners();
  }

  void lock() {
    if (!_isBiometricAvailable || _isLocked) return;

    _isLocked = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> unlock() async {
    if (_isUnlocking) return;

    if (!_isBiometricAvailable) {
      _isLocked = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isUnlocking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.authenticate(
        reason: 'Verifikasi identitas Anda untuk membuka Pasar Malam',
      );
      _isLocked = false;
      _errorMessage = null;
    } on BiometricException catch (error) {
      _errorMessage = error.userMessage;
    } finally {
      _isUnlocking = false;
      notifyListeners();
    }
  }

  void unlockWithoutBiometric() {
    _isLocked = false;
    _errorMessage = null;
    notifyListeners();
  }
}
