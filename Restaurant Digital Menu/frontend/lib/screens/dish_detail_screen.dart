import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dish.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class DishDetailScreen extends StatefulWidget {
  final Dish dish;
  const DishDetailScreen({super.key, required this.dish});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen>
    with TickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  late AnimationController _ingredientController;
  late List<Animation<double>> _ingredientAnimations;

  @override
  void initState() {
    super.initState();

    _ingredientController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 300 + widget.dish.ingredients.length * 60),
    )..forward();

    _ingredientAnimations =
        List.generate(widget.dish.ingredients.length, (i) {
      final start =
          (i / widget.dish.ingredients.length) * 0.6;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ingredientController,
          curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
              curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final state = context.watch<AppState>();
    final isFav = state.isFavorite(dish.id);
    final qty = state.getOrderQuantity(dish.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ─── Image Gallery Sliver AppBar ──────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(60),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(60),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(isFav),
                      color: isFav ? AppTheme.nonVegRed : Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () =>
                      context.read<AppState>().toggleFavorite(dish.id),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image PageView
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: dish.imageUrls.length,
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: dish.imageUrls[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.divider,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary, strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.divider,
                        child: const Center(
                          child: Icon(Icons.restaurant,
                              size: 60,
                              color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  // Rich gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(30),
                            Colors.transparent,
                            Colors.black.withAlpha(80),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Page dots
                  if (dish.imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _imagePageController,
                          count: dish.imageUrls.length,
                          effect: const WormEffect(
                            dotWidth: 6,
                            dotHeight: 6,
                            activeDotColor: Colors.white,
                            dotColor: Colors.white38,
                            spacing: 6,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Content ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Veg Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _VegBadge(isVeg: dish.isVeg),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category + Bestseller + Spicy chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        label: _categoryLabel(dish.category),
                        color: AppTheme.primary.withAlpha(18),
                        textColor: AppTheme.primary,
                      ),
                      if (dish.isBestseller)
                        const _InfoChip(
                          label: '⭐  Bestseller',
                          color: Color(0xFFFFF3CD),
                          textColor: Color(0xFF856404),
                        ),
                      if (dish.isSpicy)
                        const _InfoChip(
                          label: '🌶️  Spicy',
                          color: Color(0xFFFFE9E9),
                          textColor: Color(0xFFDC2626),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating row
                  _RatingRow(dish: dish),
                  const SizedBox(height: 20),

                  // Price + quantity
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWarm,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerLight),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(dish.price),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _QuantitySelector(
                          qty: qty,
                          onAdd: () =>
                              context.read<AppState>().addToOrder(dish),
                          onRemove: () =>
                              context.read<AppState>().decrementOrder(dish.id),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionDivider(title: 'Description'),
                  const SizedBox(height: 10),
                  Text(
                    dish.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.65),
                  ),

                  const SizedBox(height: 24),
                  _SectionDivider(title: 'Ingredients'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < dish.ingredients.length; i++)
                        AnimatedBuilder(
                          animation: _ingredientAnimations[i],
                          builder: (_, __) => Opacity(
                            opacity: _ingredientAnimations[i].value,
                            child: Transform.translate(
                              offset: Offset(
                                  0,
                                  16 *
                                      (1 -
                                          _ingredientAnimations[i].value)),
                              child: _IngredientChip(
                                  label: dish.ingredients[i]),
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (dish.imageUrls.length > 1) ...[
                    const SizedBox(height: 24),
                    _SectionDivider(title: 'Photo Gallery'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dish.imageUrls.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () => _imagePageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: dish.imageUrls[i],
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                  width: 84,
                                  height: 84,
                                  color: AppTheme.divider),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── Sticky Add-to-Order Bar ────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 19),
            label: Text(
              qty == 0
                  ? 'Add to Order  ·  ${CurrencyFormatter.format(dish.price)}'
                  : 'Added ($qty)  ·  ${CurrencyFormatter.format(dish.price * qty)}',
            ),
            onPressed: () =>
                context.read<AppState>().addToOrder(widget.dish),
            style: ElevatedButton.styleFrom(
              backgroundColor: qty > 0
                  ? AppTheme.primary.withAlpha(230)
                  : AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  String _categoryLabel(String cat) {
    return switch (cat) {
      'starter' => '🥗  Starter',
      'main' => '🍛  Main Course',
      'dessert' => '🍮  Dessert',
      'drinks' => '🥤  Drink',
      _ => cat,
    };
  }
}

// ─── Section Divider ──────────────────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

// ─── Small Reusable Widgets ───────────────────────────────────────────────────
class _VegBadge extends StatelessWidget {
  final bool isVeg;
  const _VegBadge({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppTheme.vegGreen : AppTheme.nonVegRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 5),
          Text(
            isVeg ? 'Veg' : 'Non-Veg',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _InfoChip(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final dynamic dish;
  const _RatingRow({required this.dish});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 5 stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final full = i < dish.rating.floor();
            final half =
                !full && i < dish.rating;
            return Icon(
              full
                  ? Icons.star_rounded
                  : half
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              color: AppTheme.gold,
              size: 18,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          dish.rating.toStringAsFixed(1),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '(${dish.reviewCount} reviews)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String label;
  const _IngredientChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWarm,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _QuantitySelector(
      {required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (qty == 0) {
      return ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          minimumSize: Size.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: AppTheme.primaryShadow(alpha: 60),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(icon: Icons.remove, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$qty',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          _QtyButton(icon: Icons.add, onTap: onAdd),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
