import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/review.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/error_message.dart';
import '../widgets/cookbox_logo.dart';
import '../widgets/state_views.dart';

/// Halaman Status Pesanan (Pesanan Saya) dengan 4 tab: Semua, Dikemas, Dikirim, Selesai.
class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final OrderProvider _orderProvider = OrderProvider.instance;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  /// Memuat daftar pesanan dari OrderProvider / Repository jika belum ada di memori.
  Future<void> _loadOrders({bool force = false}) async {
    if (_orderProvider.orders.isNotEmpty && !force) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _orderProvider.loadOrders(forceReload: force);
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = errorMessageOf(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Membuka layar ulasan untuk pesanan yang telah selesai.
  Future<void> _openReviewScreen(Order order) async {
    // Navigasi ke ReviewScreen membawa objek Order via arguments
    final newReview = await Navigator.pushNamed<Review>(
      context,
      AppRoutes.review,
      arguments: order,
    );

    // Jika pengguna mengirimkan ulasan (result tidak null)
    if (!mounted || newReview == null) return;

    // Perbarui ulasan pada pesanan melalui provider
    _orderProvider.addReview(order.id, newReview);
  }

  /// Menampilkan lembar aksi detail ulasan pengguna (Fitur D opsional: edit/hapus).
  void _showReviewDetailsSheet(Order order) {
    final review = order.review;
    if (review == null) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ulasan Anda',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.muted),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.star,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${review.rating}.0',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.compactRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    review.comment,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radius),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(bottomSheetContext);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Hapus Ulasan?'),
                              content: const Text(
                                'Apakah Anda yakin ingin menghapus ulasan ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogCtx, false),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(dialogCtx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            _orderProvider.removeReview(order.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ulasan berhasil dihapus'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Ubah'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(bottomSheetContext);
                          _openReviewScreen(order);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Menambahkan kembali item pesanan ke keranjang belanja (Beli Lagi).
  void _reorderItem(Order order) {
    if (order.items.isEmpty) return;
    final item = order.items.first.item;
    context.read<CartProvider>().addItem(item);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} ditambahkan ke keranjang!'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
        ),
      ),
    );
  }

  /// Dialog detail pelacakan untuk status Dikemas.
  void _showPackingDetailDialog(Order order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.inventory_2_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Pesanan Dikemas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan #${order.id} sedang dipersiapkan oleh pihak UMKM.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bahan makanan dicuci, ditakar dengan higienis, dan dikemas aman untuk pengiriman kosanmu.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  /// Dialog detail pelacakan untuk status Dikirim.
  void _showShippingStatusDialog(Order order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.delivery_dining, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Pesanan Dikirim'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan #${order.id} sedang dalam perjalanan ke alamatmu.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              'Tujuan: ${order.deliveryAddress}',
              style: const TextStyle(fontSize: 12, color: AppColors.ink),
            ),
            const SizedBox(height: 4),
            const Text(
              'Estimasi tiba: ±15 - 20 menit.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingView(message: 'Memuat pesanan...'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorView(
          message: _errorMessage!,
          onRetry: _loadOrders,
        ),
      );
    }

    // Gunakan ListenableBuilder untuk memantau perubahan pada OrderProvider singleton.
    return ListenableBuilder(
      listenable: _orderProvider,
      builder: (context, _) {
        final allOrders = _orderProvider.orders;
        final dikemasOrders =
            allOrders.where((o) => o.status == OrderStatus.dikemas).toList();
        final dikirimOrders =
            allOrders.where((o) => o.status == OrderStatus.dikirim).toList();
        final selesaiOrders =
            allOrders.where((o) => o.status == OrderStatus.selesai).toList();

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: AppSpacing.page,
              title: Row(
                children: [
                  const CookBoxLogo(compact: true),
                  const Spacer(),
                  const Text(
                    'Pesanan',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.ink,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryDark,
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(98),
                child: Column(
                  children: [
                    // Baris Judul "Pesanan Saya" dan Search Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Pesanan Saya',
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pantau pasokan masak kosanmu',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.fieldFill,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search,
                              size: 19,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Tab Bar dengan badge angka dinamis
                    TabBar(
                      isScrollable: false,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.muted,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      tabs: [
                        _buildTabItem(label: 'Semua', count: allOrders.length),
                        _buildTabItem(label: 'Dikemas', count: dikemasOrders.length),
                        _buildTabItem(label: 'Dikirim', count: dikirimOrders.length),
                        _buildTabItem(label: 'Selesai', count: selesaiOrders.length),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                _buildOrderList(
                  orders: allOrders,
                  emptyMessage: 'Belum ada pesanan.',
                ),
                _buildOrderList(
                  orders: dikemasOrders,
                  emptyMessage: 'Tidak ada pesanan yang sedang dikemas.',
                ),
                _buildOrderList(
                  orders: dikirimOrders,
                  emptyMessage: 'Tidak ada pesanan yang sedang dikirim.',
                ),
                _buildOrderList(
                  orders: selesaiOrders,
                  emptyMessage: 'Belum ada pesanan yang selesai.',
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomNavBar(context),
          ),
        );
      },
    );
  }

  /// Membuat elemen Tab dengan teks label dan bulatan counter badge.
  Widget _buildTabItem({required String label, required int count}) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: AppColors.badgeBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membuat daftar kartu pesanan atau tampilan kosong (EmptyView).
  Widget _buildOrderList({
    required List<Order> orders,
    required String emptyMessage,
  }) {
    if (orders.isEmpty) {
      return EmptyView(
        message: emptyMessage,
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  /// Kartu pesanan individu sesuai dengan desain referensi modul.
  Widget _buildOrderCard(Order order) {
    final firstCartItem =
        order.items.isNotEmpty ? order.items.first : null;
    final item = firstCartItem?.item;
    final quantity = firstCartItem?.quantity ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Toko UMKM dan Status Tag
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item?.merchantName ?? 'Dapur Mitra',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Konten Produk (Foto, Judul, Porsi, Harga)
          if (item != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppSpacing.compactRadius,
                  ),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.border,
                              child: const Icon(
                                Icons.restaurant,
                                color: AppColors.muted,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.border,
                            child: const Icon(
                              Icons.restaurant,
                              color: AppColors.muted,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$quantity porsi',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.priceLabel,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          // 3. Ringkasan Total Pesanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pesanan (${order.items.length} item):',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              Text(
                order.totalLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Baris Tombol Aksi Sesuai Status
          _buildActionButtons(order),
        ],
      ),
    );
  }

  /// Tombol aksi interaktif berdasarkan status alur pesanan.
  Widget _buildActionButtons(Order order) {
    switch (order.status) {
      case OrderStatus.dikemas:
        return Align(
          alignment: Alignment.centerRight,
          child: _buildSecondaryActionButton(
            label: 'Lihat Detail',
            onPressed: () => _showPackingDetailDialog(order),
          ),
        );

      case OrderStatus.dikirim:
        return Align(
          alignment: Alignment.centerRight,
          child: _buildSecondaryActionButton(
            label: 'Lihat Status',
            onPressed: () => _showShippingStatusDialog(order),
          ),
        );

      case OrderStatus.selesai:
        final hasReview = order.isReviewed;
        return Row(
          children: [
            // Jika sudah diulas, tampilkan deretan bintang di sebelah kiri
            if (hasReview) ...[
              Row(
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < (order.review?.rating ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.star,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 4),
              Text(
                '${order.review?.rating ?? 5}.0',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const Spacer(),
            // Tombol "Beli Lagi"
            _buildLightActionButton(
              label: 'Beli Lagi',
              onPressed: () => _reorderItem(order),
            ),
            const SizedBox(width: 8),

            // Tombol "Nilai" jika belum diulas, atau "Lihat Ulasan" jika sudah
            if (!hasReview)
              _buildPrimaryActionButton(
                label: 'Nilai',
                icon: Icons.edit_note_rounded,
                onPressed: () => _openReviewScreen(order),
              )
            else
              _buildSecondaryActionButton(
                label: 'Lihat Ulasan',
                icon: Icons.visibility_outlined,
                onPressed: () => _showReviewDetailsSheet(order),
              ),
          ],
        );
    }
  }

  /// Tombol aksi primary (berwarna oranye CookBox).
  Widget _buildPrimaryActionButton({
    required String label,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol aksi secondary (berlatar krem lembut dengan teks oranye).
  Widget _buildSecondaryActionButton({
    required String label,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.softAccent,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol aksi netral (berlatar abu-abu muda).
  Widget _buildLightActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.neutralLight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Bottom Navigation Bar aplikasi dengan tab "Pesanan" aktif.
  Widget _buildBottomNavBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavigationItem(
              icon: Icons.home_filled,
              label: 'Beranda',
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              ),
            ),
            const _NavigationItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Menu',
            ),
            const _NavigationItem(
              icon: Icons.receipt_long_outlined,
              label: 'Pesanan',
              selected: true,
            ),
            _NavigationItem(
              icon: Icons.storefront_outlined,
              label: 'UMKM',
              onTap: () => Navigator.pushNamed(context, AppRoutes.umkmList),
            ),
            _NavigationItem(
              icon: Icons.help_outline_rounded,
              label: 'Bantuan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.support),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.compactRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
