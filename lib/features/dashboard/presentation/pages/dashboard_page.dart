import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  Future<void> _logout(AuthProvider auth) async {
    await auth.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  Future<void> _showAccountDialog(AuthProvider auth) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _AccountDialog(
        auth: auth,
        onLogout: () async {
          Navigator.pop(dialogContext);
          await _logout(auth);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildFixedHeader(auth),
          Expanded(
            child: RefreshIndicator(
              onRefresh: product.fetchProducts,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildModernBanner()),
                  SliverToBoxAdapter(child: _buildSectionTitle('Categories')),
                  SliverToBoxAdapter(child: _buildCategoryChips()),
                  SliverToBoxAdapter(
                    child: _buildSectionTitle('Safety Products'),
                  ),
                  _buildProductContent(product),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeader(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 10),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, ${auth.firebaseUser?.displayName ?? 'User'}!',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Cari peralatan safety hari ini?',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Akun',
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
            onPressed: () => _showAccountDialog(auth),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBanner() {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.all(20),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, primary.withValues(alpha: 0.74)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'New Collections!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Get Discount up to 50%\nfor fire equipment',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'SHOP NOW!',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: -10,
            bottom: 10,
            child: Opacity(
              opacity: 0.3,
              child: Icon(
                Icons.fire_extinguisher,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'See All',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      {'icon': Icons.fire_extinguisher, 'name': 'APAR'},
      {'icon': Icons.engineering, 'name': 'Vest'},
      {'icon': Icons.notifications_active, 'name': 'Alarm'},
      {'icon': Icons.medical_services, 'name': 'P3K'},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final isFirst = i == 0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isFirst ? colorScheme.primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isFirst
                    ? Colors.transparent
                    : Theme.of(context).dividerColor,
              ),
              boxShadow: isFirst
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.24),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  categories[i]['icon'] as IconData,
                  size: 18,
                  color: isFirst
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  categories[i]['name'] as String,
                  style: TextStyle(
                    color: isFirst
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductContent(ProductProvider product) {
    return switch (product.status) {
      ProductStatus.loading ||
      ProductStatus.initial => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      ProductStatus.error => SliverFillRemaining(
        hasScrollBody: false,
        child: _buildMessageState(
          icon: Icons.error_outline,
          title: product.error ?? AppStrings.errorGeneral,
          actionLabel: AppStrings.retry,
          onAction: product.fetchProducts,
        ),
      ),
      ProductStatus.loaded when product.products.isEmpty => SliverFillRemaining(
        hasScrollBody: false,
        child: _buildMessageState(
          icon: Icons.inventory_2_outlined,
          title: AppStrings.emptyProducts,
          actionLabel: AppStrings.retry,
          onAction: product.fetchProducts,
        ),
      ),
      ProductStatus.loaded => _buildProductGrid(product.products),
    };
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProductCard(products[index]),
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.36,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.favorite_border,
                  color: theme.unselectedWidgetColor,
                  size: 24,
                ),
              ),
              Positioned(
                bottom: -15,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  radius: 18,
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rp${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '5.0 (2)',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.58),
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

class _AccountDialog extends StatelessWidget {
  final AuthProvider auth;
  final VoidCallback onLogout;

  const _AccountDialog({required this.auth, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = auth.firebaseUser;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.account_circle_outlined, color: colorScheme.primary),
          const SizedBox(width: 10),
          const Text('Akun'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.displayName ?? 'User',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Email belum tersedia',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.64),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 20,
                    color: isDark ? Colors.amber : theme.unselectedWidgetColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDark ? 'Mode Gelap' : 'Mode Terang',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
              Switch(
                value: isDark,
                onChanged: (_) => context.read<ThemeProvider>().toggle(),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        FilledButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text(AppStrings.logout),
        ),
      ],
    );
  }
}
