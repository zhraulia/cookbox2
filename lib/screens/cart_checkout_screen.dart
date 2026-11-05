import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/delivery_location.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/state_views.dart';

// Opsi pengantaran dan biaya pengantaran default sesuai modul.
const String _deliveryOption = 'Diantar ke Alamat';
const String _pickupOption = 'Ambil ke UMKM';
const int _deliveryFee = 5000;

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  String _deliveryMethod = _deliveryOption;
  String? _selectedPayment;
  bool _isSubmitting = false;

  // State lokasi pengantaran yang dipilih via peta
  DeliveryLocation? _deliveryLocation;

  static const _paymentOptions = [
    (
      name: 'QRIS/Saldo Digital',
      description: 'Gopay, OVO, ShopeePay, DANA',
      icon: Icons.qr_code_2_rounded,
    ),
    (
      name: 'Transfer Bank Virtual Account',
      description: 'BCA, Mandiri, BRI, BNI',
      icon: Icons.account_balance_outlined,
    ),
    (
      name: 'Tunai Saat Terima/COD',
      description: 'Bayar langsung saat pesanan diterima',
      icon: Icons.payments_outlined,
    ),
  ];

  /// Membuka layar peta pemilihan lokasi pengantaran.
  Future<void> _openLocationPicker() async {
    final result = await Navigator.pushNamed<DeliveryLocation>(
      context,
      AppRoutes.locationPicker,
      arguments: _deliveryLocation,
    );

    if (!mounted) return;
    if (result != null) {
      setState(() => _deliveryLocation = result);
    }
  }

  Future<void> _confirmOrder(CartProvider cartProvider) async {
    // Validasi: lokasi pengantaran wajib dipilih jika metode pengantaran 'Diantar'
    if (_deliveryMethod == _deliveryOption && _deliveryLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tentukan lokasi pengantaran terlebih dahulu'),
        ),
      );
      return;
    }

    final paymentMethod = _selectedPayment;
    if (paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
        ),
      );
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final items = List<CartItem>.unmodifiable(cartProvider.items);
    final subtotal = cartProvider.subtotalPrice;
    final deliveryFee = _deliveryMethod == _deliveryOption ? _deliveryFee : 0;
    final total = subtotal + deliveryFee;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Membuat pesanan dengan data lokasi dari _deliveryLocation
      final order = Order(
        items: items,
        deliveryMethod: _deliveryMethod,
        deliveryAddress: _deliveryMethod == _deliveryOption
            ? _deliveryLocation!.address
            : 'Ambil di UMKM',
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        deliveryLatitude: _deliveryMethod == _deliveryOption
            ? _deliveryLocation!.latitude
            : null,
        deliveryLongitude: _deliveryMethod == _deliveryOption
            ? _deliveryLocation!.longitude
            : null,
      );

      context.read<CartProvider>().clear();
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.orderConfirmation,
        arguments: order,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan gagal dikonfirmasi: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isCartEmpty = cartProvider.items.isEmpty;
    final deliveryFee = _deliveryMethod == _deliveryOption ? _deliveryFee : 0;
    final total = cartProvider.subtotalPrice + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Checkout Keranjang',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: isCartEmpty
          ? const EmptyView(
              message: 'Keranjang kamu masih kosong',
              icon: Icons.shopping_cart_outlined,
            )
          : IgnorePointer(
              ignoring: _isSubmitting,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.page),
                children: [
                  _CartItemsSection(
                    items: cartProvider.items,
                    onRemove: (itemId) =>
                        context.read<CartProvider>().removeItem(itemId),
                    onDecrease: (itemId) =>
                        context.read<CartProvider>().decreaseQuantity(itemId),
                    onIncrease: (itemId) =>
                        context.read<CartProvider>().increaseQuantity(itemId),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _DeliveryMethodSection(
                    selectedMethod: _deliveryMethod,
                    onMethodChanged: (method) {
                      setState(() => _deliveryMethod = method);
                    },
                    addressText: _deliveryLocation?.address ??
                        'Belum ada lokasi, ketuk Ubah Alamat',
                    onChangeAddress: _openLocationPicker,
                    merchantNames: _merchantNames(cartProvider),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _PaymentMethodSection(
                    paymentOptions: _paymentOptions,
                    selectedPayment: _selectedPayment,
                    onSelectPayment: (method) {
                      setState(() => _selectedPayment = method);
                    },
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _PaymentSummarySection(
                    subtotal: cartProvider.subtotalPrice,
                    deliveryFee: deliveryFee,
                    total: total,
                  ),
                  const SizedBox(height: AppSpacing.section),
                ],
              ),
            ),
      bottomNavigationBar: isCartEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.field,
                AppSpacing.page,
                AppSpacing.page,
              ),
              child: FilledButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _confirmOrder(cartProvider),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : Text('Konfirmasi Pesanan (${_formatRupiah(total)})'),
              ),
            ),
    );
  }

  List<String> _merchantNames(CartProvider cartProvider) => cartProvider.items
      .map((cartItem) => cartItem.item.merchantName)
      .toSet()
      .toList();
}

