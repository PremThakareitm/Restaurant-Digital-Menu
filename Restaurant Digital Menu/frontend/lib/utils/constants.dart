class AppConstants {
  static const String restaurantName = 'Bites & Brilliance';
  static const String restaurantTagline = 'Where Every Bite Shines';
  static const String restaurantCuisine = 'North Indian & Pan-Asian';
  static const String restaurantPhone = '+91 98765 43210';
  static const String restaurantEmail = 'hello@bitesandbrilliance.in';
  static const String restaurantAddress =
      '12, Connaught Place\nNew Delhi – 110 001';
  static const String restaurantWebsite = 'www.bitesandbrilliance.in';

  static const List<Map<String, String>> openingHours = [
    {'day': 'Monday – Thursday', 'hours': '12:00 PM – 10:00 PM'},
    {'day': 'Friday – Saturday', 'hours': '11:00 AM – 11:30 PM'},
    {'day': 'Sunday', 'hours': '11:00 AM – 10:00 PM'},
  ];

  static const List<Map<String, String>> categories = [
    {'id': 'all', 'label': 'All', 'emoji': '🍽️'},
    {'id': 'starter', 'label': 'Starters', 'emoji': '🥗'},
    {'id': 'main', 'label': 'Main Course', 'emoji': '🍛'},
    {'id': 'dessert', 'label': 'Desserts', 'emoji': '🍮'},
    {'id': 'drinks', 'label': 'Drinks', 'emoji': '🥤'},
  ];

  static const double taxRate = 0.05; // 5% GST (restaurant)
}
