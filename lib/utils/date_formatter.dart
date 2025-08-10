class DateFormatter {
  static String formatDate(DateTime date) {
    final months = [
      'sty',
      'lut',
      'mar',
      'kwi',
      'maj',
      'cze',
      'lip',
      'sie',
      'wrz',
      'paź',
      'lis',
      'gru',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'Wygasł ${formatDuration(-duration)} temu';
    }

    if (duration.inDays > 0) {
      return '${duration.inDays} dni';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} godzin';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minut';
    } else {
      return '${duration.inSeconds} sekund';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
