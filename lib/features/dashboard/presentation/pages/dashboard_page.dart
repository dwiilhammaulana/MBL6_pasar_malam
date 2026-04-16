import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/product_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Warna tema hijau konsisten
  final Color greenTheme = const Color(0xFF004D40);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. FIXED HEADER
          _buildFixedHeader(auth),

          // 2. SCROLLABLE CONTENT
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => product.fetchProducts(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Banner Baru (Style New Collections)
                  SliverToBoxAdapter(child: _buildModernBanner()),

                  // Judul Kategori & See All
                  SliverToBoxAdapter(child: _buildSectionTitle('Categories')),

                  // Category Chips (Horizontal Scroll)
                  SliverToBoxAdapter(child: _buildCategoryChips()),

                  // Judul Produk
                  SliverToBoxAdapter(child: _buildSectionTitle('Safety Products')),

                  // Grid Produk
                  _buildProductGrid(product),
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
      decoration: BoxDecoration(
        color: greenTheme,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, ${auth.firebaseUser?.displayName ?? 'User'}!',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Cari peralatan safety hari ini?', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.login),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [greenTheme, greenTheme.withOpacity(0.7)],
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
                const Text('New Collections!', 
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('Get Discount up to 50%\nfor fire equipment', 
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('SHOP NOW!', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
          // Gambar dekoratif di kanan banner (contoh APAR atau Helm)
          Positioned(
            right: -10, bottom: 10,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.fire_extinguisher, size: 150, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('See All', style: TextStyle(color: greenTheme, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
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
          bool isFirst = i == 0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isFirst ? greenTheme : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(25),
              boxShadow: isFirst ? [BoxShadow(color: greenTheme.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Row(
              children: [
                Icon(categories[i]['icon'] as IconData, 
                     size: 18, color: isFirst ? Colors.white : Colors.black87),
                const SizedBox(width: 8),
                Text(categories[i]['name'] as String, 
                     style: TextStyle(color: isFirst ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider product) {
    if (product.status == ProductStatus.loading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.62, // Ratio aman untuk menghindari garis kuning
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final p = product.products[index];
            return _buildProductCard(p);
          },
          childCount: product.products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.network(p.imageUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
              const Positioned(top: 10, right: 10, child: Icon(Icons.favorite_border, color: Colors.grey, size: 24)),
              Positioned(
                bottom: -15, right: 12,
                child: CircleAvatar(
                  backgroundColor: greenTheme,
                  radius: 18,
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
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
                Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Text('Rp${p.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: greenTheme)),
                const SizedBox(height: 5),
                Row(
                  children: const [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text('5.0 (2)', style: TextStyle(fontSize: 11, color: Colors.grey)),
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