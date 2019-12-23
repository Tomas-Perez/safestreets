DateTime startOfDay(DateTime dateTime) {
  return DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day
  );
}

DateTime endOfDay(DateTime dateTime) {
  final start = startOfDay(dateTime);
  final nextDay = start.add(Duration(days: 1));
  return nextDay.subtract(Duration(microseconds: 1));
}