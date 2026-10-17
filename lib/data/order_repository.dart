import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/review.dart';
import 'item_repository.dart';

/// Sumber data pesanan lokal (dummy).
class OrderRepository {
  // static list agar state pesanan dan ulasan bertahan selama aplikasi berjalan.
  static final List<Order> _orders = [
    // 1. Pesanan Dikemas
    Order(
      id: 'CKB-90214',
      items: [
        CartItem(
          item: ItemRepository.sampleItems[0], // Ayam Geprek Sambal Korek
          quantity: 1,
        ),
      ],
      deliveryMethod: 'Antar ke Alamat',
      deliveryAddress: 'Kost Bougenville No. 12, Padang',
      paymentMethod: 'QRIS',
      subtotal: 18000,
      deliveryFee: 0,
      total: 18000,
      status: OrderStatus.dikemas,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),

    // 2. Pesanan Dikirim
    Order(
      id: 'CKB-90188',
      items: [
        CartItem(
          item: ItemRepository.sampleItems[1], // Cah Kangkung Terasi
          quantity: 2,
        ),
      ],
      deliveryMethod: 'Antar ke Alamat',
      deliveryAddress: 'Kost Bougenville No. 12, Padang',
      paymentMethod: 'Transfer Bank',
      subtotal: 17000,
      deliveryFee: 0,
      total: 17000,
      status: OrderStatus.dikirim,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),

    // 3. Pesanan Selesai (Belum Diulas)
    Order(
      id: 'CKB-89945',
      items: [
        CartItem(
          item: ItemRepository.sampleItems[0], // Ayam Geprek Sambal Korek
          quantity: 1,
        ),
      ],
      deliveryMethod: 'Ambil di UMKM',
      deliveryAddress: 'Ambil Sendiri',
      paymentMethod: 'Tunai',
      subtotal: 18000,
      deliveryFee: 0,
      total: 18000,
      status: OrderStatus.selesai,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),

    // 4. Pesanan Selesai (Sudah Diulas)
    Order(
      id: 'CKB-89753',
      items: [
        CartItem(
          item: ItemRepository.sampleItems[1], // Cah Kangkung Terasi
          quantity: 1,
        ),
      ],
      deliveryMethod: 'Antar ke Alamat',
      deliveryAddress: 'Kost Bougenville No. 12, Padang',
      paymentMethod: 'QRIS',
      subtotal: 8500,
      deliveryFee: 0,
      total: 8500,
      status: OrderStatus.selesai,
      review: Review(
        id: 'REV-89753',
        rating: 5,
        comment:
            'Sayurannya masih sangat segar dan bumbunya pas banget. Cocok buat anak kos!',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  /// Mengambil daftar pesanan awal secara sinkron.
  static List<Order> get initialOrders => List.unmodifiable(_orders);

  /// Mengambil daftar pesanan dengan simulasi asinkron.
  Future<List<Order>> fetchOrders({bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (simulateError) {
      throw Exception('Gagal memuat daftar pesanan. Periksa koneksi internet.');
    }
    return List.unmodifiable(_orders);
  }

  /// Menambahkan pesanan baru yang dibuat pengguna ke daftar pesanan dummy.
  void addOrder(Order order) {
    _orders.insert(0, order);
  }

  /// Menambahkan atau memperbarui ulasan pada pesanan tertentu.
  Order addReview(String orderId, Review review) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw ArgumentError.value(orderId, 'orderId', 'Pesanan tidak ditemukan.');
    }
    final updated = _orders[index].copyWith(review: review);
    _orders[index] = updated;
    return updated;
  }

  /// Menghapus ulasan dari pesanan tertentu (Fitur D opsional).
  Order removeReview(String orderId) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw ArgumentError.value(orderId, 'orderId', 'Pesanan tidak ditemukan.');
    }
    final updated = _orders[index].copyWith(removeReview: true);
    _orders[index] = updated;
    return updated;
  }
}
