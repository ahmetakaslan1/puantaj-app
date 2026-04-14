// Turkish date/calendar utilities

const List<String> trMonths = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

const List<String> trDaysShort = [
  'Pzt',
  'Sal',
  'Çar',
  'Per',
  'Cum',
  'Cmt',
  'Paz',
];

/// Converts a DateTime to YYYY-MM-DD string key.
String toDateKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Parses a YYYY-MM-DD string key to DateTime.
DateTime fromDateKey(String key) => DateTime.parse(key);

/// Formats "13 Nisan" (short, no year).
String formatDateShort(String dateKey) {
  final dt = DateTime.parse(dateKey);
  return '${dt.day} ${trMonths[dt.month - 1]}';
}

/// Formats "13 Nisan 2025" (full with year).
String formatDateFull(String dateKey) {
  final dt = DateTime.parse(dateKey);
  return '${dt.day} ${trMonths[dt.month - 1]} ${dt.year}';
}

/// Returns "Nisan 2025" label for a month.
String monthYearLabel(int year, int month) =>
    '${trMonths[month - 1]} $year';

/// Returns today's date as YYYY-MM-DD.
String todayKey() => toDateKey(DateTime.now());

/// Returns all (year, month) pairs from job startDate to today (inclusive).
List<({int year, int month})> getMonthRange(String startDateKey) {
  final start = DateTime.parse(startDateKey);
  final today = DateTime.now();

  final months = <({int year, int month})>[];
  var current = DateTime(start.year, start.month, 1);
  final endMonth = DateTime(today.year, today.month, 1);

  while (!current.isAfter(endMonth)) {
    months.add((year: current.year, month: current.month));
    // Advance to next month
    if (current.month == 12) {
      current = DateTime(current.year + 1, 1, 1);
    } else {
      current = DateTime(current.year, current.month + 1, 1);
    }
  }

  return months;
}

/// Number of days in a given month.
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
