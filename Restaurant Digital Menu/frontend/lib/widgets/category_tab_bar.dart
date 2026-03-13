import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class CategoryTabBar extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryTabBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _keys =
      List.generate(AppConstants.categories.length, (_) => GlobalKey());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _emojiForCategory(String id) {
    switch (id) {
      case 'starter':
        return '🥗';
      case 'main':
        return '🍛';
      case 'dessert':
        return '🍮';
      case 'drinks':
        return '🥤';
      case 'all':
      default:
        return '✦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          bottom: BorderSide(color: AppTheme.dividerLight, width: 1),
        ),
      ),
      height: 58,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        itemCount: AppConstants.categories.length,
        itemBuilder: (_, i) {
          final cat = AppConstants.categories[i];
          final isSelected = widget.selectedCategory == cat['id'];
          return _CategoryTab(
            key: _keys[i],
            emoji: _emojiForCategory(cat['id']!),
            label: cat['label']!,
            isSelected: isSelected,
            onTap: () {
              widget.onCategorySelected(cat['id']!);
              _scrollToSelected(i);
            },
          );
        },
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.dividerLight,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected ? AppTheme.primaryShadow(alpha: 55) : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 230),
              style: TextStyle(
                fontSize: isSelected ? 15 : 14,
              ),
              child: Text(emoji),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
