import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_colors.dart';

class DetailMenuScreen extends StatelessWidget {
  const DetailMenuScreen({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(item.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Detail Menu',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          key: const ValueKey('detail-back'),
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            key: const ValueKey('detail-favorite'),
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            onPressed: () => favorites.toggle(item.id),
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.accent : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 230,
              child: item.imageUrl == null
                  ? const _ImageFallback()
                  : Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _ImageFallback(),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Tag(label: item.category),
              Text(
                item.merchantName,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.priceLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Komposisi bahan'),
          const SizedBox(height: 10),
          _InfoCard(
            children: item.ingredients.isEmpty
                ? const [
                    Text(
                      'Informasi bahan belum tersedia.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ]
                : [
                    for (final ingredient in item.ingredients)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.accent,
                              size: 19,
                            ),
                            const SizedBox(width: 9),
                            Expanded(child: Text(ingredient)),
                          ],
                        ),
                      ),
                  ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: _SectionTitle(title: 'Resep')),
              if (item.cookingDuration != null)
                Text(
                  item.cookingDuration!,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoCard(
            children: item.recipeSteps.isEmpty
                ? const [
                    Text(
                      'Resep belum tersedia.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ]
                : [
                    for (
                      var index = 0;
                      index < item.recipeSteps.length;
                      index++
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: AppColors.tagBackground,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.recipeSteps[index],
                                  style: const TextStyle(height: 1.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFFFE7D7),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.accent,
          size: 44,
        ),
      ),
    );
  }
}
