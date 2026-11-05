import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../models/umkm.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/state_views.dart';
import '../utils/error_message.dart';

/// Status tampilan bagian menu: sedang memuat, berhasil, atau gagal.
enum _ViewStatus { loading, success, error }

/// Angka diberi nama agar tidak tertulis langsung di widget.
const double _iconSize = 18;
const double _menuIconSize = 28;
const double _stateHeight = 140;

class UmkmDetailScreen extends StatefulWidget {
  // Data yang DITERIMA dari layar daftar lewat arguments.
  final Umkm umkm;

  const UmkmDetailScreen({super.key, required this.umkm});

  @override
  State<UmkmDetailScreen> createState() => _UmkmDetailScreenState();
}

class _UmkmDetailScreenState extends State<UmkmDetailScreen> {
  final ItemRepository _itemRepository = ItemRepository();

  List<Item> _menus = [];
  _ViewStatus _status = _ViewStatus.loading;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    // Saat "Coba Lagi" ditekan, kembali ke tampilan loading dulu.
    if (_status != _ViewStatus.loading) {
      setState(() => _status = _ViewStatus.loading);
    }
    try {
      final items = await _itemRepository.fetchItems();
      if (!mounted) return; // layar sudah ditutup saat menunggu data
      setState(() {
        // Hanya menu milik UMKM ini, dicocokkan lewat nama toko.
        _menus = items
            .where(
              (item) =>
                  item.merchantName.toLowerCase() ==
                  widget.umkm.name.toLowerCase(),
            )
            .toList();
        _status = _ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = errorMessageOf(e);
        _status = _ViewStatus.error;
      });
    }
  }

  void _openMenu(Item item) {
    // Membuka detail menu milik M1, memakai rute yang sama dengan Home.
    Navigator.pushNamed(context, AppRoutes.detailMenu, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    final umkm = widget.umkm;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          umkm.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          // M4-02: profil UMKM
          _SectionCard(
            title: 'Tentang UMKM',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: _iconSize,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Text(
                      umkm.rating.toStringAsFixed(1),
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(width: AppSpacing.field),
                    Text(
                      umkm.category,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                Text(umkm.description, style: textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.field),

          // M4-04: lokasi dan kontak
          _SectionCard(
            title: 'Lokasi dan Kontak',
            child: Column(
              children: [
                _IconText(
                  icon: Icons.location_on_outlined,
                  text: umkm.address ?? 'Alamat tidak tersedia',
                ),
                const SizedBox(height: AppSpacing.field),
                _IconText(
                  icon: Icons.phone_outlined,
                  text: umkm.phoneNumber ?? 'Nomor tidak tersedia',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.field),

          // M4-02: menu milik UMKM ini
          _SectionCard(title: 'Menu dari UMKM Ini', child: _buildMenuContent()),
        ],
      ),
    );
  }

  /// Memilih tampilan menu berdasarkan status: loading / error / kosong / data.
  Widget _buildMenuContent() {
    return switch (_status) {
      _ViewStatus.loading => const SizedBox(
        height: _stateHeight,
        child: LoadingView(message: 'Memuat menu...'),
      ),
      _ViewStatus.error => ErrorView(
        message: _errorMessage,
        onRetry: _loadMenus,
      ),
      _ViewStatus.success => _buildMenuList(),
    };
  }

  Widget _buildMenuList() {
    if (_menus.isEmpty) {
      return const EmptyView(
        message: 'Belum ada menu terdaftar untuk toko ini.',
        icon: Icons.no_food_outlined,
      );
    }
    return Column(
      children: _menus
          .map((item) => _MenuTile(item: item, onTap: () => _openMenu(item)))
          .toList(),
    );
  }
}

/// Kotak berjudul yang dipakai berulang untuk tiap bagian layar.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.field),
          child,
        ],
      ),
    );
  }
}

/// Satu baris berisi ikon dan teks (alamat, nomor telepon).
class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: _iconSize, color: AppColors.accent),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

/// Kartu satu menu milik UMKM.
class _MenuTile extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const _MenuTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.field),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.field),
          child: Row(
            children: [
              const Icon(
                Icons.restaurant_rounded,
                size: _menuIconSize,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      item.priceLabel,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
