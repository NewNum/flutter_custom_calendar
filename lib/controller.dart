import 'package:flutter/material.dart';

import 'calendar_provider.dart';
import 'configuration.dart';
import 'flutter_custom_calendar.dart';
import 'model/date_model.dart';
import 'widget/default_combine_day_view.dart';
import 'widget/default_custom_day_view.dart';
import 'widget/default_week_bar.dart';
import 'widget/month_view.dart';

/// 月份切换事件
typedef OnMonthChange = void Function(int year, int month, int position);

/// 日期选择事件
typedef OnCalendarSelect = void Function(DateModel dateModel);

/// 取消选择
typedef OnCalendarUnSelect = void Function(DateModel dateModel);

/// 多选超出指定范围
typedef OnMultiSelect = void Function(Set<DateModel> dateModels);

/// 多选超出指定范围
typedef OnMultiSelectOutOfRange = void Function();

/// 多选超出限制个数
typedef OnMultiSelectOutOfSize = void Function();

/// 可以创建自定义样式的item
typedef DayWidgetBuilder = Widget Function(DateModel dateModel);

/// 是否可以点击，外部来进行判断，默认都可以点击
typedef CanClick = bool Function(DateModel dateModel);

/// 可以自定义绘制每个Item，这种扩展性好一点，以后可以提供给外部进行自定义绘制
typedef DrawDayWidget = void Function(
  DateModel dateModel,
  Canvas canvas,
  Size size,
);

/// 自定义顶部weekBar
typedef WeekBarItemWidgetBuilder = Widget Function();

/// 自定义item点击事件
typedef OnItemClick = void Function(
  ItemContainerState itemContainerState,
  CalendarConfiguration configuration,
  DateModel dateModel,
  CalendarProvider calendarProvider,
);

/// 利用controller来控制视图
class CalendarController {
  static const Set<DateTime> emptySet = {};
  static const Map<DateModel, dynamic> emptyMap = {};
  static const Duration defaultDuration = Duration(milliseconds: 500);

  CalendarConfiguration calendarConfiguration;

  CalendarProvider calendarProvider = CalendarProvider();

  /// 下面的信息不是配置的
  List<DateModel> monthList = []; //月份list
  PageController monthController; //月份的controller

  CalendarController({
    CalendarSelectedMode selectMode = CalendarSelectedMode.singleSelect,
    int minYear = 1971,
    int maxYear = 2055,
    int minYearMonth = 1,
    int maxYearMonth = 12,
    int nowYear,
    int nowMonth,
    int minSelectYear = 1971,
    int minSelectMonth = 1,
    int minSelectDay = 1,
    int maxSelectYear = 2055,
    int maxSelectMonth = 12,
    int maxSelectDay = 30,
    Set<DateTime> selectedDateTimeList = emptySet, //多选模式下，默认选中的item列表
    DateModel selectDateModel, //单选模式下，默认选中的item
    int maxMultiSelectCount = 9999,
    Map<DateModel, dynamic> extraDataMap = emptyMap,
    int offset = 1, // 首日偏移量
  }) {
    assert(offset >= 0 && offset <= 6);
    //如果没有指定当前月份和年份，默认是当年时间
    if (nowYear == null) {
      nowYear = DateTime.now().year;
    }
    if (nowMonth == null) {
      nowMonth = DateTime.now().month;
    }
    calendarConfiguration = CalendarConfiguration(
      selectMode: selectMode,
      minYear: minYear,
      maxYear: maxYear,
      maxYearMonth: maxYearMonth,
      nowYear: nowYear,
      nowMonth: nowMonth,
      minSelectYear: minSelectYear,
      minSelectMonth: minSelectMonth,
      minYearMonth: minYearMonth,
      minSelectDay: minSelectDay,
      maxSelectYear: maxSelectYear,
      maxSelectMonth: maxSelectMonth,
      extraDataMap: extraDataMap,
      maxSelectDay: maxSelectDay,
      maxMultiSelectCount: maxMultiSelectCount,
      selectDateModel: selectDateModel,
      offset: offset,
    );

    //将默认选中的数据，放到provider中
    calendarProvider.selectDateModel =
        selectDateModel ?? DateModel.fromDateTime(DateTime.now());

    calendarConfiguration.minSelectDate = DateModel.fromDateTime(DateTime(
        calendarConfiguration.minSelectYear,
        calendarConfiguration.minSelectMonth,
        calendarConfiguration.minSelectDay));
    calendarConfiguration.maxSelectDate = DateModel.fromDateTime(DateTime(
        calendarConfiguration.maxSelectYear,
        calendarConfiguration.maxSelectMonth,
        calendarConfiguration.maxSelectDay));

    _weekAndMonthViewChange();
    calendarConfiguration.onItemClick = defaultOnItemClick;
  }

