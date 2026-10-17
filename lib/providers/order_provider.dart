import 'dart:async';
import 'package:flutter/foundation.dart';

import '../data/order_repository.dart';
import '../models/order.dart';
import '../models/review.dart';

/// State management pesanan lintas-layar dengan pola ChangeNotifier Singleton.
class OrderProvider extends ChangeNotifier {
  OrderProvider._internal() {
    // Inisialisasi awal langsung dari repository agar data dummy selalu siap seketika.
    _orders = List<Order>.from(OrderRepository.initialOrders);
  }

  static final OrderProvider _instance = OrderProvider._internal();

  /// Mengembalikan instance singleton yang sama.
  factory OrderProvider() => _instance;

  /// Akses static singleton untuk kemudahan penggunaan di UI atau Provider.
  static OrderProvider get instance => _instance;

  final OrderRepository _repository = OrderRepository();

  late List<Order> _orders;
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Memuat daftar pesanan dari repository jika belum ada data.
  Future<void> loadOrders({
    bool simulateError = false,
    bool forceReload = false,
  }) async {
    // Jika data pesanan sudah dimuat dan tidak dipaksa reload, jangan timpa state.
    if (_orders.isNotEmpty && !forceReload) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.fetchOrders(simulateError: simulateError);
      _orders = List<Order>.from(data);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan pesanan baru ke repository, state provider, dan memulai simulasi alur status.
  void addOrder(Order order) {
    _repository.addOrder(order);
    _orders.insert(0, order);
    notifyListeners();

    // Memulai simulasi timer otomatis jika pesanan baru berstatus Dikemas
    if (order.status == OrderStatus.dikemas) {
      _startOrderSimulation(order.id);
    }
  }

  /// Simulasi waktu alur pesanan otomatis:
  /// - 10 detik pertama: Dikemas -> Dikirim
  /// - 15 detik berikutnya: Dikirim -> Selesai
  void _startOrderSimulation(String orderId) {
    Timer(const Duration(seconds: 10), () {
      final order = _findOrder(orderId);
      if (order != null && order.status == OrderStatus.dikemas) {
        updateOrderStatus(orderId, OrderStatus.dikirim);

        Timer(const Duration(seconds: 15), () {
          final current = _findOrder(orderId);
          if (current != null && current.status == OrderStatus.dikirim) {
            updateOrderStatus(orderId, OrderStatus.selesai);
          }
        });
      }
    });
  }

  /// Memperbarui status pesanan dan merefresh UI secara reaktif.
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final updated = _repository.updateOrderStatus(orderId, newStatus);
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = updated;
      notifyListeners();
    }
  }

  Order? _findOrder(String orderId) {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  /// Menambahkan atau memperbarui ulasan pada pesanan.
  void addReview(String orderId, Review review) {
    final updated = _repository.addReview(orderId, review);
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = updated;
      notifyListeners();
    }
  }

  /// Menghapus ulasan dari pesanan.
  void removeReview(String orderId) {
    final updated = _repository.removeReview(orderId);
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = updated;
      notifyListeners();
    }
  }
}
