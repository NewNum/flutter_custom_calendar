import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'LogUtil.dart';

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

  /// 获取某月的天数
  ///
  /// @param year  年
  /// @param month 月
  /// @return 某月的天数
  static int getMonthDaysCount(int month, int year) {
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
        return isLeapYear(year) ? 29 : 28;
      default:
        return 0;
    }
  }

  ///获取几个月后的最后一天
  /// @params monthCount 月数
  /// @params dateTime 起始时间
  static DateTime getAfterMonthLastDay(int monthCount, DateTime dateTime) {
    var temp = DateTime(dateTime.year, dateTime.month + monthCount);
    return DateTime(
        temp.year, temp.month, getMonthDaysCount(temp.year, temp.month));
  }

  /// 是否是今天
  static bool isCurrentDay(int year, int month, int day) {
    DateTime now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  /// 是否是今天
  static bool isToday(DateTime dateTime) {
    var now = DateTime.now();
    return now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
  }

  /// 是否是闰年
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  /// 本月的第几周
  static int getIndexWeekInMonth(DateTime dateTime) {
    DateTime firstDayInMonth = new DateTime(dateTime.year, dateTime.month, 1);
    Duration duration = dateTime.difference(firstDayInMonth);
    return duration.inDays ~/ 7 + 1;
  }

  /// 本周的第几天
  static int getIndexDayInWeek(DateTime dateTime) {
    DateTime firstDayInMonth = new DateTime(
      dateTime.year,
      dateTime.month,
    );
    Duration duration = dateTime.difference(firstDayInMonth);
    return duration.inDays ~/ 7 + 1;
  }

  /// 本月第一天，是那一周的第几天,从1开始
  /// @return 获取日期所在月视图对应的起始偏移量 the start diff with MonthView

  static int getIndexOfFirstDayInMonth(DateTime dateTime, {int offset = 0}) {
    DateTime firstDayOfMonth = new DateTime(dateTime.year, dateTime.month, 1);

    int week = firstDayOfMonth.weekday + offset;

    return week;
  }

  static List<DateModel> initCalendarForMonthView(
    int year,
    int month,
    DateTime currentDate,
    int weekStart, {
    Map<DateModel, Object> extraDataMap,
    int offset = 0,
  }) {
    print('initCalendarForMonthView start');
    weekStart = DateTime.monday;
    //获取月视图真实偏移量
    int mPreDiff =
        getIndexOfFirstDayInMonth(new DateTime(year, month), offset: offset);
    //获取该月的天数
    int monthDayCount = getMonthDaysCount(year, month);

    List<DateModel> result = new List();

    int size = 42;

    DateTime firstDayOfMonth = new DateTime(year, month, 1);
    DateTime lastDayOfMonth = new DateTime(year, month, monthDayCount);

    for (int i = 0; i < size; i++) {
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
        temp = new DateTime(year, month, i - mPreDiff + 2);
        dateModel = DateModel.fromDateTime(temp);
        dateModel.isCurrentMonth = true;
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
    DateTime firstDayOfMonth = new DateTime(year, month, 1);
    int monthDayCount = getMonthDaysCount(year, month);

    int preIndex = (firstDayOfMonth.weekday - 1 + offset) % 7;
    int lineCount = ((preIndex + monthDayCount) / 7).ceil();
    LogUtil.log(
        TAG: "DateUtil",
        message: "getMonthViewLineCount:$year年$month月:有$lineCount行");

    return lineCount;
  }

  /// 获取本周的7个item
  static List<DateModel> initCalendarForWeekView(
      int year, int month, DateTime currentDate, int weekStart,
      {DateModel minSelectDate,
      DateModel maxSelectDate,
      Map<DateModel, Object> extraDataMap,
      int offset = 0}) {
    List<DateModel> items = List();

    int weekDay = currentDate.weekday + offset;

    //计算本周的第一天
    DateTime firstDayOfWeek = currentDate.add(Duration(days: -weekDay));

    for (int i = 1; i <= 7; i++) {
      DateModel dateModel =
          DateModel.fromDateTime(firstDayOfWeek.add(Duration(days: i)));

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
