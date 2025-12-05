import 'package:intl/intl.dart';
import '../core/localization/app_localization.dart';

/// Utility class for formatting dates
class DateFormatter {
  /// Format date based on how recent it is
  static String formatDate(DateTime date, String languageCode) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppLocalization.translate('today', languageCode);
    } else if (difference.inDays == 1) {
      return AppLocalization.translate('yesterday', languageCode);
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${AppLocalization.translate('days_ago', languageCode)}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${AppLocalization.translate('weeks_ago', languageCode)}';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  /// Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}

