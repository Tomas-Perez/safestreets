/// Utility functions for DateTime.
DateTime startOfDay(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

DateTime endOfDay(DateTime dateTime) {
  final start = startOfDay(dateTime);
  final nextDay = start.add(Duration(days: 1));
  return nextDay.subtract(Duration(microseconds: 1));
}

String formatDate(DateTime dateTime) =>
    "${dateTime.day}/${dateTime.month}/${dateTime.year}";

String formatTime(DateTime dateTime) {
  String minutes =
      dateTime.minute >= 10 ? "${dateTime.minute}" : "0${dateTime.minute}";
  return "${dateTime.hour}:$minutes";
}
