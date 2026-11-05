import 'package:flutter/material.dart';

import '../data/faq_repository.dart';
import '../models/faq_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Layar Pusat Bantuan CookBox.
/// Data FAQ dikelola terpisah melalui [FaqRepository] dan model [FaqItem] (Hasil Audit Temuan 5),
/// serta pewarnaan dan tipografi mengacu pada [AppColors] dan [AppTextStyles] (Hasil Audit Temuan 4).
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
  String _selectedTopic = 'Semua Topik';
  bool _showAllFaq = false;
  late final List<FaqItem> _allFaqs;

  final List<Map<String, String>> _reportHistory = [
    {
      'id': '#LP-2041',
      'title': 'Sayur kurang lengkap',
      'desc': 'Paket Sayur Asem Segar - Pesanan #CB-882910',
      'status': '⏳ Sedang Diproses',
    }
  ];

  @override
  void initState() {
    super.initState();
    _allFaqs = widget.faqRepository.getFaqs();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;
    const bgColor = AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back, color: AppColors.ink, size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        titleSpacing: 0,
        title: const Text('Pusat Bantuan', style: AppTextStyles.titleMedium),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.muted,
              child: Icon(Icons.person, size: 18, color: AppColors.surface),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerHeader(primaryColor),
            _buildTopicCategories(),
            _buildFaqSection(primaryColor),
            _buildGoToReportCard(context, primaryColor),
            _buildReportHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerHeader(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🟢 Layanan Siap 24/7',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pusat Bantuan CookBox',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ada kendala pesanan, paket bahan masak, atau resep? Kami siap membantu.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Cari kendala pesanan, atau topik FAQ...',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: primaryColor,
                  child: const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopicCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip('Semua Topik'),
          _buildChip('📦 Pesanan & Bayar'),
          _buildChip('🥬 Kualitas Bahan'),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedTopic == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTopic = label;
          _showAllFaq = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipSelected : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.ink,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection(Color primaryColor) {
    List<FaqItem> filteredFaqs = _allFaqs;

    if (_selectedTopic != 'Semua Topik') {
      filteredFaqs = widget.faqRepository.getFaqsByCategory(_selectedTopic);
    }

    List<FaqItem> displayedFaqs = filteredFaqs;
    if (!_showAllFaq && filteredFaqs.length > 3) {
      displayedFaqs = filteredFaqs.take(3).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FAQ', style: AppTextStyles.titleSmall),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllFaq = !_showAllFaq;
                  });
                },
                child: Text(
                  _showAllFaq ? 'Tutup' : 'Lihat Semua',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (displayedFaqs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Belum ada FAQ untuk kategori ini.',
                style: AppTextStyles.bodyMuted,
              ),
            )
          else
            ...displayedFaqs.map((faq) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: Icon(faq.icon, color: faq.color),
                  title: Text(
                    faq.question,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Text(
                        faq.answer,
                        style: const TextStyle(fontSize: 12, color: AppColors.ink),
                      ),
                    )
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildGoToReportCard(BuildContext context, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: primaryColor),
              const SizedBox(width: 8),
              const Text('Layanan Pengaduan Pelanggan', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Ada item tertinggal atau kemasan bermasalah? Ajukan laporan langsung ke tim kami.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () async {
                final newReport = await Navigator.pushNamed(
                  context,
                  '/add-report',
                  arguments: 'Pesanan & Pengiriman Bahan',
                );

                if (newReport != null && newReport is Map<String, String>) {
                  setState(() {
                    _reportHistory.insert(0, newReport);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Buat Laporan Pengaduan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riwayat Laporan Saya', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          ..._reportHistory.map((report) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        report['id']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          report['status']!,
                          style: const TextStyle(fontSize: 10, color: Colors.orange),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(report['desc']!, style: AppTextStyles.caption),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}