import '../utils/formatters.dart';
import 'cart_item.dart';
import 'review.dart';

/// Status alur pesanan: Dikemas, Dikirim, atau Selesai.
enum OrderStatus {
  dikemas('Dikemas'),
  dikirim('Dikirim'),
  selesai('Selesai');

  final String label;
  const OrderStatus(this.label);
}

// Snapshot pesanan yang diteruskan ke halaman konfirmasi dan status pesanan.
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
  final OrderStatus status;
  final Review? review;

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
    this.status = OrderStatus.dikemas,
    this.review,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       items = List.unmodifiable(items),
       createdAt = createdAt ?? DateTime.now();

  /// Memeriksa apakah pesanan ini sudah diberi ulasan.
  bool get isReviewed => review != null;

  String get totalLabel => AppFormatters.rupiah(total);

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
    OrderStatus? status,
    Review? review,
    bool removeReview = false,
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
      status: status ?? this.status,
      review: removeReview ? null : (review ?? this.review),
    );
  }
}

