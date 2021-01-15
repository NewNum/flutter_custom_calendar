import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/widget/month_view.dart';
import 'calendar_provider.dart';
import 'configuration.dart';
import 'flutter_custom_calendar.dart';
import 'utils/LogUtil.dart';
import 'widget/default_combine_day_view.dart';
import 'widget/default_custom_day_view.dart';
import 'widget/default_week_bar.dart';

import 'model/date_model.dart';

/// 利用controller来控制视图

class CalendarController {
  static const Set<DateTime> EMPTY_SET = {};
  static const Map<DateModel, dynamic> EMPTY_MAP = {};
  static const Duration DEFAULT_DURATION = const Duration(milliseconds: 500);

  CalendarConfiguration calendarConfiguration;

  CalendarProvider calendarProvider = CalendarProvider();

  /// 下面的信息不是配置的
  List<DateModel> monthList = new List(); //月份list
  PageController monthController; //月份的controller

  CalendarController({
    CalendarSelectedMode selectMode = CalendarSelectedMode.singleSelect,
    int minYear = 1971,
    int maxYear = 2055,
    int minYearMonth = 1,
    int maxYearMonth = 12,
    int nowYear,
    int nowMonth,
    Set<DateTime> selectedDateTimeList = EMPTY_SET, //多选模式下，默认选中的item列表
    DateModel selectDateModel, //单选模式下，默认选中的item
    Map<DateModel, dynamic> extraDataMap = EMPTY_MAP,
    int offset = 0, // 首日偏移量
    OnItemClick onItemClick = defaultOnItemClick, // 首日偏移量
  }) {
    assert(offset >= 0 && offset <= 6);
    LogUtil.log(TAG: this.runtimeType, message: "init CalendarConfiguration");
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
      minYearMonth: minYearMonth,
      extraDataMap: extraDataMap,
      selectDateModel: selectDateModel,
      offset: offset,
      onItemClick: onItemClick,
    );
    //将默认选中的数据，放到provider中
    calendarProvider.selectDateModel = selectDateModel;
    _weekAndMonthViewChange();
  }

  void _weekAndMonthViewChange() {
    int minYear = calendarConfiguration.minYear;
    int maxYear = calendarConfiguration.maxYear;
    int minYearMonth = calendarConfiguration.minYearMonth;
    int maxYearMonth = calendarConfiguration.maxYearMonth;
    int nowYear = calendarConfiguration.nowYear;
    int nowMonth = calendarConfiguration.nowMonth;
    int nowDay = calendarConfiguration.selectDateModel?.day ?? -1;

    //初始化pageController,initialPage默认是当前时间对于的页面
    int initialPage = 0;
    int nowMonthIndex = 0;
    monthList.clear();
    for (int i = minYear; i <= maxYear; i++) {
      for (int j = 1; j <= 12; j++) {
        if (i == minYear && j < minYearMonth) {
          continue;
        }
        if (i == maxYear && j > maxYearMonth) {
          continue;
        }
        DateModel dateModel = new DateModel();
        dateModel.year = i;
        dateModel.month = j;

        if (i == nowYear && j == nowMonth) {
          initialPage = nowMonthIndex;
        }
        monthList.add(dateModel);
        nowMonthIndex++;
      }
    }
    this.monthController =
        new PageController(initialPage: initialPage, keepPage: true);

    LogUtil.log(
        TAG: this.runtimeType,
        message:
            "初始化月份视图的信息:一共有${monthList.length}个月，initialPage为$nowMonthIndex");

    calendarConfiguration.monthList = monthList;
    calendarConfiguration.monthController = monthController;
  }

  //月份切换监听
  void addMonthChangeListener(OnMonthChange listener) {
    this.calendarConfiguration.monthChangeListeners.add(listener);
  }

  //点击选择监听
  void addOnCalendarSelectListener(OnCalendarSelect listener) {
    this.calendarConfiguration.calendarSelect = listener;
  }

  //点击选择取消监听
  void addOnCalendarUnSelectListener(OnCalendarUnSelect listener) {
    this.calendarConfiguration.unCalendarSelect = listener;
  }

  //多选结束监听
  void addOnMultiSelectEndListener(OnMultiSelectEnd listener) {
    this.calendarConfiguration.onMultiSelectEnd = listener;
  }

  void addOnMultiSelectStartListener(OnMultiSelectStart listener){
    this.calendarConfiguration.onMultiSelectStart = listener;
  }

  //可以动态修改extraDataMap
  void changeExtraData(Map<DateModel, Object> newMap) {
    this.calendarConfiguration.extraDataMap = newMap;
    this.calendarProvider.generation.value++;
  }

  //可以动态修改默认选中的item
  void changeDefaultSelectedDateModel(DateModel dateModel) {
    this.calendarProvider.selectDateModel = dateModel;
    this.calendarProvider.generation.value++;
  }

  /// 月份或者星期的上一页
  Future<bool> previousPage() async {
    //月视图
    int currentIndex =
        calendarProvider.calendarConfiguration.monthController.page.toInt();
    if (currentIndex == 0) {
      return false;
    } else {
      calendarProvider.calendarConfiguration.monthController
          .previousPage(duration: DEFAULT_DURATION, curve: Curves.ease);
      calendarProvider.calendarConfiguration.monthChangeListeners
          .forEach((listener) {
        listener(monthList[currentIndex - 1].year,
            monthList[currentIndex - 1].month);
      });
      DateModel temp = new DateModel();
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
    int currentIndex =
        calendarProvider.calendarConfiguration.monthController.page.toInt();
    if (monthList.length - 1 == currentIndex) {
      return false;
    } else {
      calendarProvider.calendarConfiguration.monthController
          .nextPage(duration: DEFAULT_DURATION, curve: Curves.ease);
      calendarProvider.calendarConfiguration.monthChangeListeners
          .forEach((listener) {
        listener(monthList[currentIndex + 1].year,
            monthList[currentIndex + 1].month);
      });

      DateModel temp = new DateModel();
      temp.year = monthList[currentIndex].year;
      temp.month = monthList[currentIndex].month;
      temp.day = monthList[currentIndex].day + 14;
      print('341 周视图的变化: $temp');
      calendarProvider.lastClickDateModel = temp;
      return true;
    }
  }

  //跳转到指定日期
  void moveToCalendar(int year, int month, int day,
      {bool needAnimation = false,
      Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.ease}) {
    DateModel dateModel = DateModel.fromDateTime(DateTime(year, month, 1));
    //计算目标索引
    int targetPage = monthList.indexOf(dateModel);
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
    DateTime targetDateTime = monthList[calendarProvider
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
    DateTime targetDateTime = monthList[calendarProvider
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
      LogUtil.log(TAG: this.runtimeType, message: "moveToNextMonth：当前是最后一个月份");
      return;
    }
    DateTime targetDateTime = monthList[calendarProvider
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
      LogUtil.log(
          TAG: this.runtimeType, message: "moveToPreviousMonth：当前是第一个月份");
      return;
    }
    DateTime targetDateTime = monthList[calendarProvider
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
  return new DefaultCombineDayWidget(
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

  calendarProvider.lastClickDateModel = dateModel;

  switch (configuration.selectMode) {
    //简单多选
    case CalendarSelectedMode.multiSelect:
      if (calendarProvider.selectedDateList.contains(dateModel)) {
        calendarProvider.selectedDateList.remove(dateModel);
        itemContainerState.notifiCationUnCalendarSelect(dateModel);
      } else {
        //多选，判断是否超过限制，超过范围
        dateModel.isSelected = !dateModel.isSelected;
        calendarProvider.selectedDateList.add(dateModel);
      }

      //多选也可以弄这些单选的代码
      calendarProvider.selectDateModel = dateModel;
      break;

    /// 单选
    case CalendarSelectedMode.singleSelect:

      /// 加入已经选择了多个 则进行取消操作
      calendarProvider.selectedDateList.forEach((element) {
        element.isSelected = false;
        itemContainerState.notifiCationUnCalendarSelect(element);
      });
      calendarProvider.selectedDateList.clear();

      //单选需要刷新上一个item
      if (calendarProvider.lastClickItemState != itemContainerState) {
        calendarProvider.lastClickItemState?.refreshItem(false);
        calendarProvider.lastClickItemState = itemContainerState;
      }
      dateModel.isSelected = true;
      calendarProvider.selectDateModel = dateModel;
      itemContainerState.notifiCationCalendarSelect(dateModel);
      itemContainerState.updateWidget();
      break;

    /// 选择范围
    case CalendarSelectedMode.multiStartToEndSelect:
      if (calendarProvider.selectedDateList.length == 0) {
        calendarProvider.selectedDateList.add(dateModel);
      } else if (calendarProvider.selectedDateList.length == 1) {
        DateModel d2 = calendarProvider.selectedDateList.first;
        if (calendarProvider.selectedDateList.contains(dateModel)) {
          /// 选择同一个第二次则进行取消
          dateModel.isSelected = false;
          calendarProvider.selectDateModel = null;
          calendarProvider.selectedDateList.clear();
          itemContainerState.notifiCationUnCalendarSelect(dateModel);
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
        calendarProvider.selectedDateList.forEach((element) {
          element.isSelected = false;
          itemContainerState.notifiCationUnCalendarSelect(element);
        });

        /// 清空删除的 数组
        calendarProvider.selectedDateList.clear();
        itemContainerState.updateWidget();
      }
      calendarProvider.generation.value++;
      break;
  }

  /// 所有数组操作完了 进行通知分发
  if (configuration.calendarSelect != null &&
      calendarProvider.selectedDateList.length > 0) {
    calendarProvider.selectedDateList.forEach((element) {
      itemContainerState.notifiCationCalendarSelect(element);
    });
  }

  itemContainerState.refreshItem(!dateModel.isSelected);
}

/// 周视图切换
typedef void OnWeekChange(int year, int month);

/// 月份切换事件
typedef void OnMonthChange(int year, int month);

/// 日期选择事件
typedef void OnCalendarSelect(DateModel dateModel);

/// 取消选择
typedef void OnCalendarUnSelect(DateModel dateModel);

/// 多选结束
typedef void OnMultiSelectEnd(Set<DateModel> dateModels);

/// 多选开始
typedef void OnMultiSelectStart(DateModel dateModels);

/// 可以创建自定义样式的item
typedef Widget DayWidgetBuilder(DateModel dateModel);

/// 是否可以点击，外部来进行判断，默认都可以点击
typedef bool CanClick(DateModel dateModel);

/// 可以自定义绘制每个Item，这种扩展性好一点，以后可以提供给外部进行自定义绘制
typedef void DrawDayWidget(DateModel dateModel, Canvas canvas, Size size);

/// 自定义顶部weekBar
typedef Widget WeekBarItemWidgetBuilder();

/// 自定义item点击事件
typedef void OnItemClick(
  ItemContainerState itemContainerState,
  CalendarConfiguration configuration,
  DateModel dateModel,
  CalendarProvider calendarProvider,
);
