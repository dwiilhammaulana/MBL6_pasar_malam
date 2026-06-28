import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/order/data/models/order_model.dart';
import '../../features/order/presentation/pages/checkout_page.dart';
import '../../features/order/presentation/pages/my_orders_page.dart';
import '../../features/order/presentation/pages/order_success_page.dart';
import '../../features/order/presentation/pages/payment_pending_page.dart';
import '../../features/order/presentation/providers/order_provider.dart';
import '../services/global_institute_pay_service.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String myOrders = '/my-orders';
  static const String paymentPending = '/payment-pending';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    dashboard: (_) => const AuthGuard(child: DashboardPage()),
    cart: (_) => const AuthGuard(child: CartPage()),
    checkout: (_) => const AuthGuard(child: CheckoutPage()),
    myOrders: (_) => const AuthGuard(child: MyOrdersPage()),
    orderSuccess: (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return AuthGuard(child: OrderSuccessPage(order: order));
    },
    paymentPending: (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return AuthGuard(child: PaymentPendingPage(order: order));
    },
  };
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _checkAuth);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    final isAuthenticated = await context.read<AuthProvider>().restoreSession();
    if (!mounted) return;

    if (!isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRouter.login);
      return;
    }

    final handledCallback = await _handleColdStartPaymentCallback();
    if (!mounted || handledCallback) return;

    Navigator.pushReplacementNamed(context, AppRouter.dashboard);
  }

  Future<bool> _handleColdStartPaymentCallback() async {
    final callback = GlobalInstitutePayService().consumePendingCallback();
    if (callback == null || !callback.isSuccess) return false;

    final orderId = _orderIdFromReference(callback.reference);
    if (orderId == null) return false;

    final order = await context.read<OrderProvider>().markPaymentPaid(orderId);
    if (!mounted || order == null) return false;

    Navigator.pushReplacementNamed(
      context,
      AppRouter.orderSuccess,
      arguments: order,
    );
    return true;
  }

  int? _orderIdFromReference(String? reference) {
    if (reference == null || reference.isEmpty) return null;
    final match = RegExp(r'^INV-(\d+)$').firstMatch(reference);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    return switch (status) {
      AuthStatus.authenticated => child,
      AuthStatus.emailNotVerified => const VerifyEmailPage(),
      AuthStatus.initial || AuthStatus.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _ => const LoginPage(),
    };
  }
}
