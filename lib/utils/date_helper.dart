class DateHelper {
  /// Calculate medicine finish date
  /// [purchaseDate] - Date when medicine was purchased
  /// [durationDays] - Number of days the medicine will last
  static DateTime calculateFinishDate(
      DateTime purchaseDate,
      int durationDays,
      ) {
    return purchaseDate.add(Duration(days: durationDays));
  }

  /// Calculate days remaining until medicine finishes
  static int daysRemaining(DateTime finishDate) {
    final now = DateTime.now();
    return finishDate.difference(now).inDays;
  }

  /// Check if reminder should be sent (3 days before finish)
  static bool shouldSendReminder(DateTime finishDate) {
    final now = DateTime.now();
    final daysLeft = finishDate.difference(now).inDays;
    return daysLeft == 3;
  }

  /// Check if medicine is due today
  static bool isDueToday(DateTime finishDate) {
    final now = DateTime.now();
    final daysLeft = finishDate.difference(now).inDays;
    return daysLeft <= 0 && daysLeft > -7; // Within 7 days past due
  }

  /// Check if medicine is due this week
  static bool isDueThisWeek(DateTime finishDate) {
    final now = DateTime.now();
    final daysLeft = finishDate.difference(now).inDays;
    return daysLeft >= 0 && daysLeft <= 7;
  }

  /// Get all medicines due today (from a list of dates)
  static List<T> filterDueToday<T>(
      List<T> items,
      DateTime Function(T) getFinishDate,
      ) {
    return items.where((item) => isDueToday(getFinishDate(item))).toList();
  }

  /// Get all medicines due this week (from a list of dates)
  static List<T> filterDueThisWeek<T>(
      List<T> items,
      DateTime Function(T) getFinishDate,
      ) {
    return items.where((item) => isDueThisWeek(getFinishDate(item))).toList();
  }

  /// Format date to readable string (e.g., "12 Nov 2025")
  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format date time to readable string (e.g., "12 Nov 2025, 3:45 PM")
  static String formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, $hour:$minute $period';
  }

  /// Get day name (e.g., "Monday")
  static String getDayName(DateTime date) {
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  /// Get reminder text based on days remaining
  static String getReminderText(int daysRemaining) {
    if (daysRemaining < 0) {
      return 'Overdue by ${(-daysRemaining).toString()} days';
    } else if (daysRemaining == 0) {
      return 'Due today';
    } else if (daysRemaining == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $daysRemaining days';
    }
  }

  /// Parse date string (e.g., "2025-11-06")
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get current timestamp
  static DateTime getCurrentTimestamp() {
    return DateTime.now();
  }

  /// Get date only (without time)
  static DateTime getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get reminder status badge text and color
  static (String status, String color) getReminderStatus(DateTime finishDate) {
    final daysLeft = finishDate.difference(DateTime.now()).inDays;

    if (daysLeft < 0) {
      return ('Overdue', 'FF0000'); // Red
    } else if (daysLeft <= 3) {
      return ('Urgent', 'FF9800'); // Orange
    } else if (daysLeft <= 7) {
      return ('Due Soon', 'FFC107'); // Amber
    } else {
      return ('Active', '4CAF50'); // Green
    }
  }
}
