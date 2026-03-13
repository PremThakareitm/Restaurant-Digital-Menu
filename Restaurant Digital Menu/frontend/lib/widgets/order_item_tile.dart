import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_item.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;
  const OrderItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.dish.imageUrls.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.dividerLight,
                      child: const Center(
                        child: Icon(Icons.restaurant,
                            size: 26, color: AppTheme.divider),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.dividerLight,
                      child: const Icon(Icons.restaurant,
                          color: AppTheme.textSecondary),
                    ),
                  ),
                  // Veg indicator in corner
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: item.dish.isVeg
                              ? AppTheme.vegGreen
                              : AppTheme.nonVegRed,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: item.dish.isVeg
                              ? AppTheme.vegGreen
                              : AppTheme.nonVegRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    CurrencyFormatter.format(item.dish.price),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _QtyControl(
                        onMinus: () => context
                            .read<AppState>()
                            .decrementOrder(item.dish.id),
                        qty: item.quantity,
                        onPlus: () =>
                            context.read<AppState>().addToOrder(item.dish),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormatter.format(item.totalPrice),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Delete
            GestureDetector(
              onTap: () =>
                  context.read<AppState>().removeFromOrder(item.dish.id),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppTheme.nonVegRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final VoidCallback onMinus;
  final int qty;
  final VoidCallback onPlus;
  const _QtyControl(
      {required this.onMinus, required this.qty, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.dividerLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onMinus,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.remove,
                  size: 14, color: AppTheme.primary),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onPlus,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.add, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
