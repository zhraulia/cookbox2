import '../models/faq_item.dart';

/// Repository penyedia data FAQ (Frequently Asked Questions) dan pusat bantuan.
/// Memisahkan logika penyediaan data dari layer UI (support_screen).
class FaqRepository {
  const FaqRepository();

  static const List<FaqItem> _faqs = [
    FaqItem(
      id: 'faq_1',
      question: 'Apa itu CookBox?',
      answer:
          'CookBox adalah platform penyedia paket bahan masakan porsi pas dan siap masak untuk mahasiswa dan anak kos, lengkap dengan bumbu racik dan panduan langkah memasak praktis.',
      category: 'Umum',
    ),
    FaqItem(
      id: 'faq_2',
      question: 'Bagaimana cara memesan paket masakan?',
      answer:
          'Pilih menu paket masak favoritmu di Beranda, tentukan porsi yang diinginkan, lalu masukkan ke keranjang atau langsung lakukan checkout untuk mengonfirmasi pesanan.',
      category: 'Pemesanan',
    ),
    FaqItem(
      id: 'faq_3',
      question: 'Apakah bahan masakan dijamin segar?',
      answer:
          'Semua bahan pangan disiapkan dan dikemas langsung oleh mitra UMKM lokal terpercaya sesaat sebelum kurir mengantarkan ke alamatmu guna menjamin kesegaran maksimal.',
      category: 'Kualitas',
    ),
    FaqItem(
      id: 'faq_4',
      question: 'Bagaimana cara melacak status pengantaran?',
      answer:
          'Buka tab "Pesanan" pada bilah navigasi bawah. Di sana kamu dapat memantau status pesanan secara langsung: mulai dari Diproses, Sedang Dikirim, hingga Pesanan Selesai.',
      category: 'Pengiriman',
    ),
    FaqItem(
      id: 'faq_5',
      question: 'Bagaimana cara memberi ulasan setelah pesanan tiba?',
      answer:
          'Setelah pesananmu berstatus Selesai, kamu dapat menekan tombol "Beri Ulasan" pada kartu pesanan untuk memberikan rating bintang serta tanggapan mengenai kualitas bahan dan resep.',
      category: 'Ulasan',
    ),
  ];

  /// Mengambil seluruh daftar FAQ.
  List<FaqItem> getFaqs() => List.unmodifiable(_faqs);

  /// Mengambil daftar FAQ berdasarkan kategori tertentu.
  List<FaqItem> getFaqsByCategory(String category) {
    return _faqs.where((faq) => faq.category == category).toList();
  }
}
