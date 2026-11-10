import 'package:flutter/material.dart';

import '../data/promo_repository.dart';
import '../data/umkm_repository.dart';
import '../models/umkm_promo.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/error_message.dart';

/// Membuka lembar notifikasi promo dalam aplikasi.
Future<void> showPromoNotificationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const PromoNotificationSheet(),
  );
}

/// Status tampilan lembar notifikasi promo.
enum _SheetStatus { loading, success, error }

/// Lembar notifikasi promo UMKM yang cocok dengan preferensi pengguna.
class PromoNotificationSheet extends StatefulWidget {
  const PromoNotificationSheet({super.key});

  @override
  State<PromoNotificationSheet> createState() => _PromoNotificationSheetState();
}

class _PromoNotificationSheetState extends State<PromoNotificationSheet> {
  final UmkmRepository _umkmRepository = UmkmRepository();
  final PromoRepository _promoRepository = PromoRepository();

  _SheetStatus _status = _SheetStatus.loading;
  List<PromoMatch> _matches = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  Future<void> _loadPromos() async {
    if (_status != _SheetStatus.loading) {
      setState(() => _status = _SheetStatus.loading);
    }
    try {
      final umkmList = await _umkmRepository.fetchUmkm();
      final promos = await _promoRepository.fetchPromos();
      final matches = _promoRepository.findMatching(umkmList, promos);
      if (!mounted) return;
      setState(() {
        _matches = matches;
        _status = _SheetStatus.success;
      });
    } catch (e) {
      debugPrint('Gagal memuat notifikasi promo: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = errorMessageOf(e);
        _status = _SheetStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.top,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifikasi Promo UMKM',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.muted),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Tutup',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return switch (_status) {
      _SheetStatus.loading => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      _SheetStatus.error => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.field),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.field),
              FilledButton(
                onPressed: _loadPromos,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      _SheetStatus.success => _matches.isEmpty
          ? _buildEmpty()
          : _buildList(),
    };
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: AppSpacing.field),
            const Text(
              'Belum ada promo yang cocok',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Ikuti UMKM favoritmu dan atur pilihan promo untuk mendapatkan notifikasi promo di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        final umkm = match.umkm;
        final promo = match.promo;

        return Card(
          elevation: 0,
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: AppSpacing.field),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softAccent,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.compactRadius,
                    ),
                  ),
                  child: Text(
                    promo.type,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  umkm.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  promo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Sesuai preferensimu: ${umkm.promo?.summary}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.field),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.umkmDetail,
                        arguments: umkm,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                    ),
                    child: const Text('Lihat toko dan menu'),
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

