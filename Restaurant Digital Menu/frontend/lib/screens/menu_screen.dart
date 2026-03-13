import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/dish_card.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/search_bar_widget.dart';
import 'dish_detail_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MenuView();
  }
}

class _MenuView extends StatefulWidget {
  const _MenuView();

  @override
  State<_MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<_MenuView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dishes = state.filteredDishes;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context, state),
      body: ResponsiveBuilder(
        builder: (context, screenType, screenWidth) {
          final horizontalPad =
              ResponsiveHelper.getHorizontalPadding(screenWidth);
          final maxContentWidth =
              ResponsiveHelper.getMaxContentWidth(screenWidth);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Search Bar ──────────────────────────────────────
                  AnimatedCrossFade(
                    firstChild: const SizedBox(height: 0),
                    secondChild: Padding(
                      padding: EdgeInsets.fromLTRB(
                          horizontalPad, 10, horizontalPad, 8),
                      child: SearchBarWidget(
                        controller: _searchController,
                        onChanged: (q) =>
                            context.read<AppState>().setSearchQuery(q),
                      ),
                    ),
                    crossFadeState: state.searchVisible
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 280),
                  ),

                  // ─── Greeting Header ─────────────────────────────────
                  if (!state.searchVisible)
                    _GreetingHeader(horizontalPad: horizontalPad),

                  // ─── Trending Strip ──────────────────────────────────
                  if (!state.searchVisible && state.trendingDishes.isNotEmpty)
                    _TrendingSection(
                      dishes: state.trendingDishes,
                      horizontalPad: horizontalPad,
                    ),

                  // ─── Category Tabs ───────────────────────────────────
                  CategoryTabBar(
                    selectedCategory: state.selectedCategory,
                    onCategorySelected: (cat) =>
                        context.read<AppState>().setCategory(cat),
                  ),

                  // ─── Filter Row ──────────────────────────────────────
                  _FilterRow(state: state, horizontalPad: horizontalPad),

                  // ─── Results bar ─────────────────────────────────────
                  _ResultsBar(
                    count: dishes.length,
                    hasFilters: state.filterVeg ||
                        state.filterSpicy ||
                        state.filterBestseller,
                    horizontalPad: horizontalPad,
                  ),

                  // ─── Dish Grid ────────────────────────────────────────
                  Expanded(
                    child: dishes.isEmpty
                        ? _EmptyState(isSearch: state.searchQuery.isNotEmpty)
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final crossAxisCount =
                                  ResponsiveHelper.getGridColumns(width);
                              final ratio =
                                  ResponsiveHelper.getCardAspectRatio(
                                      crossAxisCount);
                              final spacing =
                                  ResponsiveHelper.getGridSpacing(screenWidth);

                              return GridView.builder(
                                padding: EdgeInsets.fromLTRB(
                                    horizontalPad, 8, horizontalPad, 100),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: ratio,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                ),
                                itemCount: dishes.length,
                                itemBuilder: (ctx, index) => DishCard(
                                  dish: dishes[index],
                                  index: index,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state) {
    final isCompact = MediaQuery.sizeOf(context).width < 380;
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 16,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.divider.withAlpha(0),
                AppTheme.divider,
                AppTheme.divider.withAlpha(0),
              ],
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          // Logo icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.primaryShadow(alpha: 50),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bites & Brilliance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (!isCompact)
                  Text(
                    '✦  North Indian · Pan-Asian',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _SearchToggleButton(
          isSearchVisible: state.searchVisible,
          onPressed: () {
            context.read<AppState>().toggleSearch();
            _searchController.clear();
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

// ─── Greeting Header ────────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final double horizontalPad;
  const _GreetingHeader({required this.horizontalPad});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    if (h < 21) return 'Good Evening';
    return 'Good Night';
  }

  String _greetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '🌅';
    if (h < 17) return '☀️';
    if (h < 21) return '🌆';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, 14, horizontalPad, 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _greetingEmoji(),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _greeting(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "What's on your mind?",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Cuisine pill badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.primary.withAlpha(35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  'New Delhi',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trending Section ───────────────────────────────────────────────────────
class _TrendingSection extends StatelessWidget {
  final List<dynamic> dishes;
  final double horizontalPad;
  const _TrendingSection(
      {required this.dishes, required this.horizontalPad});

  @override
  Widget build(BuildContext context) {
    if (dishes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPad, 14, horizontalPad, 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🔥  Trending Now',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
              Text(
                '${dishes.length} items',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, 4),
            itemCount: dishes.length,
            itemBuilder: (ctx, i) => _TrendingCard(dish: dishes[i]),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final dynamic dish;
  const _TrendingCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DishDetailScreen(dish: dish),
        ),
      ),
      child: Container(
        width: 132,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.shadowMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Full image
            CachedNetworkImage(
              imageUrl: dish.imageUrls.first,
              width: 132,
              height: 170,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                  color: AppTheme.dividerLight,
                  child: const Center(
                      child: Icon(Icons.restaurant,
                          size: 28, color: AppTheme.divider))),
              errorWidget: (_, __, ___) =>
                  Container(color: AppTheme.dividerLight),
            ),
            // Gradient overlay (stronger at bottom)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(45),
                      Colors.black.withAlpha(190),
                    ],
                    stops: const [0.35, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            // Hot badge top-right
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFE8412A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        size: 9, color: Colors.white),
                    const SizedBox(width: 2),
                    Text('Hot',
                        style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            // Veg dot top-left
            Positioned(
              top: 7,
              left: 7,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: dish.isVeg
                        ? AppTheme.vegGreen
                        : AppTheme.nonVegRed,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 4.5,
                    backgroundColor:
                        dish.isVeg ? AppTheme.vegGreen : AppTheme.nonVegRed,
                  ),
                ),
              ),
            ),
            // Name + price at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 0, 9, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${dish.price.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 10,
                                  color: AppTheme.goldLight),
                              const SizedBox(width: 2),
                              Text(
                                dish.rating.toStringAsFixed(1),
                                style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
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

// ─── Search toggle button ────────────────────────────────────────────────────
class _SearchToggleButton extends StatelessWidget {
  final bool isSearchVisible;
  final VoidCallback onPressed;
  const _SearchToggleButton(
      {required this.isSearchVisible, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSearchVisible
              ? AppTheme.primary.withAlpha(18)
              : AppTheme.dividerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
            key: ValueKey(isSearchVisible),
            color:
                isSearchVisible ? AppTheme.primary : AppTheme.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Row ─────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final AppState state;
  final double horizontalPad;

  const _FilterRow({required this.state, required this.horizontalPad});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(horizontalPad, 10, horizontalPad, 6),
      child: Row(
        children: [
          _FilterChip(
            icon: '🌿',
            label: 'Veg Only',
            selected: state.filterVeg,
            onTap: () => context.read<AppState>().toggleVegFilter(),
            activeColor: AppTheme.vegGreen,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: '🌶️',
            label: 'Spicy',
            selected: state.filterSpicy,
            onTap: () => context.read<AppState>().toggleSpicyFilter(),
            activeColor: AppTheme.nonVegRed,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: '⭐',
            label: 'Bestseller',
            selected: state.filterBestseller,
            onTap: () => context.read<AppState>().toggleBestsellerFilter(),
            activeColor: AppTheme.gold,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? activeColor.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? activeColor : AppTheme.divider,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? activeColor : AppTheme.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Results Bar ─────────────────────────────────────────────────────────────
class _ResultsBar extends StatelessWidget {
  final int count;
  final bool hasFilters;
  final double horizontalPad;

  const _ResultsBar({
    required this.count,
    required this.hasFilters,
    required this.horizontalPad,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, 4),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? 'dish' : 'dishes'}',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 6),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.textHint,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Filtered',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isSearch;
  const _EmptyState({required this.isSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isSearch ? '🔍' : '🍽️',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isSearch ? 'No dishes found' : 'Nothing here yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          if (isSearch) ...[
            const SizedBox(height: 8),
            Text(
              'Try a different search term\nor adjust your filters.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
