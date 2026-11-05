import 'package:flutter/material.dart';

import '../models/faq_item.dart';

/// Repository penyedia data FAQ (Frequently Asked Questions) dan pusat bantuan.
/// Memisahkan logika penyediaan data dari layer UI (support_screen).
class FaqRepository {
  const FaqRepository();

  static const List<FaqItem> _faqs = [
    FaqItem(
      id: 'faq_1',
      question: 'Bagaimana cara pesan paket bahan masak?',
      answer:
          'Pilih menu dari UMKM mitra favorit di katalog harian, pilih porsi, lalu tentukan jam antar instan atau jadwal pengiriman esok pagi.',
      category: '📦 Pesanan & Bayar',
      icon: Icons.shopping_bag_outlined,
      color: Colors.orange,
    ),
    FaqItem(
      id: 'faq_2',
      question: 'Metode pembayaran apa saja yang didukung?',
      answer:
          'Kami menerima pembayaran melalui Transfer Bank, QRIS, E-Wallet (OVO, GoPay, Dana), dan bayar di tempat (COD).',
      category: '📦 Pesanan & Bayar',
      icon: Icons.payment,
      color: Colors.blue,
    ),
    FaqItem(
      id: 'faq_3',
      question: 'Apakah bahan makanan dijamin segar dan higienis?',
      answer:
          'Ya, semua bahan disortir ketat, dicuci bersih, dan dikemas secara higienis sebelum dikirim ke lokasi Anda.',
      category: '🥬 Kualitas Bahan',
      icon: Icons.verified_user_outlined,
      color: Colors.green,
    ),
    FaqItem(
      id: 'faq_4',
      question: 'Berapa lama bahan masak tahan disimpan?',
      answer:
          'Sebaiknya dimasak pada hari yang sama. Jika disimpan di kulkas (chiller), tahan hingga 2-3 hari untuk sayuran, dan di freezer untuk ayam/daging.',
      category: '🥬 Kualitas Bahan',
      icon: Icons.ac_unit,
      color: Colors.lightBlue,
    ),
  ];

  /// Mengambil seluruh daftar FAQ.
  List<FaqItem> getFaqs() => List.unmodifiable(_faqs);

  /// Mengambil daftar FAQ berdasarkan kategori tertentu.
  List<FaqItem> getFaqsByCategory(String category) {
    if (category == 'Semua Topik') {
      return getFaqs();
    }
    return _faqs.where((faq) => faq.category == category).toList();
  }
}
