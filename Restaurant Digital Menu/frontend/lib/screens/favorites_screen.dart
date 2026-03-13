import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/dish_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites =
        context.select<AppState, List>((s) => s.favoriteDishes);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Favourites'),
        actions: [
          if (favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.nonVegRed.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.nonVegRed.withAlpha(40), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          size: 13, color: AppTheme.nonVegRed),
                      const SizedBox(width: 5),
                      Text(
                        '${favorites.length} saved',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.nonVegRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? const _EmptyFavourites()
          : ResponsiveBuilder(
              builder: (context, screenType, screenWidth) {
                final useGrid = screenType.isLargeScreen;
                final horizontalPad =
                    ResponsiveHelper.getHorizontalPadding(screenWidth);
                final maxContentWidth =
                    ResponsiveHelper.getMaxContentWidth(screenWidth);

                if (useGrid) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount =
                              ResponsiveHelper.getGridColumns(width);
                          final ratio =
                              ResponsiveHelper.getCardAspectRatio(crossAxisCount);
                          final spacing =
                              ResponsiveHelper.getGridSpacing(screenWidth);

                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                                horizontalPad, 16, horizontalPad, 16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: ratio,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                            ),
                            itemCount: favorites.length,
                            itemBuilder: (ctx, i) => DishCard(
                              dish: favorites[i],
                              index: i,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                // ─── Mobile: List Layout ───────────────────────────
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                          horizontalPad, 16, horizontalPad, 100),
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => DishCard(
                        dish: favorites[i],
                        index: i,
                        useListLayout: true,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyFavourites extends StatefulWidget {
  const _EmptyFavourites();

  @override
  State<_EmptyFavourites> createState() => _EmptyFavouritesState();
}

class _EmptyFavouritesState extends State<_EmptyFavourites>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scale,
              builder: (_, child) => Transform.scale(
                scale: _scale.value,
                child: child,
              ),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.nonVegRed.withAlpha(20),
                      AppTheme.nonVegRed.withAlpha(6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🤍', style: TextStyle(fontSize: 52)),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'No favourites yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the ♥ on any dish to save\nyour favourite meals here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withAlpha(30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant_menu_outlined,
                      size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Explore the menu',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