  void _weekAndMonthViewChange() {
    var minYear = calendarConfiguration.minYear;
    var maxYear = calendarConfiguration.maxYear;
    var minYearMonth = calendarConfiguration.minYearMonth;
    var maxYearMonth = calendarConfiguration.maxYearMonth;
    var nowYear = calendarConfiguration.nowYear;
    var nowMonth = calendarConfiguration.nowMonth;
    //var nowDay = calendarConfiguration.selectDateModel?.day ?? -1;

    //初始化pageController,initialPage默认是当前时间对于的页面
    var initialPage = 0;
    var nowMonthIndex = 0;
    monthList.clear();
    for (var i = minYear; i <= maxYear; i++) {
      for (var j = 1; j <= 12; j++) {
        if (i == minYear && j < minYearMonth) {
          continue;
        }
        if (i == maxYear && j > maxYearMonth) {
          continue;
        }
        var dateModel = DateModel();
        dateModel.year = i;
        dateModel.month = j;

        if (i == nowYear && j == nowMonth) {
          initialPage = nowMonthIndex;
        }
        monthList.add(dateModel);
        nowMonthIndex++;
      }
    }
    monthController = PageController(initialPage: initialPage, keepPage: true);

    calendarConfiguration.monthList = monthList;
    calendarConfiguration.monthController = monthController;
  }

  //月份切换监听
  void addMonthChangeListener(OnMonthChange listener) {
    calendarConfiguration.monthChangeListeners.add(listener);
  }

  //可以动态修改extraDataMap
  void changeExtraData(Map<DateModel, dynamic> map) {
    calendarConfiguration.extraDataMap = map;
    calendarProvider.generation.value++;
  }

  //可以动态修改默认选中的item
  void changeDefaultSelectedDateModel(DateModel dateModel) {
    calendarProvider.selectDateModel = dateModel;
    calendarProvider.generation.value++;
  }

  /// 月份或者星期的上一页
  Future<bool> previousPage() async {
    //月视图
    var currentIndex =
        calendarProvider.calendarConfiguration.monthController.page.toInt();
    if (currentIndex == 0) {
      return false;
    } else {
      calendarProvider.calendarConfiguration.monthController
          .previousPage(duration: defaultDuration, curve: Curves.ease);
      for (var listener
          in calendarProvider.calendarConfiguration.monthChangeListeners) {
        var index = currentIndex - 1;
        listener.call(monthList[index].year, monthList[index].month, index);
      }
      ;
      var temp = DateModel();
      temp.year = monthList[currentIndex].year;
      temp.month = monthList[currentIndex].month;
      temp.day = monthList[currentIndex].day + 14;
      print('298 周视图的变化: $temp');
      calendarProvider.lastClickDateModel = temp;
      return true;
    }
  }

  /// 月份或者星期的下一页
  /// true：成功
  /// false:是最后一页
  Future<bool> nextPage() async {
    //月视图
    var currentIndex =
        calendarProvider.calendarConfiguration.monthController.page.toInt();
    if (monthList.length - 1 == currentIndex) {
      return false;
    } else {
      calendarProvider.calendarConfiguration.monthController
          .nextPage(duration: defaultDuration, curve: Curves.ease);
      for (var listener
          in calendarProvider.calendarConfiguration.monthChangeListeners) {
        var index = currentIndex + 1;
        listener.call(monthList[index].year, monthList[index].month, index);
      }

      var temp = DateModel();
      temp.year = monthList[currentIndex].year;
      temp.month = monthList[currentIndex].month;
      temp.day = monthList[currentIndex].day + 14;
      print('341 周视图的变化: $temp');
      calendarProvider.lastClickDateModel = temp;
      return true;
    }
  }

