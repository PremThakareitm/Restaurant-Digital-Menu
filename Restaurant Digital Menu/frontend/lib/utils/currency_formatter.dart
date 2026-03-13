class CurrencyFormatter {
  /// Formats [amount] as Indian Rupees (e.g. ₹299, ₹1,499).
  /// No decimal places if amount is a whole number (paise = 0).
  static String format(double amount) {
    final int paise = (amount * 100).round();
    final int rupees = paise ~/ 100;
    final int remainingPaise = paise % 100;
    final String rupeeStr = _formatIndian(rupees);
    if (remainingPaise == 0) return '₹$rupeeStr';
    return '₹$rupeeStr.${remainingPaise.toString().padLeft(2, '0')}';
  }

  static String formatWithLabel(double amount) => format(amount);

  /// Indian number formatting: 12,34,567
  static String _formatIndian(int n) {
    if (n < 1000) return n.toString();
    final String s = n.toString();
    final String last3 = s.substring(s.length - 3);
    final String rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    var i = rest.length;
    while (i > 0) {
      final int start = i > 2 ? i - 2 : 0;
      if (buf.isNotEmpty) buf.write(',');
      buf.write(rest.substring(start, i));
      i = start;
    }
    return '${buf.toString()},$last3';
  }
}
