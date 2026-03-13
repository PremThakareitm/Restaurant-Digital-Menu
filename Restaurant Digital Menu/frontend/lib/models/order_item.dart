import 'dish.dart';

class OrderItem {
  final Dish dish;
  int quantity;

  OrderItem({required this.dish, this.quantity = 1});

  double get totalPrice => dish.price * quantity;
}