  int dataLength() {
    return monthList?.length ?? 0;
  }

  //跳转到指定日期
  void moveToCalendar(int year, int month, int day,
      {bool needAnimation = false,
      Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.ease}) {
    var dateModel = DateModel.fromDateTime(DateTime(year, month, 1));
    //计算目标索引
    var targetPage = monthList.indexOf(dateModel);
    if (targetPage == -1) {
      return;
    }
    if (calendarProvider.calendarConfiguration.monthController.hasClients ==
        false) {
      return;
    }
    if (needAnimation) {
      calendarProvider.calendarConfiguration.monthController
          .animateToPage(targetPage, duration: duration, curve: curve);
    } else {
      calendarProvider.calendarConfiguration.monthController
          .jumpToPage(targetPage);
    }
  }

  //切换到下一年
  void moveToNextYear(
      {bool needAnimation = false,
      Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.ease}) {
    var targetDateTime = monthList[calendarProvider
                .calendarConfiguration.monthController.page
                .toInt() +
            12]
        .getDateTime();
    moveToCalendar(
        targetDateTime.year, targetDateTime.month, targetDateTime.day,
        needAnimation: needAnimation, duration: duration, curve: curve);
  }

  //切换到上一年
  void moveToPreviousYear(
      {bool needAnimation = false,
      Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.ease}) {
    var targetDateTime = monthList[calendarProvider
                .calendarConfiguration.monthController.page
                .toInt() -
            12]
        .getDateTime();
    moveToCalendar(
        targetDateTime.year, targetDateTime.month, targetDateTime.day,
        needAnimation: needAnimation, duration: duration, curve: curve);
  }

  //切换到下一个月份,
  void moveToNextMonth(
      {bool needAnimation = false,
      Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.ease}) {
    if ((calendarProvider.calendarConfiguration.monthController.page.toInt() +
            1) >=
        monthList.length) {
      return;
    }
    var targetDateTime = monthList[calendarProvider
                .calendarConfiguration.monthController.page
                .toInt() +
            1]
        .getDateTime();
    moveToCalendar(
        targetDateTime.year, targetDateTime.month, targetDateTime.day,
        needAnimation: needAnimation, duration: duration, curve: curve);
  }

  //切换到上一个月份
  void moveToPreviousMonth(
      {bool needAnimation = false,
      Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.ease}) {
    if ((calendarProvider.calendarConfiguration.monthController.page.toInt()) ==
        0) {
      return;
    }
    var targetDateTime = monthList[calendarProvider
                .calendarConfiguration.monthController.page
                .toInt() -
            1]
        .getDateTime();
    moveToCalendar(
        targetDateTime.year, targetDateTime.month, targetDateTime.day,
        needAnimation: needAnimation, duration: duration, curve: curve);
  }

  // 获取当前的月份
  DateModel getCurrentMonth() {
    return monthList[monthController.page.toInt()];
  }

  //获取被选中的日期，单选
  DateModel getSingleSelectCalendar() {
    return calendarProvider.selectDateModel;
  }

  //清除数据
  void clearData() {
    monthList.clear();
    calendarProvider.clearData();
    calendarConfiguration.monthChangeListeners = null;
  }
}

/// 默认的weekBar
Widget defaultWeekBarWidget() {
  return const DefaultWeekBar();
}

/// 使用canvas绘制item
Widget defaultCustomDayWidget(DateModel dateModel) {
  return DefaultCustomDayWidget(
    dateModel,
  );
}

/// 使用组合widget的方式构造item
Widget defaultCombineDayWidget(DateModel dateModel) {
  return DefaultCombineDayWidget(
    dateModel,
  );
}

/// 判断是否在范围内，不在范围内的话，可以置灰
bool defaultInRange(DateModel dateModel) {
  return true;
}

