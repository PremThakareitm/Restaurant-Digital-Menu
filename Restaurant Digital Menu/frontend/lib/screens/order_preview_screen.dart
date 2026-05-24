import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_digital_menu/services/auth_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';
import '../utils/test_ids.dart';
import '../widgets/order_item_tile.dart';

class OrderPreviewScreen extends StatelessWidget {
  const OrderPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.orderItems;
    final history = state.orderHistory;

    return Semantics(
      identifier: TestIds.orderScreen,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('My Order'),
              if (items.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.totalOrderItems}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (items.isNotEmpty)
              Semantics(
                identifier: TestIds.orderClearButton,
                child: TextButton.icon(
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.nonVegRed, size: 18),
                  label: Text(
                    'Clear',
                    style: GoogleFonts.outfit(
                        color: AppTheme.nonVegRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              ),
            const SizedBox(width: 4),
          ],
        ),
        body: items.isEmpty && history.isEmpty
            ? const _EmptyOrder()
            : ResponsiveBuilder(
                builder: (context, screenType, screenWidth) {
                  final horizontalPad =
                      ResponsiveHelper.getHorizontalPadding(screenWidth);
                  final maxContentWidth =
                      ResponsiveHelper.getMaxContentWidth(screenWidth);

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.fromLTRB(
                                  horizontalPad, 16, horizontalPad, 16),
                              children: [
                                if (items.isNotEmpty) ...[
                                  // ─── Table number ────────────────────
                                  _TableSelector(state: state),
                                  const SizedBox(height: 16),
                                  // ─── Order items ──────────────────────
                                  ...items.map(
                                    (item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: OrderItemTile(item: item),
                                    ),
                                  ),
                                  // ─── Special notes ────────────────────
                                  _SpecialNotesField(state: state),
                                  const SizedBox(height: 16),
                                ],
                                if (history.isNotEmpty) ...[
                                  _OrderHistorySection(history: history),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                          if (items.isNotEmpty)
                            _OrderSummary(
                                state: state, horizontalPad: horizontalPad),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.nonVegRed.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: AppTheme.nonVegRed, size: 28),
        ),
        title: Text(
          'Clear Order?',
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'All items will be removed from your order.',
          style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Cancel',
                style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().clearOrder();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.nonVegRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text('Clear',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Order Summary Card ────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final AppState state;
  final double horizontalPad;
  final AuthService _authService = AuthService();

  _OrderSummary({required this.state, required this.horizontalPad});

  @override
  Widget build(BuildContext context) {
    final subtotal = state.totalOrderPrice;
    final tax = subtotal * AppConstants.taxRate;
    final total = subtotal + tax;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(14),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(horizontalPad, 6, horizontalPad, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _SummaryRow(
              label:
                  'Subtotal  ·  ${state.totalOrderItems} item${state.totalOrderItems > 1 ? 's' : ''}',
              value: CurrencyFormatter.format(subtotal)),
          const SizedBox(height: 8),
          _SummaryRow(
              label:
                  'GST (${(AppConstants.taxRate * 100).toInt()}%)',
              value: '+  ${CurrencyFormatter.format(tax)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.dividerLight),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payable',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Semantics(
                identifier: TestIds.orderPlaceButton,
                child: ElevatedButton.icon(
                  onPressed: () => _placeOrder(context, state),
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 18),
                  label: const Text('Place Order'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    textStyle: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, AppState state) async {
    final orderPayload = state.orderItems
        .map(
          (item) => {
            'dishId': item.dish.id,
            'quantity': item.quantity,
          },
        )
        .toList();

    final success = await _authService.submitOrder(
      items: orderPayload,
      tableNumber: state.tableNumber,
      note: state.orderNote,
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not place order. Please try again.')),
      );
      return;
    }

    final placedOrder = state.placeOrder();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _OrderPlacedDialog(order: placedOrder),
    );
  }
}

class _TableSelector extends StatelessWidget {
  final AppState state;
  const _TableSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: TestIds.orderTableField,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.dividerLight),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.table_restaurant_outlined,
                      size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Select Table',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (state.tableNumber != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.tableNumber == 0
                          ? '🛵 Takeaway'
                          : '🪑 Table ${state.tableNumber}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TableChip(
                  label: '🛵',
                  sublabel: 'Takeaway',
                  value: 0,
                  selected: state.tableNumber == 0,
                  onTap: () => state.setTableNumber(0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(12, (index) {
                final tableNum = index + 1;
                final selected = state.tableNumber == tableNum;
                return _TableChip(
                  label: '$tableNum',
                  value: tableNum,
                  selected: selected,
                  onTap: () => state.setTableNumber(tableNum),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableChip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final int value;
  final bool selected;
  final VoidCallback onTap;
  const _TableChip({
    required this.label,
    this.sublabel,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: value == 0 ? null : 44,
        height: 40,
        padding: value == 0
            ? const EdgeInsets.symmetric(horizontal: 14)
            : EdgeInsets.zero,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected
              ? AppTheme.primaryGradient
              : null,
          color: selected ? null : AppTheme.dividerLight,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected ? AppTheme.primaryShadow(alpha: 55) : [],
        ),
        child: value == 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14)),
                  if (sublabel != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      sublabel!,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              )
            : Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _SpecialNotesField extends StatefulWidget {
  final AppState state;
  const _SpecialNotesField({required this.state});

  @override
  State<_SpecialNotesField> createState() => _SpecialNotesFieldState();
}

class _SpecialNotesFieldState extends State<_SpecialNotesField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.orderNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded,
                    size: 16, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Special Instructions',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 2,
            maxLength: 200,
            onChanged: (v) => context.read<AppState>().setOrderNote(v),
            decoration: InputDecoration(
              hintText: 'e.g. No onions, extra spicy, nut allergy...',
              counterText: '',
              filled: true,
              fillColor: AppTheme.surfaceWarm,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistorySection extends StatelessWidget {
  final List<PlacedOrder> history;
  const _OrderHistorySection({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history_rounded,
                      size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Order History',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.dividerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'This session',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerLight),
          ...history.take(5).map((order) => _HistoryTile(order: order)),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PlacedOrder order;
  const _HistoryTile({required this.order});

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppTheme.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 20, color: AppTheme.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.token,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.success,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(order.placedAt),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppTheme.textSecondary.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(order.total),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Placed Dialog ───────────────────────────────────────────────────────
class _OrderPlacedDialog extends StatefulWidget {
  final PlacedOrder order;
  const _OrderPlacedDialog({required this.order});

  @override
  State<_OrderPlacedDialog> createState() => _OrderPlacedDialogState();
}

class _OrderPlacedDialogState extends State<_OrderPlacedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.shadowLg,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Gradient header ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD55A3A),
                      Color(0xFF882010),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 44, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Order Confirmed! 🎉',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sit back & relax — your meal is being crafted with love',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white.withAlpha(200),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Token + details ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER TOKEN',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textSecondary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.primary.withAlpha(60),
                            width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.token,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: order.token));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Token copied!',
                                      style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 13)),
                                  backgroundColor: AppTheme.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.copy_rounded,
                                  size: 17, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 12, color: AppTheme.textHint),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Show this token at the counter to collect your order',
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    // Stats row
                    Row(
                      children: [
                        _SummaryPill(
                          icon: Icons.shopping_bag_outlined,
                          label:
                              '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                        ),
                        const SizedBox(width: 8),
                        _SummaryPill(
                          icon: Icons.currency_rupee_rounded,
                          label: CurrencyFormatter.format(order.total),
                        ),
                        const SizedBox(width: 8),
                        const _SummaryPill(
                          icon: Icons.schedule_rounded,
                          label: '25–35 min',
                        ),
                      ],
                    ),

                    if (order.tableNumber != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWarm,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.table_restaurant_outlined,
                                size: 16, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              order.tableNumber == 0
                                  ? '🛵  Takeaway Order'
                                  : '🪑  Table ${order.tableNumber}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (order.note != null &&
                        order.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWarm,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.edit_note_rounded,
                                size: 16, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.note!,
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Text('🍛',
                            style: TextStyle(fontSize: 16)),
                        label: Text('Enjoy your meal!',
                            style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWarm,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Icon(icon, size: 17, color: AppTheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(width: 16),
        Text(
          value,
          style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}

// ─── Empty Order ───────────────────────────────────────────────────────────────
class _EmptyOrder extends StatefulWidget {
  const _EmptyOrder();

  @override
  State<_EmptyOrder> createState() => _EmptyOrderState();
}

class _EmptyOrderState extends State<_EmptyOrder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _float,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _float.value),
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🛒', style: TextStyle(fontSize: 46)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing ordered yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Explore our menu and add your\nfavourite dishes here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
