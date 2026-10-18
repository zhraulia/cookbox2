import 'package:flutter/material.dart';

import '../data/faq_repository.dart';
import '../models/faq_item.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Layar Pusat Bantuan & FAQ CookBox.
/// Data FAQ dikelola terpisah melalui [FaqRepository] dan [FaqItem],
/// serta seluruh tipografi dan warna mengacu pada [AppTextStyles] dan [AppColors].
class SupportScreen extends StatefulWidget {
  const SupportScreen({
    super.key,
    this.faqRepository = const FaqRepository(),
  });

  final FaqRepository faqRepository;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final List<FaqItem> _faqs;

  @override
  void initState() {
    super.initState();
    _faqs = widget.faqRepository.getFaqs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pusat Bantuan', style: AppTextStyles.titleMedium),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          // Banner Bantuan
          Container(
            padding: const EdgeInsets.all(AppSpacing.page),
            decoration: BoxDecoration(
              color: AppColors.softAccent,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.infoAccent),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.field),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ada pertanyaan?',
                        style: AppTextStyles.titleSmall,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Temukan jawaban cepat seputar pemesanan dan layanan CookBox di bawah ini.',
                        style: AppTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),

          // Judul Seksi FAQ
          const Text(
            'Pertanyaan Populer (FAQ)',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.field),

          // Daftar FAQ yang diambil dari FaqRepository
          ..._faqs.map((faq) => _FaqCard(faq: faq)),

          const SizedBox(height: AppSpacing.section),

          // Kontak CS
          Container(
            padding: const EdgeInsets.all(AppSpacing.page),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Butuh Bantuan Lebih Lanjut?',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tim CookBox siap membantu kebutuhan memasak dan pesananmu setiap hari.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.field),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.compactRadius),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Layanan obrolan langsung segera hadir!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Hubungi Layanan Pelanggan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SupportNavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Menu',
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (r) => false,
                ),
              ),
              _SupportNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Pesanan',
                onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
              ),
              _SupportNavItem(
                icon: Icons.storefront_outlined,
                label: 'UMKM',
                onTap: () => Navigator.pushNamed(context, AppRoutes.umkmList),
              ),
              const _SupportNavItem(
                icon: Icons.help_outline_rounded,
                label: 'Bantuan',
                selected: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.faq});

  final FaqItem faq;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.field),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.compactRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.muted,
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.badgeBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              faq.category,
              style: AppTextStyles.badge,
            ),
          ),
          title: Text(
            faq.question,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: AppTextStyles.bodyMuted.copyWith(height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportNavItem extends StatelessWidget {
  const _SupportNavItem({
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
