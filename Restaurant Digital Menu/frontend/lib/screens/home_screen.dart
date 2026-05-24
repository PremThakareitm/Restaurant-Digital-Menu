import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'menu_screen.dart';
import 'favorites_screen.dart';
import 'order_preview_screen.dart';
import 'restaurant_info_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    MenuScreen(),
    FavoritesScreen(),
    OrderPreviewScreen(),
    RestaurantInfoScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final orderCount = context.select<AppState, int>((s) => s.totalOrderItems);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        if (isDesktop) {
          // ─── Desktop: Navigation Rail ──────────────────────────────
          return Scaffold(
            body: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: const Border(
                      right: BorderSide(color: AppTheme.dividerLight, width: 1),
                    ),
                  ),
                  child: NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (i) =>
                        setState(() => _currentIndex = i),
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: AppTheme.surface,
                    indicatorColor: AppTheme.primary.withAlpha(18),
                    selectedIconTheme:
                        const IconThemeData(color: AppTheme.primary),
                    unselectedIconTheme: IconThemeData(
                        color: AppTheme.textSecondary.withAlpha(150)),
                    selectedLabelTextStyle: GoogleFonts.outfit(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11),
                    unselectedLabelTextStyle: GoogleFonts.outfit(
                        color: AppTheme.textSecondary.withAlpha(150),
                        fontWeight: FontWeight.w500,
                        fontSize: 11),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.primaryShadow(alpha: 50),
                        ),
                        child: const Icon(Icons.restaurant_menu,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    destinations: [
                      const NavigationRailDestination(
                        icon: Icon(Icons.restaurant_menu_outlined),
                        selectedIcon: Icon(Icons.restaurant_menu_rounded),
                        label: Text('Menu'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.favorite_border_rounded),
                        selectedIcon: Icon(Icons.favorite_rounded),
                        label: Text('Favourites'),
                      ),
                      NavigationRailDestination(
                        icon: Badge(
                          isLabelVisible: orderCount > 0,
                          label: Text(orderCount > 9 ? '9+' : '$orderCount'),
                          child: const Icon(Icons.shopping_bag_outlined),
                        ),
                        selectedIcon: Badge(
                          isLabelVisible: orderCount > 0,
                          label: Text(orderCount > 9 ? '9+' : '$orderCount'),
                          child: const Icon(Icons.shopping_bag_rounded),
                        ),
                        label: const Text('My Order'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.store_outlined),
                        selectedIcon: Icon(Icons.store_rounded),
                        label: Text('About'),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.person_outline_rounded),
                        selectedIcon: Icon(Icons.person_rounded),
                        label: Text('Account'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _tabs,
                  ),
                ),
              ],
            ),
          );
        }

        // ─── Mobile / Tablet: Bottom NavigationBar ─────────────────
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(14),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) =>
                    setState(() => _currentIndex = i),
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: AppTheme.primary.withAlpha(18),
                height: 68,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.restaurant_menu_outlined),
                    selectedIcon: Icon(Icons.restaurant_menu_rounded),
                    label: 'Menu',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.favorite_border_rounded),
                    selectedIcon: Icon(Icons.favorite_rounded),
                    label: 'Favourites',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: orderCount > 0,
                      label: Text(
                        orderCount > 9 ? '9+' : '$orderCount',
                      ),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: orderCount > 0,
                      label: Text(
                        orderCount > 9 ? '9+' : '$orderCount',
                      ),
                      child: const Icon(Icons.shopping_bag_rounded),
                    ),
                    label: 'Order',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.store_outlined),
                    selectedIcon: Icon(Icons.store_rounded),
                    label: 'About',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Account',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
