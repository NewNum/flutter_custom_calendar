import '../flutter_custom_calendar.dart';

/// 工具类
class DateUtil {
  /// 判断一个日期是否是周末，即周六日
  static bool isWeekend(DateTime dateTime) {
    return dateTime.weekday == DateTime.saturday ||
        dateTime.weekday == DateTime.sunday;
  }

  /// 获取某年的天数
  static int getYearDaysCount(int year) {
    if (isLeapYear(year)) {
      return 366;
    }
    return 365;
  }

  static DateTime getAfterMonthLastDay(int monthCount, DateTime dateTime) {
    var temp = DateTime(dateTime.year, dateTime.month + monthCount);
    return DateTime(
        temp.year, temp.month, getMonthDaysCount(temp.year, temp.month));
  }

  /// 获取某月的天数
  ///
  /// @param year  年
  /// @param month 月
  /// @return 某月的天数
  static int getMonthDaysCount(int year, int month) {
    var count = 0;
    //判断大月份
    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      count = 31;
    }

    //判断小月
    if (month == 4 || month == 6 || month == 9 || month == 11) {
      count = 30;
    }

    //判断平年与闰年
    if (month == 2) {
      if (isLeapYear(year)) {
        count = 29;
      } else {
        count = 28;
      }
    }
    return count;
  }

  /// 是否是今天
  static bool isCurrentDay(int year, int month, int day) {
    var now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  /// 是否是今天
  static bool isToday(DateTime dateTime) {
    return isCurrentDay(dateTime.year, dateTime.month, dateTime.day);
  }

  /// 是否是闰年
  static bool isLeapYear(int year) {
    return ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
  }

  /// 本月的第几周
  static int getIndexWeekInMonth(DateTime dateTime) {
    var firstDayInMonth =  DateTime(dateTime.year, dateTime.month, 1);
    var duration = dateTime.difference(firstDayInMonth);
    return duration.inDays ~/ 7 + 1;
  }

  /// 本周的第几天
  static int getIndexDayInWeek(DateTime dateTime) {
    var firstDayInMonth =  DateTime(
      dateTime.year,
      dateTime.month,
    );
    var duration = dateTime.difference(firstDayInMonth);
    return duration.inDays ~/ 7 + 1;
  }

  /// 本月第一天，是那一周的第几天,从1开始
  /// @return 获取日期所在月视图对应的起始偏移量 the start diff with MonthView

  static int getIndexOfFirstDayInMonth(DateTime dateTime, {int offset = 0}) {
    var firstDayOfMonth =  DateTime(dateTime.year, dateTime.month, 1);

    var week = firstDayOfMonth.weekday + offset;

    return week;
  }

  static List<DateModel> initCalendarForMonthView(
    int year,
    int month,
    DateTime currentDate,
    int weekStart, {
    DateModel minSelectDate,
    DateModel maxSelectDate,
    Map<DateModel, dynamic> extraDataMap,
    int offset = 0,
  }) {
    print('initCalendarForMonthView start');
    weekStart = DateTime.monday;
    //获取月视图真实偏移量
    var mPreDiff =
        getIndexOfFirstDayInMonth( DateTime(year, month), offset: offset);
    //获取该月的天数
    var monthDayCount = getMonthDaysCount(year, month);
    var result =  <DateModel>[];
    var size = 42;

    var firstDayOfMonth =  DateTime(year, month, 1);
    var lastDayOfMonth =  DateTime(year, month, monthDayCount);

    for (var i = 0; i < size; i++) {
      DateTime temp;
      DateModel dateModel;
      if (i < mPreDiff - 1) {
        if (i < ((mPreDiff / 7).ceil() - 1) * 7) {
          size++;
          continue;
        }
        //这个上一月的几天
        temp = firstDayOfMonth.subtract(Duration(days: mPreDiff - i - 1));
        dateModel = DateModel.fromDateTime(temp);
        dateModel.day = 0;
        dateModel.isCurrentMonth = false;
      } else if (i >= monthDayCount + (mPreDiff - 1)) {
        //这是下一月的几天
        temp = lastDayOfMonth
            .add(Duration(days: i - mPreDiff - monthDayCount + 2));
        dateModel = DateModel.fromDateTime(temp);
        dateModel.day = 0;
        dateModel.isCurrentMonth = false;
      } else {
        //这个月的
        temp =  DateTime(year, month, i - mPreDiff + 2);
        dateModel = DateModel.fromDateTime(temp);
        dateModel.isCurrentMonth = true;
      }

      //判断是否在范围内
      if (dateModel.getDateTime().isAfter(minSelectDate.getDateTime()) &&
          dateModel.getDateTime().isBefore(maxSelectDate.getDateTime())) {
        dateModel.isInRange = true;
      } else {
        dateModel.isInRange = false;
      }
      //将自定义额外的数据，存储到相应的model中
      if (extraDataMap?.isNotEmpty == true) {
        if (extraDataMap.containsKey(dateModel)) {
          dateModel.extraData = extraDataMap[dateModel];
        } else {
          dateModel.extraData = null;
        }
      } else {
        dateModel.extraData = null;
      }

      result.add(dateModel);
    }

    print('initCalendarForMonthView end');

    return result;
  }

  /// 月的行数
  static int getMonthViewLineCount(int year, int month, int offset) {
    var firstDayOfMonth =  DateTime(year, month, 1);
    var monthDayCount = getMonthDaysCount(year, month);

    var preIndex = (firstDayOfMonth.weekday - 1 + offset) % 7;
    var lineCount = ((preIndex + monthDayCount) / 7).ceil();

    return lineCount;
  }

  /// 获取本周的7个item
  static List<DateModel> initCalendarForWeekView(
      int year, int month, DateTime currentDate, int weekStart,
      {DateModel minSelectDate,
      DateModel maxSelectDate,
      Map<DateModel, dynamic> extraDataMap,
      int offset = 0,}) {
    var items = <DateModel>[];

    var weekDay = currentDate.weekday + offset;

    //计算本周的第一天
    var firstDayOfWeek = currentDate.add(Duration(days: -weekDay));

    for (var i = 1; i <= 7; i++) {
      var dateModel =
          DateModel.fromDateTime(firstDayOfWeek.add(Duration(days: i)));

      //判断是否在范围内
      if (dateModel.getDateTime().isAfter(minSelectDate.getDateTime()) &&
          dateModel.getDateTime().isBefore(maxSelectDate.getDateTime())) {
        dateModel.isInRange = true;
      } else {
        dateModel.isInRange = false;
      }
      if (month == dateModel.month) {
        dateModel.isCurrentMonth = true;
      } else {
        dateModel.isCurrentMonth = false;
      }

      //将自定义额外的数据，存储到相应的model中
      if (extraDataMap?.isNotEmpty == true) {
        if (extraDataMap.containsKey(dateModel)) {
          dateModel.extraData = extraDataMap[dateModel];
        }
      }

      items.add(dateModel);
    }
    return items;
  }
}
