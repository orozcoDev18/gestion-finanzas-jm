import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount) {
    final format = NumberFormat.currency(
      locale: 'es_EC',
      symbol: '\$',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String currencyCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount);
  }

  static String percent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}
