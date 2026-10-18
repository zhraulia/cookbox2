import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
import '../data/item_repository.dart';
import '../models/item.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/cookbox_logo.dart';
import '../widgets/state_views.dart';

// (1) status tampilan
enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _heroImage =
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=85';
  static const _filterCategories = [
    'Paket Masak',
    'Segar',
    'Lauk Instan',
    'Hemat Kos',
  ];

  // (2) variabel state
  final _repository = ItemRepository();
  final _searchController = TextEditingController();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';
  Set<String> _selectedCategories = {};
  bool _showFavoritesOnly = false;

  List<Item> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final matchesQuery =
          query.isEmpty ||
          '${item.title} ${item.merchantName} ${item.category} ${item.subtitle}'
              .toLowerCase()
              .contains(query);
      final matchesCategory =
          _selectedCategories.isEmpty ||
          _selectedCategories.any(
            (category) => category.toLowerCase() == item.category.toLowerCase(),
          );
      final matchesFavorite =
          !_showFavoritesOnly ||
          context.read<FavoritesProvider>().isFavorite(item.id);
      return matchesQuery && matchesCategory && matchesFavorite;
    }).toList();
  }

  // (3) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // (4) mengambil data + menangani error
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final items = await _repository.fetchItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  Future<void> _showCategoryFilter() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var draftSelection = Set<String>.of(_selectedCategories);
    final selection = await showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filter kategori',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setSheetState(() => draftSelection = {}),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final category in _filterCategories)
                      FilterChip(
                        label: Text(category),
                        selected: draftSelection.contains(category),
                        onSelected: (selected) => setSheetState(() {
                          draftSelection = Set<String>.of(draftSelection);
                          if (selected) {
                            draftSelection.add(category);
                          } else {
                            draftSelection.remove(category);
                          }
                        }),
                        selectedColor: AppColors.chipSelected,
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTextStyles.bodySmall,
                        side: const BorderSide(color: AppColors.border),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      Set<String>.of(draftSelection),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selection != null && mounted) {
      setState(() => _selectedCategories = selection);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // (5)(6) memilih tampilan: loading / error / empty / daftar data
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const SizedBox(height: 200, child: LoadingView()),
      ViewStatus.error => ErrorView(
        message: _errorMessage,
        onRetry: _loadItems,
      ),
      ViewStatus.success => _buildList(),
    };
  }

  void _openItem(Item item) {
    Navigator.pushNamed(context, AppRoutes.detailMenu, arguments: item);
  }

  Widget _buildList() {
    final items = _filteredItems;
    if (items.isEmpty) {
      if (_searchController.text.trim().isNotEmpty ||
          _selectedCategories.isNotEmpty ||
          _showFavoritesOnly) {
        return const EmptyView(
          message: 'Menu tidak ditemukan',
          icon: Icons.search_off_rounded,
        );
      }
      return const EmptyView(message: 'Belum ada data.');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemCard(
          item: item,
          index: index,
          onTap: () => _openItem(item),
          isFavorite: context.watch<FavoritesProvider>().isFavorite(item.id),
          onToggleFavorite: () =>
              context.read<FavoritesProvider>().toggle(item.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 600 ? 460.0 : null;
            return Center(
              child: SizedBox(
                width: contentWidth,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _HomeHeader(
                            showFavorites: _showFavoritesOnly,
                            onToggleFavorites: () => setState(
                              () => _showFavoritesOnly = !_showFavoritesOnly,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SearchBar(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            onFilter: _showCategoryFilter,
                            selectedCategoryCount: _selectedCategories.length,
                            onClear: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 14),
                          const _PromoBanner(),
                          const SizedBox(height: 16),
                          const SizedBox(height: 4),
                          const _SectionHeading(
                            title: 'Paket Bahan Terlaris',
                            action: 'Lihat Semua',
                          ),
                          const SizedBox(height: 10),
                          _buildContent(),
                          if (!_showFavoritesOnly &&
                              _searchController.text.trim().isEmpty &&
                              _selectedCategories.isEmpty) ...[
                            const SizedBox(height: 20),
                            const _SectionHeading(
                              title: 'Menu Populer Mahasiswa',
                              action: 'Lagi Tren',
                            ),
                            const SizedBox(height: 10),
                            _PopularMenuGrid(items: _items, onTap: _openItem),
                          ],
                          const SizedBox(height: 14),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _HomeBottomBar(),
    );
  }
}

// Kartu item, gayanya mengikuti _AdvantageTile dari Praktikum 1
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.index,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final Item item;
  final int index;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  static const _images = [
    'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl ?? _images[index % _images.length],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _FoodImageFallback(),
                  ),
                  Positioned(
                    top: 7,
                    left: 7,
                    child: _SmallTag(
                      label: index.isEven ? 'PAKET HEMAT' : 'FAVORIT',
                      color: index.isEven
                          ? const Color(0xFFB9F1D1)
                          : const Color(0xFFFFD86F),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      key: ValueKey('favorite-${item.id}'),
                      tooltip: isFavorite
                          ? 'Hapus dari favorit'
                          : 'Tambah ke favorit',
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 30,
                        height: 30,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 15,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.muted,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 11, color: Colors.orange),
                        const SizedBox(width: 2),
                        const Text('4.9', style: TextStyle(fontSize: 8)),
                        const Spacer(),
                        Text(
                          item.priceLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.showFavorites,
    required this.onToggleFavorites,
  });

  final bool showFavorites;
  final VoidCallback onToggleFavorites;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CookBoxLogo(compact: true),
        const Spacer(),
        _HeaderAction(
          icon: showFavorites
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          onTap: onToggleFavorites,
        ),
        const SizedBox(width: 8),
        // Aksi keranjang membuka alur checkout.
        _HeaderAction(
          icon: Icons.shopping_bag_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.checkout),
        ),
        const SizedBox(width: 8),
        _HeaderAction(icon: Icons.notifications_none_rounded),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilter,
    required this.selectedCategoryCount,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  final int selectedCategoryCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.accent, size: 18),
                const SizedBox(width: 7),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 10, color: AppColors.ink),
                    decoration: const InputDecoration(
                      hintText: 'Cari menu atau UMKM...',
                      hintStyle: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    onPressed: onClear,
                    tooltip: 'Hapus pencarian',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 24,
                      height: 28,
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.muted,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 42,
          child: OutlinedButton.icon(
            key: const ValueKey('category-filter'),
            onPressed: onFilter,
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: Text(
              selectedCategoryCount == 0
                  ? 'Filter'
                  : 'Filter $selectedCategoryCount',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: selectedCategoryCount > 0
                  ? AppColors.primary
                  : AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              side: BorderSide(
                color: selectedCategoryCount > 0
                    ? AppColors.accent
                    : AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _HomeScreenState._heroImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: AppColors.primary),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xE8F16A00), Color(0x30F16A00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SmallTag(
                    label: 'SPESIAL KOS',
                    color: Color(0xFFFFD84D),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Masak Lezat, Hemat s/d\n40%',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.05,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Paket bahan serba praktis buatmu.',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Klaim Voucher  ›',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
      ],
    );
  }
}

class _PopularMenuGrid extends StatelessWidget {
  const _PopularMenuGrid({required this.items, required this.onTap});

  final List<Item> items;
  final ValueChanged<Item> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onTap(item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.imageUrl ??
                            _ItemCard._images[index % _ItemCard._images.length],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _FoodImageFallback(),
                      ),
                      Positioned(
                        top: 7,
                        left: 7,
                        child: _SmallTag(
                          label: item.category,
                          color: index.isEven
                              ? const Color(0xFFF6A85D)
                              : const Color(0xFF55C890),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          key: ValueKey('popular-favorite-${item.id}'),
                          tooltip:
                              context.watch<FavoritesProvider>().isFavorite(
                                item.id,
                              )
                              ? 'Hapus dari favorit'
                              : 'Tambah ke favorit',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints.tightFor(
                            width: 30,
                            height: 30,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              context.read<FavoritesProvider>().toggle(item.id),
                          icon: Icon(
                            context.watch<FavoritesProvider>().isFavorite(
                                  item.id,
                                )
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 15,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.merchantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.muted,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              item.priceLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            const CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.accent,
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar();

  @override
  Widget build(BuildContext context) {
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
            const _NavigationItem(
              icon: Icons.home_filled,
              label: 'Beranda',
              selected: true,
            ),
            const _NavigationItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Menu',
            ),
            _NavigationItem(
              icon: Icons.receipt_long_outlined,
              label: 'Pesanan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
            ),
            _NavigationItem(
              icon: Icons.storefront_outlined,
              label: 'UMKM',
              onTap: () => Navigator.pushNamed(context, AppRoutes.umkmList),
            ),
            _NavigationItem(
              icon: Icons.person_outline_rounded,
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
    final color = selected ? AppColors.accent : AppColors.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: color,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 15, color: AppColors.muted),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _FoodImageFallback extends StatelessWidget {
  const _FoodImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFFFE7D7),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.accent,
          size: 30,
        ),
      ),
    );
  }
}
