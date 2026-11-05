import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../providers/favorites_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<FavoritesProvider>().favoriteIds;
    final items = ItemRepository.sampleItems
        .where((item) => favoriteIds.contains(item.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Menu Favorit Anda',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.muted,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada menu favorit. Tekan ikon hati untuk menyimpan menu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _FavoriteMenuCard(item: items[index]),
            ),
    );
  }
}

class _FavoriteMenuCard extends StatelessWidget {
  const _FavoriteMenuCard({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('favorite-menu-${item.id}'),
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.detailMenu, arguments: item),
        child: SizedBox(
          height: 112,
          child: Row(
            children: [
              SizedBox(
                width: 112,
                child: item.imageUrl == null
                    ? const _FavoriteImageFallback()
                    : Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _FavoriteImageFallback(),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${item.category} · ${item.merchantName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.star,
                            size: 17,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.priceLabel,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                key: ValueKey('remove-favorite-${item.id}'),
                tooltip: 'Hapus dari favorit',
                onPressed: () =>
                    context.read<FavoritesProvider>().toggle(item.id),
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteImageFallback extends StatelessWidget {
  const _FavoriteImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.chipSelected,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
