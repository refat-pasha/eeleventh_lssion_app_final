// placeholder
// lib/core/utils/date_utils.dart

import 'package:intl/intl.dart';

class DateUtilsHelper {
  // Default formats
  static const String defaultFormat = "yyyy-MM-dd";
  static const String displayFormat = "dd MMM yyyy";
  static const String fullFormat = "dd MMM yyyy, hh:mm a";

  // Format DateTime to string
  static String formatDate(
    DateTime date, {
    String format = displayFormat,
  }) {
    return DateFormat(format).format(date);
  }

  // Parse string to DateTime
  static DateTime? parseDate(
    String date, {
    String format = defaultFormat,
  }) {
    try {
      return DateFormat(format).parse(date);
    } catch (_) {
      return null;
    }
  }

  // Get current date formatted
  static String now({String format = displayFormat}) {
    return DateFormat(format).format(DateTime.now());
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Difference in days
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // Convert timestamp (milliseconds) to DateTime
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Convert DateTime to timestamp
  static int toTimestamp(DateTime date) {
    return date.millisecondsSinceEpoch;
  }
}