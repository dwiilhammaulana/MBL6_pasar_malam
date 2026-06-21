import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedPaymentMethod;

  static const _paymentOptions = [
    _PaymentOption(
      value: 'gopay',
      label: 'GoPay',
      subtitle: 'Bayar instant dengan GoPay',
      icon: Icons.account_balance_wallet,
      iconColor: Color(0xFF00ADB5),
    ),
    _PaymentOption(
      value: 'bank_transfer',
      label: 'Transfer Bank',
      subtitle: 'BCA, Mandiri, BNI, BRI',
      icon: Icons.account_balance,
      iconColor: Color(0xFF1565C0),
    ),
    _PaymentOption(
      value: 'virtual_account',
      label: 'Virtual Account',
      subtitle: 'Nomor VA otomatis digenerate',
      icon: Icons.credit_card,
      iconColor: Color(0xFFE65100),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CartProvider>().fetchCart();
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.cart == null || cartProvider.cart!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await orderProvider.checkout(
      shippingAddress: _addressCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      paymentMethod: _selectedPaymentMethod!,
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Checkout gagal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await cartProvider.clearCart();
    if (!mounted) return;
    final order = orderProvider.lastOrder!;
    final needsPayment =
        order.paymentMethod == 'virtual_account' || order.paymentMethod == 'gopay';

    Navigator.pushNamedAndRemoveUntil(
      context,
      needsPayment ? AppRouter.paymentPending : AppRouter.orderSuccess,
      (route) => route.settings.name == AppRouter.dashboard,
      arguments: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    final isLoading = context.watch<OrderProvider>().isCheckingOut;
    final items = cart?.items ?? [];
    final isCartLoading =
        cartProvider.status == CartStatus.loading ||
        cartProvider.status == CartStatus.initial;
    final canCheckout = items.isNotEmpty && !isLoading && !isCartLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle(title: 'Ringkasan Pesanan'),
            const SizedBox(height: 10),
            if (isCartLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (cartProvider.status == CartStatus.error)
              _InlineError(
                message: cartProvider.error ?? 'Gagal memuat keranjang',
                onRetry: cartProvider.fetchCart,
              )
            else if (items.isEmpty)
              const Text('Keranjang kosong')
            else
              ...items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.product.name),
                  subtitle: Text('${item.quantity} x ${CurrencyFormatter.rupiah(item.product.price)}'),
                  trailing: Text(CurrencyFormatter.rupiah(item.subtotal)),
                ),
              ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  CurrencyFormatter.rupiah(cart?.total ?? 0),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionTitle(title: 'Alamat Pengiriman'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan alamat lengkap',
              ),
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Alamat wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Catatan'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Catatan opsional',
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Metode Pembayaran'),
            const SizedBox(height: 10),
            ..._paymentOptions.map(
              (option) => _PaymentOptionCard(
                option: option,
                isSelected: _selectedPaymentMethod == option.value,
                onTap: () => setState(() => _selectedPaymentMethod = option.value),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: canCheckout ? _placeOrder : null,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    ),
  );
}

class _InlineError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _PaymentOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

class _PaymentOptionCard extends StatelessWidget {
  final _PaymentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(option.icon, color: option.iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(option.subtitle),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
