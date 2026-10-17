import 'cart_item.dart';

// Snapshot pesanan yang diteruskan ke halaman konfirmasi.
class Order {
  final String id;
  final List<CartItem> items;
  final String deliveryMethod;
  final String deliveryAddress;
  final String paymentMethod;
  final int subtotal;
  final int deliveryFee;
  final int total;
  final DateTime createdAt;

  Order({
    String? id,
    required List<CartItem> items,
    required this.deliveryMethod,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       items = List.unmodifiable(items),
       createdAt = createdAt ?? DateTime.now();

  String get totalLabel {
    final digits = total.toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $grouped';
  }
}