// ==========================================
// SECTIONS & COMPONENTS
// ==========================================

/// Section daftar item di keranjang beserta kontrol jumlah dan tombol hapus.
class _CartItemsSection extends StatelessWidget {
  const _CartItemsSection({
    required this.items,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  final List<CartItem> items;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onDecrease;
  final ValueChanged<String> onIncrease;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Rincian Paket Masak (${items.length} Menu)',
        ),
        const SizedBox(height: AppSpacing.field),
        for (final cartItem in items)
          _CartItemCard(
            cartItem: cartItem,
            onRemove: () => onRemove(cartItem.item.id),
            onDecrease: () => onDecrease(cartItem.item.id),
            onIncrease: () => onIncrease(cartItem.item.id),
          ),
      ],
    );
  }
}

/// Section pilihan pengantaran (Diantar / Ambil Sendiri) dan kartu alamat/pickup.
class _DeliveryMethodSection extends StatelessWidget {
  const _DeliveryMethodSection({
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.addressText,
    required this.onChangeAddress,
    required this.merchantNames,
  });

  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final String addressText;
  final VoidCallback onChangeAddress;
  final List<String> merchantNames;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Pilihan Pengantaran'),
        const SizedBox(height: AppSpacing.field),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: _deliveryOption,
              label: Text('Diantar'),
              icon: Icon(Icons.delivery_dining_outlined),
            ),
            ButtonSegment(
              value: _pickupOption,
              label: Text('Ambil Sendiri'),
              icon: Icon(Icons.storefront_outlined),
            ),
          ],
          selected: {selectedMethod},
          onSelectionChanged: (selection) => onMethodChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.field),
        if (selectedMethod == _deliveryOption)
          _AddressCard(
            addressText: addressText,
            onChangeAddress: onChangeAddress,
          )
        else
          _PickupCard(merchantNames: merchantNames),
      ],
    );
  }
}

/// Section pilihan metode pembayaran menggunakan kartu reusable.
class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.paymentOptions,
    required this.selectedPayment,
    required this.onSelectPayment,
  });

  final List<({String name, String description, IconData icon})> paymentOptions;
  final String? selectedPayment;
  final ValueChanged<String> onSelectPayment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Metode Pembayaran'),
        const SizedBox(height: AppSpacing.field),
        for (final option in paymentOptions)
          _PaymentOptionCard(
            icon: option.icon,
            title: option.name,
            subtitle: option.description,
            isSelected: selectedPayment == option.name,
            onTap: () => onSelectPayment(option.name),
          ),
      ],
    );
  }
}

/// Section ringkasan rincian pembayaran (subtotal, ongkir, total).
class _PaymentSummarySection extends StatelessWidget {
  const _PaymentSummarySection({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  final int subtotal;
  final int deliveryFee;
  final int total;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.section),
          _SummaryRow(
            label: 'Subtotal Paket',
            value: _formatRupiah(subtotal),
          ),
          const SizedBox(height: AppSpacing.field),
          _SummaryRow(
            label: 'Ongkos Kirim',
            value: _formatRupiah(deliveryFee),
          ),
          const Divider(height: AppSpacing.section),
          _SummaryRow(
            label: 'Total Pembayaran',
            value: _formatRupiah(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.cartItem,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  final CartItem cartItem;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final item = cartItem.item;
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.field),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.field),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.compactRadius),
              child: SizedBox(
                width: 76,
                height: 76,
                child: item.imageUrl == null
                    ? const _CartImageFallback()
                    : Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const _CartImageFallback(),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.field),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus ${item.title}',
                        visualDensity: VisualDensity.compact,
                        onPressed: onRemove,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.merchantName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.priceLabel} / porsi',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      _QuantityControl(
                        quantity: cartItem.quantity,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Kurangi jumlah',
            visualDensity: VisualDensity.compact,
            onPressed: onDecrease,
            icon: const Icon(Icons.remove, size: 18),
          ),
          Text('$quantity', style: Theme.of(context).textTheme.bodyLarge),
          IconButton(
            tooltip: 'Tambah jumlah',
            visualDensity: VisualDensity.compact,
            onPressed: onIncrease,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.addressText,
    required this.onChangeAddress,
  });

  final String addressText;
  final VoidCallback onChangeAddress;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.field),
          Expanded(child: Text(addressText)),
          TextButton(
            onPressed: onChangeAddress,
            child: const Text('Ubah Alamat'),
          ),
        ],
      ),
    );
  }
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.merchantNames});

  final List<String> merchantNames;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.storefront_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.field),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantNames.join(', '),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Jam operasional: 08.00–20.00',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.field),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.headlineSmall
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: child,
      ),
    );
  }
}

class _CartImageFallback extends StatelessWidget {
  const _CartImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.infoBackground,
      child: Center(
        child: Icon(Icons.restaurant_outlined, color: AppColors.primary),
      ),
    );
  }
}

String _formatRupiah(int amount) {
  final digits = amount.toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'Rp $grouped';
}
