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
  // Koordinat GPS lokasi pengantaran (nullable)
  final double? deliveryLatitude;
  final double? deliveryLongitude;

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
    this.deliveryLatitude,
    this.deliveryLongitude,
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

  /// Membuat salinan Order dengan atribut yang diperbarui.
  Order copyWith({
    String? id,
    List<CartItem>? items,
    String? deliveryMethod,
    String? deliveryAddress,
    String? paymentMethod,
    int? subtotal,
    int? deliveryFee,
    int? total,
    DateTime? createdAt,
    double? deliveryLatitude,
    double? deliveryLongitude,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
    );
  }
}
