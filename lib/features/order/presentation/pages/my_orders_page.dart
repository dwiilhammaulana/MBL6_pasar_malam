import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../providers/order_provider.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          return switch (orderProvider.ordersStatus) {
            OrderStatus.initial ||
            OrderStatus.loading => const Center(child: CircularProgressIndicator()),
            OrderStatus.error => _MessageState(
              title: orderProvider.error ?? 'Gagal memuat pesanan',
              onRetry: orderProvider.fetchOrders,
            ),
            OrderStatus.success when orderProvider.orders.isEmpty =>
              _MessageState(
                title: 'Belum ada pesanan',
                icon: Icons.receipt_long_outlined,
                onRetry: orderProvider.fetchOrders,
              ),
            OrderStatus.success => RefreshIndicator(
              onRefresh: orderProvider.fetchOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orderProvider.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _OrderCard(order: orderProvider.orders[index]),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Menunggu Pembayaran',
    'processing' => 'Sedang Diproses',
    'shipped' => 'Dikirim',
    'delivered' => 'Diterima',
    'cancelled' => 'Dibatalkan',
    _ => status,
  };

  Color _statusColor(String status) => switch (status) {
    'pending' => Colors.orange,
    'processing' => Colors.blue,
    'shipped' => Colors.purple,
    'delivered' => Colors.green,
    'cancelled' => Colors.red,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Total: ${CurrencyFormatter.rupiah(order.totalAmount)}'),
          const SizedBox(height: 4),
          Text('Metode: ${order.paymentMethod}'),
          if (order.createdAt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Tanggal: ${order.createdAt}'),
          ],
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<void> Function() onRetry;

  const _MessageState({
    required this.title,
    this.icon = Icons.error_outline,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}