/// 判断是否可以点击
bool defaultItemClick(DateModel dateModel) {
  return true;
}

/// 默认item点击事件处理
void defaultOnItemClick(
  ItemContainerState itemContainerState,
  CalendarConfiguration configuration,
  DateModel dateModel,
  CalendarProvider calendarProvider,
) {
  print('244 周视图的变化: $dateModel');
  calendarProvider.lastClickDateModel = dateModel;

  switch (configuration.selectMode) {
    //简单多选
    case CalendarSelectedMode.multiSelect:
      if (calendarProvider.selectedDateList.contains(dateModel)) {
        calendarProvider.selectedDateList.remove(dateModel);
        itemContainerState.notifyCationUnCalendarSelect(dateModel);
      } else {
        //多选，判断是否超过限制，超过范围
        if (calendarProvider.selectedDateList.length ==
            configuration.maxMultiSelectCount) {
          if (configuration.multiSelectOutOfSize != null) {
            configuration.multiSelectOutOfSize();
          }
          return;
        }
        dateModel.isSelected = !dateModel.isSelected;
        calendarProvider.selectedDateList.add(dateModel);
      }

      //多选也可以弄这些单选的代码
      calendarProvider.selectDateModel = dateModel;
      break;

    /// 单选
    case CalendarSelectedMode.singleSelect:

      /// 加入已经选择了多个 则进行取消操作
      for (var element in calendarProvider.selectedDateList) {
        element.isSelected = false;
        itemContainerState.notifyCationUnCalendarSelect(element);
      }
      calendarProvider.selectedDateList.clear();

      //单选需要刷新上一个item
      if (calendarProvider.lastClickItemState != itemContainerState) {
        calendarProvider.lastClickItemState?.refreshItem(false);
        calendarProvider.lastClickItemState = itemContainerState;
      }
      dateModel.isSelected = true;
      calendarProvider.selectDateModel = dateModel;
      itemContainerState.notifyCationCalendarSelect(dateModel);
      itemContainerState.updateWidget();
      break;

    /// 选择范围
    case CalendarSelectedMode.multiStartToEndSelect:
      if (calendarProvider.selectedDateList.isEmpty) {
        calendarProvider.selectedDateList.add(dateModel);
      } else if (calendarProvider.selectedDateList.length == 1) {
        var d2 = calendarProvider.selectedDateList.first;
        if (calendarProvider.selectedDateList.contains(dateModel)) {
          /// 选择同一个第二次则进行取消
          dateModel.isSelected = false;
          calendarProvider.selectDateModel = null;
          calendarProvider.selectedDateList.clear();
          itemContainerState.notifyCationUnCalendarSelect(dateModel);
          itemContainerState.updateWidget();
          return;
        }
        DateTime t1, t2;
        if (d2.getDateTime().isAfter(dateModel.getDateTime())) {
          t2 = d2.getDateTime();
          t1 = dateModel.getDateTime();
        } else {
          t1 = d2.getDateTime();
          t2 = dateModel.getDateTime();
        }
        for (; t1.isBefore(t2);) {
          calendarProvider.selectedDateList.add(DateModel.fromDateTime(t1));
          t1 = t1.add(Duration(days: 1));
        }
        calendarProvider.selectedDateList.add(DateModel.fromDateTime(t1));
      } else {
        /// 加入已经选择了多个 则进行取消操作
        for (var element in calendarProvider.selectedDateList) {
          element.isSelected = false;
          itemContainerState.notifyCationUnCalendarSelect(element);
        }

        /// 清空删除的 数组
        calendarProvider.selectedDateList.clear();
        itemContainerState.updateWidget();
      }
      calendarProvider.generation.value++;
      break;
  }

  /// 所有数组操作完了 进行通知分发
  if (configuration.calendarSelect != null &&
      calendarProvider.selectedDateList.isNotEmpty) {
    for (var element in calendarProvider.selectedDateList) {
      itemContainerState.notifyCationCalendarSelect(element);
    }
  }

  itemContainerState.refreshItem(!dateModel.isSelected);
}
