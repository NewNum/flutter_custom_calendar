enum CalendarSelectedMode { singleSelect, multiSelect, multiStartToEndSelect }

class CalendarConstants {
  /// 单选
  static const int MODE_SINGLE_SELECT = 1;

  /// 多选
  static const int MODE_MULTI_SELECT = 2;

  /// 选择开始和结束 中间的自动选择
  static const int MODE_MULTI_SELECT_START_TO_END = 3;

  /// 一周七天
  static const List<String> WEEK_LIST = [
    "日",
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
  ];

  /// 农历的月份
  static const List<String> LUNAR_MONTH_TEXT = [
    "正月",
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "冬月",
    "腊月",
  ];

  ///   农历的日期
  static const List<String> LUNAR_DAY_TEXT = [
    "初一",
    "初二",
    "初三",
    "初四",
    "初五",
    "初六",
    "初七",
    "初八",
    "初九",
    "初十",
    "十一",
    "十二",
    "十三",
    "十四",
    "十五",
    "十六",
    "十七",
    "十八",
    "十九",
    "二十",
    "廿一",
    "廿二",
    "廿三",
    "廿四",
    "廿五",
    "廿六",
    "廿七",
    "廿八",
    "廿九",
    "三十"
  ];
}
