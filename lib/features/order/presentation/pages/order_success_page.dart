import 'package:flutter/material.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';

class OrderSuccessPage extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessPage({super.key, required this.order});

  String _paymentMethodLabel(String method) => switch (method) {
    'gopay' => 'GoPay',
    'global_institute_pay' => 'Dompet Jajan',
    'bank_transfer' => 'Transfer Bank',
    'virtual_account' => 'Virtual Account',
    _ => method,
  };

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Menunggu Pembayaran',
    'processing' => 'Sedang Diproses',
    'shipped' => 'Dikirim',
    'delivered' => 'Diterima',
    'cancelled' => 'Dibatalkan',
    _ => status,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPaid = order.isPaid;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: (isPaid ? Colors.green : colorScheme.primary)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.receipt_long,
                  color: isPaid ? Colors.green : colorScheme.primary,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPaid ? 'Pembayaran Berhasil!' : 'Pesanan Dibuat',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${order.id}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Metode Pembayaran',
                  value: _paymentMethodLabel(order.paymentMethod),
                  icon: Icons.payment,
                ),
                _InfoRow(
                  label: 'Total Pembayaran',
                  value: CurrencyFormatter.rupiah(order.totalAmount),
                  icon: Icons.attach_money,
                  valueBold: true,
                ),
                _InfoRow(
                  label: 'Status',
                  value: _statusLabel(order.status),
                  icon: Icons.local_shipping_outlined,
                ),
                _InfoRow(
                  label: 'Alamat',
                  value: order.shippingAddress,
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.dashboard,
                (route) => false,
              ),
              child: const Text('Kembali ke Dashboard'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.myOrders),
              child: const Text('Lihat Pesanan Saya'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const Divider(height: 22),
        ],
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool valueBold;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
