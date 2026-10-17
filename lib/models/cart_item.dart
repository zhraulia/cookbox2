// Satu menu dan jumlah porsinya di dalam keranjang.
import 'item.dart';

class CartItem {
  final Item item;
  final int quantity;

  const CartItem({required this.item, required this.quantity});

  int get subtotal => (item.price ?? 0) * quantity;
}
