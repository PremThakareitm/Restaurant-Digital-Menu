import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dish.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../screens/dish_detail_screen.dart';

class DishCard extends StatefulWidget {
  final Dish dish;
  final int index;
  final bool useListLayout;

  const DishCard({
    super.key,
    required this.dish,
    required this.index,
    this.useListLayout = false,
  });

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 50 + widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: child),
      ),
      child: widget.useListLayout
          ? _ListCard(dish: widget.dish)
          : _GridCard(dish: widget.dish),
    );
  }
}

// ─── Grid layout (menu screen) ────────────────────────────────────────────────
class _GridCard extends StatelessWidget {
  final Dish dish;
  const _GridCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isFav = state.isFavorite(dish.id);
    final qty = state.getOrderQuantity(dish.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DishDetailScreen(dish: dish)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerLight, width: 1),
          boxShadow: AppTheme.shadowMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image ────────────────────────────────────────────────
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: dish.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppTheme.dividerLight,
                      child: const Center(
                        child: Icon(Icons.restaurant,
                            size: 34, color: AppTheme.divider),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.dividerLight,
                      child: const Center(
                        child: Icon(Icons.restaurant,
                            size: 34, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(50),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Veg/Non-veg indicator (top-left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _VegDot(isVeg: dish.isVeg),
                  ),
                  // Bestseller badge (top-right)
                  if (dish.isBestseller)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _BestsellerBadge(),
                    ),
                  // Favourite button (bottom-right, on image)
                  Positioned(
                    bottom: 7,
                    right: 7,
                    child: _FavButton(
                      isFav: isFav,
                      onTap: () =>
                          context.read<AppState>().toggleFavorite(dish.id),
                    ),
                  ),
                  // Spicy icon (bottom-left on image if needed)
                  if (dish.isSpicy)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(90),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                size: 10, color: Color(0xFFFF7043)),
                            const SizedBox(width: 3),
                            Text('Spicy',
                                style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ─── Info ─────────────────────────────────────────────────
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish name
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Description
                    Expanded(
                      child: Text(
                        dish.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Rating
                    _RatingBadge(rating: dish.rating),
                    const SizedBox(height: 6),
                    // Price + Add
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            CurrencyFormatter.format(dish.price),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _AddButton(dish: dish, qty: qty),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List layout (favourites screen) ─────────────────────────────────────────
class _ListCard extends StatelessWidget {
  final Dish dish;
  const _ListCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isFav = state.isFavorite(dish.id);
    final qty = state.getOrderQuantity(dish.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DishDetailScreen(dish: dish)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.dividerLight, width: 1),
          boxShadow: AppTheme.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: dish.imageUrls.first,
                  width: 115,
                  height: 115,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 115,
                    height: 115,
                    color: AppTheme.dividerLight,
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          size: 30, color: AppTheme.divider),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 115,
                    height: 115,
                    color: AppTheme.dividerLight,
                    child: const Icon(Icons.restaurant,
                        size: 36, color: AppTheme.textSecondary),
                  ),
                ),
                Positioned(
                  top: 7,
                  left: 7,
                  child: _VegDot(isVeg: dish.isVeg),
                ),
                if (dish.isBestseller)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '★ Best',
                        style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context
                              .read<AppState>()
                              .toggleFavorite(dish.id),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(isFav),
                              size: 18,
                              color: isFav
                                  ? AppTheme.nonVegRed
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _RatingBadge(rating: dish.rating),
                        if (dish.isSpicy) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.local_fire_department_rounded,
                              size: 13, color: Color(0xFFE25822)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          CurrencyFormatter.format(dish.price),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        const Spacer(),
                        _AddButton(dish: dish, qty: qty),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _VegDot extends StatelessWidget {
  final bool isVeg;
  const _VegDot({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isVeg ? AppTheme.vegGreen : AppTheme.nonVegRed,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: CircleAvatar(
          radius: 5,
          backgroundColor: isVeg ? AppTheme.vegGreen : AppTheme.nonVegRed,
        ),
      ),
    );
  }
}

class _BestsellerBadge extends StatelessWidget {
  const _BestsellerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDAA520), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 9, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            'Best',
            style: GoogleFonts.outfit(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;
  const _FavButton({required this.isFav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isFav ? AppTheme.nonVegRed.withAlpha(20) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFav),
            size: 14,
            color: isFav ? AppTheme.nonVegRed : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.gold.withAlpha(22),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 11, color: AppTheme.gold),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Dish dish;
  final int qty;
  const _AddButton({required this.dish, required this.qty});

  @override
  Widget build(BuildContext context) {
    if (qty == 0) {
      return GestureDetector(
        onTap: () => context.read<AppState>().addToOrder(dish),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.primaryShadow(alpha: 60),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 14, color: Colors.white),
              const SizedBox(width: 3),
              Text(
                'Add',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 30,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.primaryShadow(alpha: 60),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.read<AppState>().decrementOrder(dish.id),
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.remove, size: 15, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              '$qty',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<AppState>().addToOrder(dish),
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.add, size: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
