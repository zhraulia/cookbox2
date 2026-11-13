import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import '../widgets/state_views.dart';
import 'cart_checkout_screen.dart';

/// Layar keranjang belanja yang mengelompokkan item per UMKM mitra.
/// Pengguna dapat mengelola item dan melakukan checkout secara terpisah per UMKM.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final itemsByMerchant = cartProvider.itemsByMerchant;
    final isCartEmpty = itemsByMerchant.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: isCartEmpty
          ? const EmptyView(
              message: 'Keranjang belanja kamu masih kosong',
              icon: Icons.shopping_cart_outlined,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                for (final entry in itemsByMerchant.entries)
                  _MerchantCartGroup(
                    merchantName: entry.key,
                    items: entry.value,
                    subtotal: cartProvider.subtotalFor(entry.key),
                    onCheckout: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.checkout,
                        arguments: entry.key,
                      );
                    },
                    onRemove: (itemId) =>
                        context.read<CartProvider>().removeItem(itemId),
                    onDecrease: (itemId) =>
                        context.read<CartProvider>().decreaseQuantity(itemId),
                    onIncrease: (itemId) =>
                        context.read<CartProvider>().increaseQuantity(itemId),
                  ),
              ],
            ),
    );
  }
}

/// Kartu kelompok keranjang untuk satu UMKM.
class _MerchantCartGroup extends StatelessWidget {
  const _MerchantCartGroup({
    required this.merchantName,
    required this.items,
    required this.subtotal,
    required this.onCheckout,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String merchantName;
  final List<CartItem> items;
  final int subtotal;
  final VoidCallback onCheckout;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onDecrease;
  final ValueChanged<String> onIncrease;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.section),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul kelompok = Nama UMKM
            Row(
              children: [
                const Icon(Icons.storefront_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.field),
                Expanded(
                  child: Text(
                    merchantName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Text(
                  '${items.length} Menu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.section),
            // Daftar item beserta kontrol jumlah dan tombol hapus
            for (final cartItem in items)
              CartItemCard(
                cartItem: cartItem,
                onRemove: () => onRemove(cartItem.item.id),
                onDecrease: () => onDecrease(cartItem.item.id),
                onIncrease: () => onIncrease(cartItem.item.id),
              ),
            const Divider(height: AppSpacing.section),
            // Subtotal kelompok dan tombol checkout per kelompok
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtotal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.rupiah(subtotal),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: onCheckout,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('Checkout'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
