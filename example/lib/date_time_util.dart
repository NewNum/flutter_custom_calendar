class DateTimeUtil {
  static DateTime getAfterMonthLastDay(int monthCount, DateTime dateTime) {
    var temp = DateTime(dateTime.year, dateTime.month + monthCount);
    return DateTime(temp.year, temp.month,
        getDayByMonth(temp.month, isLeapYear(temp.year)));
  }

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  static int getDayByMonth(int month, [bool isLeapYear = false]) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear ? 29 : 28;
      default:
        return 0;
    }
  }
}
