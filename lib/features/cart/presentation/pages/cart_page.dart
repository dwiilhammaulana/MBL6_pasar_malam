import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/cart_model.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CartProvider>().fetchCart();
    });
  }

  Future<void> _confirmClearCart(CartProvider cartProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus semua item dari keranjang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true) await cartProvider.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              final hasItems = cartProvider.cart?.items.isNotEmpty ?? false;
              if (!hasItems) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Hapus Semua',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmClearCart(cartProvider),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return switch (cartProvider.status) {
            CartStatus.loading ||
            CartStatus.initial => const Center(child: CircularProgressIndicator()),
            CartStatus.error => _MessageState(
              icon: Icons.error_outline,
              title: cartProvider.error ?? 'Gagal memuat keranjang',
              actionLabel: 'Coba Lagi',
              onAction: cartProvider.fetchCart,
            ),
            CartStatus.loaded => _CartContent(cartProvider: cartProvider),
          };
        },
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final CartProvider cartProvider;

  const _CartContent({required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    final cart = cartProvider.cart;
    if (cart == null || cart.items.isEmpty) {
      return _MessageState(
        icon: Icons.shopping_cart_outlined,
        title: 'Keranjang masih kosong',
        subtitle: 'Yuk tambahkan produk ke keranjang!',
        actionLabel: 'Mulai Belanja',
        onAction: () => Navigator.pop(context),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: cartProvider.fetchCart,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _CartItemCard(
                  item: item,
                  onRemove: () => cartProvider.removeItem(item.id),
                  onDecrease: () {
                    final quantity = item.quantity - 1;
                    if (quantity <= 0) {
                      cartProvider.removeItem(item.id);
                    } else {
                      cartProvider.updateItem(item.id, quantity);
                    }
                  },
                  onIncrease: () =>
                      cartProvider.updateItem(item.id, item.quantity + 1),
                );
              },
            ),
          ),
        ),
        _CartBottomBar(
          total: cart.total,
          onCheckout: () => Navigator.pushNamed(context, AppRouter.checkout),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 82,
              height: 82,
              child: item.product.imageUrl.isNotEmpty
                  ? Image.network(
                      item.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                Text(
                  item.product.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 6),
                Text(CurrencyFormatter.rupiah(item.product.price)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _QtyButton(icon: Icons.remove, onTap: onDecrease),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _QtyButton(icon: Icons.add, onTap: onIncrease),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.rupiah(item.subtotal),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: primary),
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  const _CartBottomBar({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.58),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.rupiah(total),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onCheckout,
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Icon(Icons.image_outlined),
  );
}
