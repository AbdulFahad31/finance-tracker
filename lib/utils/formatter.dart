import 'package:intl/intl.dart';

class Formatter {
  static String formatCurrency(double amount, {required String currency}) {
    final locale = switch (currency) {
      'EUR' => 'de_DE',
      'GBP' => 'en_GB',
      'INR' => 'en_IN',
      _ => 'en_US',
    };

    final NumberFormat formatter = NumberFormat.currency(
      locale: locale,
      symbol: _currencySymbol(currency),
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String _currencySymbol(String currency) {
    return switch (currency) {
      'EUR' => '€',
      'GBP' => '£',
      'INR' => '₹',
      _ => '\$',
    };
  }
}
