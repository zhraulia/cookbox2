import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/review.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/error_message.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/state_views.dart';

/// Halaman form untuk memberikan atau memperbarui ulasan pesanan.
class ReviewScreen extends StatefulWidget {
  final Order order;

  const ReviewScreen({super.key, required this.order});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();

  int _rating = 0;
  String? _ratingError;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika pesanan sudah memiliki ulasan (mode edit), inisialisasi data sebelumnya.
    final existingReview = widget.order.review;
    if (existingReview != null) {
      _rating = existingReview.rating;
      _reviewController.text = existingReview.comment;
    }
  }

  @override
  void dispose() {
    // Controller wajib dibuang saat layar ditutup agar tidak memory leak.
    _reviewController.dispose();
    super.dispose();
  }

  /// Label teks responsif yang berubah sesuai rating bintang yang dipilih.
  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Bagus';
      case 5:
        return 'Sangat Puas!';
      default:
        return 'Pilih bintang untuk menilai';
    }
  }

  /// Memvalidasi input dan mengirimkan ulasan.
  Future<void> _submitReview() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard saat tombol ditekan

    // Validasi rating bintang menggunakan fungsi di Validators.
    final ratingError = Validators.rating(_rating);
    setState(() => _ratingError = ratingError);

    // Validasi form ulasan teks (minimal 10 karakter, maksimal 200).
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (ratingError != null || !isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulasi proses pengiriman ulasan asinkron (±500 ms).
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final review = Review(
        id: widget.order.review?.id ??
            'REV-${DateTime.now().millisecondsSinceEpoch}',
        rating: _rating,
        comment: _reviewController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Tampilkan feedback SnackBar keberhasilan.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ulasan terkirim!'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      // Kembalikan objek Review yang baru ke layar pemanggil (OrderStatusScreen).
      Navigator.pop(context, review);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = errorMessageOf(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil item pertama dari pesanan sebagai ringkasan tampilan.
    final firstCartItem = widget.order.items.isNotEmpty
        ? widget.order.items.first
        : null;
    final item = firstCartItem?.item;

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        // Cegah pengguna kembali jika sedang proses pengiriman ulasan.
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.ink),
            onPressed: _isLoading ? null : () => Navigator.maybePop(context),
          ),
          title: const Text(
            'Beri Ulasan',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.ink),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.page),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryDark,
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.surface,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Ringkasan Pesanan
                  if (item != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.compactRadius,
                            ),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: item.imageUrl != null
                                  ? Image.network(
                                      item.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
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
                          const SizedBox(width: AppSpacing.field),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.storefront_outlined,
                                      size: 13,
                                      color: AppColors.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        item.merchantName,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${firstCartItem?.quantity ?? 1} porsi',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.fieldVertical),

                  // 2. Kartu Rating Bintang
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                      vertical: AppSpacing.section,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Bagaimana pesananmu?',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.section),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            final isSelected = starIndex <= _rating;
                            return IconButton(
                              iconSize: 38,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isSelected
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: isSelected
                                    ? const Color(0xFFFFB800)
                                    : const Color(0xFFCED1DE),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _rating = starIndex;
                                        _ratingError = null;
                                      });
                                    },
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          _ratingLabel,
                          style: TextStyle(
                            color: _rating > 0
                                ? AppColors.ink
                                : AppColors.muted,
                            fontSize: 12,
                            fontWeight: _rating > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (_ratingError != null) ...[
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            _ratingError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.fieldVertical),

                  // 3. Kartu Kolom Ulasan
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
                          'Ceritakan pengalamanmu',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.field),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F9),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.compactRadius,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _reviewController,
                                minLines: 3,
                                maxLines: 5,
                                maxLength: 200,
                                onChanged: (_) => setState(() {}),
                                validator: Validators.reviewComment,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 13,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText:
                                      'Tulis ulasanmu di sini (minimal 10 karakter)',
                                  hintStyle: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                  counterText: '',
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  '${_reviewController.text.length}/200',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.field),
                    ErrorBanner(message: _errorMessage!),
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(AppSpacing.page),
          child: AppButton(
            label: 'Kirim Ulasan',
            isLoading: _isLoading,
            onPressed: _submitReview,
          ),
        ),
      ),
    );
  }
}
