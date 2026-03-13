class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // 'starter' | 'main' | 'dessert' | 'drinks'
  final List<String> imageUrls;
  final List<String> ingredients;
  final double rating;
  final int reviewCount;
  final bool isVeg;
  final bool isSpicy;
  final bool isBestseller;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    required this.ingredients,
    required this.rating,
    required this.reviewCount,
    required this.isVeg,
    this.isSpicy = false,
    this.isBestseller = false,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      ingredients: List<String>.from(json['ingredients'] as List),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      isVeg: json['isVeg'] as bool,
      isSpicy: (json['isSpicy'] as bool?) ?? false,
      isBestseller: (json['isBestseller'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'imageUrls': imageUrls,
        'ingredients': ingredients,
        'rating': rating,
        'reviewCount': reviewCount,
        'isVeg': isVeg,
        'isSpicy': isSpicy,
        'isBestseller': isBestseller,
      };
}
