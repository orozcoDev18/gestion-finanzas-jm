import 'package:intl/intl.dart';

class DateService {
  static DateTime get nowUTC => DateTime.now().toUtc();
  static DateTime get nowLocal => DateTime.now();

  static DateTime startOfMonth(int year, int month) {
    return DateTime.utc(year, month, 1);
  }

  static DateTime endOfMonth(int year, int month) {
    return DateTime.utc(year, month + 1, 0, 23, 59, 59);
  }

  static bool isSameMonth(DateTime date, int year, int month) {
    return date.year == year && date.month == month;
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es').format(date.toLocal());
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM', 'es').format(date.toLocal());
  }

  static String formatMonth(int month) {
    final months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }

  static String formatMonthYear(int year, int month) {
    return '${formatMonth(month)} $year';
  }

  static int get currentMonth => DateTime.now().month;
  static int get currentYear => DateTime.now().year;

  static List<Map<String, int>> get last12Months {
    final now = DateTime.now();
    final months = <Map<String, int>>[];
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add({'year': date.year, 'month': date.month});
    }
    return months;
  }
}
