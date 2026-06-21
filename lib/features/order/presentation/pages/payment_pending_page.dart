import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../providers/order_provider.dart';

class PaymentPendingPage extends StatefulWidget {
  final OrderModel order;

  const PaymentPendingPage({super.key, required this.order});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage>
    with WidgetsBindingObserver {
  bool _gopayLaunched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      orderProvider.startPaymentPolling(widget.order.id);
      if (widget.order.paymentMethod == 'gopay') _launchGopay();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<OrderProvider>().stopPaymentPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _gopayLaunched) {
      context.read<OrderProvider>().checkPaymentStatus(widget.order.id);
    }
  }

  Future<void> _launchGopay() async {
    final deeplink = widget.order.gopayDeeplink;
    if (deeplink == null || deeplink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link GoPay belum tersedia')),
      );
      return;
    }

    final uri = Uri.parse(deeplink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) setState(() => _gopayLaunched = true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aplikasi GoPay tidak ditemukan di perangkat ini'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToSuccess(OrderModel order) {
    context.read<OrderProvider>().stopPaymentPolling();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.orderSuccess,
      (route) => route.settings.name == AppRouter.dashboard,
      arguments: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final paymentStatus = orderProvider.paymentCheckStatus;
    final order = orderProvider.lastOrder ?? widget.order;

    if (paymentStatus == PaymentCheckStatus.paid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToSuccess(order));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showCancelConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selesaikan Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showCancelConfirmation,
          ),
        ),
        body: order.paymentMethod == 'virtual_account'
            ? _VirtualAccountBody(
                order: order,
                paymentStatus: paymentStatus,
                onCheckStatus: () =>
                    orderProvider.checkPaymentStatus(order.id),
              )
            : _GopayBody(
                order: order,
                paymentStatus: paymentStatus,
                gopayLaunched: _gopayLaunched,
                onOpenGopay: _launchGopay,
                onCheckStatus: () =>
                    orderProvider.checkPaymentStatus(order.id),
              ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Pesanan tetap tersimpan. Kamu bisa bayar nanti di halaman Pesanan Saya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Lanjutkan Bayar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.dashboard,
                (route) => false,
              );
            },
            child: const Text('Bayar Nanti'),
          ),
        ],
      ),
    );
  }
}

class _VirtualAccountBody extends StatelessWidget {
  final OrderModel order;
  final PaymentCheckStatus paymentStatus;
  final VoidCallback onCheckStatus;

  const _VirtualAccountBody({
    required this.order,
    required this.paymentStatus,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    final vaNumber = order.vaNumber ?? '-';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PaymentHeader(
          icon: Icons.credit_card,
          color: const Color(0xFFE65100),
          title: 'Selesaikan Pembayaran via Virtual Account',
          subtitle: 'Order #${order.id} - ${CurrencyFormatter.rupiah(order.totalAmount)}',
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Nomor Virtual Account'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  vaNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: vaNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nomor VA disalin')),
                  );
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _TotalBox(total: order.totalAmount),
        const SizedBox(height: 24),
        const _SectionLabel('Cara Pembayaran'),
        const SizedBox(height: 8),
        const _StepText('Pilih menu Transfer atau Virtual Account di aplikasi bank.'),
        const _StepText('Masukkan nomor Virtual Account di atas.'),
        const _StepText('Konfirmasi nominal pembayaran dan selesaikan transaksi.'),
        const SizedBox(height: 24),
        _CheckStatusButton(
          paymentStatus: paymentStatus,
          onPressed: onCheckStatus,
        ),
      ],
    );
  }
}

class _GopayBody extends StatelessWidget {
  final OrderModel order;
  final PaymentCheckStatus paymentStatus;
  final bool gopayLaunched;
  final VoidCallback onOpenGopay;
  final VoidCallback onCheckStatus;

  const _GopayBody({
    required this.order,
    required this.paymentStatus,
    required this.gopayLaunched,
    required this.onOpenGopay,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PaymentHeader(
          icon: Icons.account_balance_wallet,
          color: const Color(0xFF00ADB5),
          title: 'Bayar dengan GoPay',
          subtitle: 'Order #${order.id} - ${CurrencyFormatter.rupiah(order.totalAmount)}',
        ),
        const SizedBox(height: 24),
        _TotalBox(total: order.totalAmount),
        const SizedBox(height: 24),
        _StepText(
          gopayLaunched
              ? 'Aplikasi GoPay sudah dibuka.'
              : 'Kamu akan diarahkan ke aplikasi GoPay.',
        ),
        const _StepText('Konfirmasi pembayaran di GoPay.'),
        const _StepText('Kembali ke aplikasi dan cek status pembayaran.'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onOpenGopay,
          icon: const Icon(Icons.open_in_new),
          label: Text(gopayLaunched ? 'Buka Kembali GoPay' : 'Buka GoPay'),
        ),
        const SizedBox(height: 12),
        _CheckStatusButton(
          paymentStatus: paymentStatus,
          onPressed: onCheckStatus,
        ),
      ],
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _PaymentHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 44, color: color),
      ),
      const SizedBox(height: 16),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Text(subtitle, textAlign: TextAlign.center),
    ],
  );
}

class _TotalBox extends StatelessWidget {
  final double total;

  const _TotalBox({required this.total});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Pembayaran'),
        Text(
          CurrencyFormatter.rupiah(total),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

class _CheckStatusButton extends StatelessWidget {
  final PaymentCheckStatus paymentStatus;
  final VoidCallback onPressed;

  const _CheckStatusButton({
    required this.paymentStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isChecking = paymentStatus == PaymentCheckStatus.checking;
    return OutlinedButton.icon(
      onPressed: isChecking ? null : onPressed,
      icon: isChecking
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: Text(isChecking ? 'Memeriksa Status...' : 'Cek Status Pembayaran'),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(fontWeight: FontWeight.bold),
  );
}

class _StepText extends StatelessWidget {
  final String text;

  const _StepText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
