import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../models/order_item.dart';
import '../data/menu_data.dart';
import '../utils/constants.dart';

class PlacedOrder {
  final String token;
  final int itemCount;
  final double total;
  final DateTime placedAt;
  final int? tableNumber;
  final String? note;

  const PlacedOrder({
    required this.token,
    required this.itemCount,
    required this.total,
    required this.placedAt,
    this.tableNumber,
    this.note,
  });
}

class AppState extends ChangeNotifier {
  // ─── Dishes ───────────────────────────────────────────────────────────────
  final List<Dish> _allDishes = MenuData.dishes;

  // ─── Category filter ──────────────────────────────────────────────────────
  String _selectedCategory = 'all';

  // ─── Search ───────────────────────────────────────────────────────────────
  String _searchQuery = '';
  bool _searchVisible = false;

  // ─── Chip filters ─────────────────────────────────────────────────────────
  bool _filterVeg = false;
  bool _filterSpicy = false;
  bool _filterBestseller = false;

  // ─── Favourites ───────────────────────────────────────────────────────────
  final Set<String> _favoriteIds = {};

  // ─── Order ────────────────────────────────────────────────────────────────
  final Map<String, OrderItem> _orderItems = {};
  final List<PlacedOrder> _orderHistory = [];
  int? _tableNumber;
  String _orderNote = '';

  // ─── Getters ──────────────────────────────────────────────────────────────
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get searchVisible => _searchVisible;
  bool get filterVeg => _filterVeg;
  bool get filterSpicy => _filterSpicy;
  bool get filterBestseller => _filterBestseller;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<Dish> get filteredDishes {
    return _allDishes.where((dish) {
      if (_selectedCategory != 'all' && dish.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!dish.name.toLowerCase().contains(q) &&
            !dish.description.toLowerCase().contains(q) &&
            !dish.ingredients.any((i) => i.toLowerCase().contains(q))) {
          return false;
        }
      }
      if (_filterVeg && !dish.isVeg) return false;
      if (_filterSpicy && !dish.isSpicy) return false;
      if (_filterBestseller && !dish.isBestseller) return false;
      return true;
    }).toList();
  }

  List<Dish> get favoriteDishes =>
      _allDishes.where((d) => _favoriteIds.contains(d.id)).toList();

  List<OrderItem> get orderItems => _orderItems.values.toList();
  List<PlacedOrder> get orderHistory => List.unmodifiable(_orderHistory);
  int? get tableNumber => _tableNumber;
  String get orderNote => _orderNote;
  List<Dish> get trendingDishes =>
      _allDishes.where((d) => d.isBestseller).toList();

  int get totalOrderItems =>
      _orderItems.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalOrderPrice =>
      _orderItems.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool isFavorite(String dishId) => _favoriteIds.contains(dishId);

  int getOrderQuantity(String dishId) => _orderItems[dishId]?.quantity ?? 0;

  // ─── Category ─────────────────────────────────────────────────────────────
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ─── Search ───────────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSearch() {
    _searchVisible = !_searchVisible;
    if (!_searchVisible) _searchQuery = '';
    notifyListeners();
  }

  // ─── Filters ──────────────────────────────────────────────────────────────
  void toggleVegFilter() {
    _filterVeg = !_filterVeg;
    notifyListeners();
  }

  void toggleSpicyFilter() {
    _filterSpicy = !_filterSpicy;
    notifyListeners();
  }

  void toggleBestsellerFilter() {
    _filterBestseller = !_filterBestseller;
    notifyListeners();
  }

  // ─── Favourites ───────────────────────────────────────────────────────────
  void toggleFavorite(String dishId) {
    if (_favoriteIds.contains(dishId)) {
      _favoriteIds.remove(dishId);
    } else {
      _favoriteIds.add(dishId);
    }
    notifyListeners();
  }

  // ─── Order ────────────────────────────────────────────────────────────────
  void addToOrder(Dish dish) {
    if (_orderItems.containsKey(dish.id)) {
      _orderItems[dish.id]!.quantity++;
    } else {
      _orderItems[dish.id] = OrderItem(dish: dish);
    }
    notifyListeners();
  }

  void decrementOrder(String dishId) {
    if (_orderItems.containsKey(dishId)) {
      if (_orderItems[dishId]!.quantity > 1) {
        _orderItems[dishId]!.quantity--;
      } else {
        _orderItems.remove(dishId);
      }
    }
    notifyListeners();
  }

  void removeFromOrder(String dishId) {
    _orderItems.remove(dishId);
    notifyListeners();
  }

  void clearOrder() {
    _orderItems.clear();
    notifyListeners();
  }

  void setTableNumber(int? n) {
    _tableNumber = n;
    notifyListeners();
  }

  void setOrderNote(String note) {
    _orderNote = note;
    notifyListeners();
  }

  PlacedOrder placeOrder() {
    if (_orderItems.isEmpty) {
      throw StateError('Cannot place an empty order');
    }

    final subtotal = totalOrderPrice;
    final tax = subtotal * AppConstants.taxRate;
    final total = subtotal + tax;
    final token = _generateOrderToken();
    final placedOrder = PlacedOrder(
      token: token,
      itemCount: totalOrderItems,
      total: total,
      placedAt: DateTime.now(),
      tableNumber: _tableNumber,
      note: _orderNote.trim().isEmpty ? null : _orderNote.trim(),
    );

    _orderHistory.insert(0, placedOrder);
    _orderItems.clear();
    _tableNumber = null;
    _orderNote = '';
    notifyListeners();
    return placedOrder;
  }

  String _generateOrderToken() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'ORD-${now.toString().substring(now.toString().length - 6)}';
  }
}
