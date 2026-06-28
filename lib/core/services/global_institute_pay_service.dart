import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class PaymentCallbackData {
  final String status;
  final String? reference;
  final String? transactionId;

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
  });

  bool get isSuccess => status == 'success';
}

class GlobalInstitutePayService {
  static final GlobalInstitutePayService _instance =
      GlobalInstitutePayService._();

  factory GlobalInstitutePayService() => _instance;

  GlobalInstitutePayService._();

  final _callbackController =
      StreamController<PaymentCallbackData>.broadcast();
  StreamSubscription<Uri>? _linkSubscription;
  PaymentCallbackData? _pendingCallback;
  bool _initialized = false;

  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final appLinks = AppLinks();

    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, isColdStart: true);
      }
    } catch (e) {
      debugPrint('[GlobalInstitutePayService] initial link error: $e');
    }

    _linkSubscription = appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) {
        debugPrint('[GlobalInstitutePayService] stream error: $error');
      },
    );
  }

  PaymentCallbackData? consumePendingCallback() {
    final data = _pendingCallback;
    _pendingCallback = null;
    return data;
  }

  void _handleUri(Uri uri, {bool isColdStart = false}) {
    debugPrint('[GlobalInstitutePayService] URI diterima: $uri');
    debugPrint('[GlobalInstitutePayService] Cold start: $isColdStart');

    if (uri.scheme != 'pasarmalam' || uri.host != 'payment-callback') {
      debugPrint('[GlobalInstitutePayService] URI diabaikan');
      return;
    }

    debugPrint(
      '[GlobalInstitutePayService] Callback params: ${uri.queryParameters}',
    );

    final data = PaymentCallbackData(
      status: uri.queryParameters['status'] ?? 'unknown',
      reference: uri.queryParameters['reference'],
      transactionId: uri.queryParameters['transaction_id'],
    );

    if (isColdStart) {
      _pendingCallback = data;
    }

    _callbackController.add(data);
    debugPrint('[GlobalInstitutePayService] Callback status: ${data.status}');
  }

  static String buildDeeplinkUrl({
    required int orderId,
    required double amount,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': 'MCH_E_COMMERCE',
        'merchant_name': 'e_commerce',
        'amount': amount.toStringAsFixed(0),
        'description': (description != null && description.isNotEmpty)
            ? description
            : 'Order #$orderId',
        'reference': 'INV-$orderId',
        'callback': 'pasarmalam://payment-callback',
      },
    );

    final deeplink = uri.toString();
    debugPrint('[GlobalInstitutePayService] Deeplink dibuat: $deeplink');
    return deeplink;
  }

  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    await _callbackController.close();
    _initialized = false;
  }
}
