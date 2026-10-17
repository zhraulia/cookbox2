import 'package:flutter/material.dart';

import '../models/promo_preference.dart';
import '../models/umkm.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/state_views.dart';

/// Ukuran ikon kecil, diberi nama agar angkanya tidak tertulis di widget.
const double _iconSize = 16;

class PromoPreferenceScreen extends StatefulWidget {
  // Data yang DITERIMA dari layar daftar lewat arguments.
  // Kalau umkm.promo tidak null, form dibuka dalam mode ubah.
  final Umkm umkm;

  const PromoPreferenceScreen({super.key, required this.umkm});

  @override
  State<PromoPreferenceScreen> createState() => _PromoPreferenceScreenState();
}

class _PromoPreferenceScreenState extends State<PromoPreferenceScreen> {
  // Kunci untuk mengakses state Form (validate).
  final _formKey = GlobalKey<FormState>();

  // Controller untuk membaca isi kolom minimal diskon.
  final _discountController = TextEditingController();

  final List<String> _selectedTypes = [];
  String? _typeError; // pesan error untuk pilihan promo
  String? _errorMessage; // pesan error dari proses simpan
  bool _isSubmitting = false;

  // Ubah ke true untuk menguji tampilan error.
  final bool _simulateError = false;

  bool get _isEditing => widget.umkm.isFollowing;

  @override
  void initState() {
    super.initState();
    // Mode ubah: isi form dengan pilihan yang tersimpan sebelumnya.
    final current = widget.umkm.promo;
    if (current != null) {
      _selectedTypes.addAll(current.types);
      final minDiscount = current.minDiscount;
      if (minDiscount != null) {
        _discountController.text = minDiscount.toString();
      }
    }
  }

  @override
  void dispose() {
    // WAJIB: controller dibuang saat layar ditutup agar tidak memory leak.
    _discountController.dispose();
    super.dispose();
  }

  /// EVENT: chip dipilih atau dilepas, lalu UI di-rebuild lewat setState.
  void _toggleType(String type, bool selected) {
    setState(() {
      if (selected) {
        _selectedTypes.add(type);
      } else {
        _selectedTypes.remove(type);
      }
      _typeError = null; // pesan error hilang saat pengguna memperbaiki pilihan
    });
  }

  /// Langkah VALIDASI: periksa pilihan promo (manual) dan kolom diskon
  /// (validator). Mengembalikan true kalau semuanya valid.
  bool _isInputValid() {
    final typeError = Validators.atLeastOne(
      _selectedTypes,
      message: 'Pilih minimal 1 jenis promo',
    );
    setState(() => _typeError = typeError);
    final isFormValid = _formKey.currentState?.validate() ?? false;
    return typeError == null && isFormValid;
  }

  /// Menyusun hasil form menjadi satu objek PromoPreference.
  /// int.parse aman karena validator sudah memastikan isinya angka bulat.
  /// List.of membuat salinan daftar pilihan.
  PromoPreference _buildPreference() {
    final hasDiscount = _selectedTypes.contains(PromoPreference.discount);
    return PromoPreference(
      types: List<String>.of(_selectedTypes),
      minDiscount: hasDiscount
          ? int.parse(_discountController.text.trim())
          : null,
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus(); // tutup keyboard

    // 1. Validasi. Kalau ada yang salah, berhenti dan tetap di form.
    if (!_isInputValid()) return;

    // 2. Susun hasil form.
    final preference = _buildPreference();

    // 3. Masuk ke loading state (tombol nonaktif, mencegah double submit).
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // 4. Proses async (simulasi menyimpan ke server).
      await Future.delayed(const Duration(seconds: 1));
      if (_simulateError) {
        throw Exception('Gagal menyimpan pilihan promo. Coba lagi.');
      }

      // 5. Setelah await, pastikan layar masih ada sebelum memakai context.
      if (!mounted) return;

      // 6. Tutup layar ini sambil membawa hasil ke layar sebelumnya.
      Navigator.pop(context, preference);
    } catch (e) {
      if (!mounted) return;
      // Isian tetap ada, pengguna bisa menekan Simpan lagi untuk mencoba ulang.
      setState(
        () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          _isEditing ? 'Ubah Pilihan Promo' : 'Ikuti UMKM',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
                // Data yang diterima dari layar daftar.
                _UmkmSummaryCard(umkm: widget.umkm),
                const SizedBox(height: AppSpacing.section),

                Text('Jenis promo', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Pilih satu atau lebih promo yang ingin kamu terima.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.field),
                Wrap(
                  spacing: AppSpacing.small,
                  children: [
                    for (final type in PromoPreference.availableTypes)
                      FilterChip(
                        label: Text(type),
                        selected: _selectedTypes.contains(type),
                        // null = chip nonaktif selama proses simpan
                        onSelected: _isSubmitting
                            ? null
                            : (selected) => _toggleType(type, selected),
                        selectedColor: AppColors.infoAccent,
                        checkmarkColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                  ],
                ),
                if (_typeError != null) ...[
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    _typeError!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],

                // Kolom diskon hanya muncul kalau jenis Diskon dipilih.
                if (_selectedTypes.contains(PromoPreference.discount)) ...[
                  const SizedBox(height: AppSpacing.section),
                  AppTextField(
                    controller: _discountController,
                    label: 'Minimal diskon (%)',
                    hint: 'Contoh: 20',
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.numberInRange(
                      value,
                      PromoPreference.minDiscountLimit,
                      PromoPreference.maxDiscountLimit,
                      fieldName: 'Minimal diskon',
                    ),
                  ),
                ],

                // Ringkasan langsung dari state (berubah saat chip dipilih).
                const SizedBox(height: AppSpacing.section),
                Text(
                  _selectedTypes.isEmpty
                      ? 'Belum ada promo dipilih'
                      : 'Kamu akan menerima: ${_selectedTypes.join(', ')}',
                  style: textTheme.bodyLarge,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.field),
                  ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.section),
                AppButton(
                  label: _isEditing ? 'Simpan Perubahan' : 'Simpan dan Ikuti',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu ringkas UMKM yang dikirim dari layar daftar.
class _UmkmSummaryCard extends StatelessWidget {
  final Umkm umkm;

  const _UmkmSummaryCard({required this.umkm});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(umkm.name, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              const Icon(Icons.star, size: _iconSize, color: AppColors.accent),
              const SizedBox(width: AppSpacing.small),
              Text(umkm.rating.toStringAsFixed(1), style: textTheme.bodyLarge),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: Text(
                  umkm.category,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
