import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'flutter_custom_calendar.dart';

import 'model/date_model.dart';

/// 配置信息类
class CalendarConfiguration {
  //默认是单选,可以配置为MODE_SINGLE_SELECT，MODE_MULTI_SELECT
  CalendarSelectedMode selectMode;

  //日历显示的最小年份和最大年份
  int minYear;
  int maxYear;

  //日历显示的最小年份的月份，最大年份的月份
  int minYearMonth;
  int maxYearMonth;

  //日历显示的当前的年份和月份
  int nowYear;
  int nowMonth;

  // 周视图需要
  int nowDay;

  //可操作的范围设置,比如点击选择
  int minSelectYear;
  int minSelectMonth;
  int minSelectDay;

  int maxSelectYear;
  int maxSelectMonth;
  int maxSelectDay; //注意：不能超过对应月份的总天数

  DateModel selectDateModel; //默认被选中的item，用于单选
  int maxMultiSelectCount; //多选，最多选多少个
  Map<DateModel, dynamic> extraDataMap = new Map(); //自定义额外的数据

  /// UI绘制方面的绘制
  double itemSize; //默认是屏幕宽度/7
  double verticalSpacing; //日历item之间的竖直方向间距，默认10
  BoxDecoration boxDecoration; //整体的背景设置
  EdgeInsetsGeometry padding;
  EdgeInsetsGeometry margin;

  //支持自定义绘制
  DayWidgetBuilder dayWidgetBuilder; //创建日历item
  WeekBarItemWidgetBuilder weekBarItemWidgetBuilder; //创建顶部的weekbar
  CanClick itemCanClick; //控制item是否可点击
  OnItemClick onItemClick;//item点击事件处理
  /// 监听变化
  //各种事件回调
  OnCalendarSelect calendarSelect; //点击选择事件
  OnCalendarSelect unCalendarSelect; //点击取消选择事件
  OnMultiSelect onMultiSelect; //多选点击结束回调
  OnMultiSelectOutOfRange multiSelectOutOfRange; //多选超出指定范围
  OnMultiSelectOutOfSize multiSelectOutOfSize; //多选超出限制个数

  ObserverList<OnMonthChange> monthChangeListeners =
      ObserverList<OnMonthChange>(); //保存多个月份监听的事件
  ObserverList<OnWeekChange> weekChangeListeners =
      ObserverList<OnWeekChange>(); //周视图切换

  /// 下面的信息不是配置的，是根据配置信息进行计算出来的

  List<DateModel> monthList = new List(); //月份list
  PageController monthController; //月份的controller
  DateModel minSelectDate;
  DateModel maxSelectDate;

  /// 首日偏移量 first day offset
  /// first day = (first day of month or week) + offset
  final int offset;

  CalendarConfiguration({
    this.selectMode,
    this.minYear,
    this.maxYear,
    this.minYearMonth,
    this.maxYearMonth,
    this.nowYear,
    this.nowMonth,
    this.minSelectYear,
    this.minSelectMonth,
    this.minSelectDay,
    this.maxSelectYear,
    this.maxSelectMonth,
    this.maxSelectDay,
    this.selectDateModel,
    this.maxMultiSelectCount,
    this.extraDataMap,
    this.monthList,
    this.monthController,
    this.verticalSpacing,
    this.itemSize,
    this.padding,
    this.margin,
    this.offset = 0,
    this.onItemClick
  });

  @override
  String toString() {
    return 'CalendarConfiguration{selectMode: $selectMode, minYear: $minYear, maxYear: $maxYear, minYearMonth: $minYearMonth, maxYearMonth: $maxYearMonth, nowYear: $nowYear, nowMonth: $nowMonth, nowDay: $nowDay, minSelectYear: $minSelectYear, minSelectMonth: $minSelectMonth, minSelectDay: $minSelectDay, maxSelectYear: $maxSelectYear, maxSelectMonth: $maxSelectMonth, maxSelectDay: $maxSelectDay, selectDateModel: $selectDateModel, maxMultiSelectCount: $maxMultiSelectCount, extraDataMap: $extraDataMap, itemSize: $itemSize, verticalSpacing: $verticalSpacing, boxDecoration: $boxDecoration, padding: $padding, margin: $margin, dayWidgetBuilder: $dayWidgetBuilder, weekBarItemWidgetBuilder: $weekBarItemWidgetBuilder, itemCanClick: $itemCanClick, calendarSelect: $calendarSelect, unCalendarSelect: $unCalendarSelect, onMultiSelect: $onMultiSelect, multiSelectOutOfRange: $multiSelectOutOfRange, multiSelectOutOfSize: $multiSelectOutOfSize, monthChangeListeners: $monthChangeListeners, weekChangeListeners: $weekChangeListeners, monthList: $monthList, monthController: $monthController, minSelectDate: $minSelectDate, maxSelectDate: $maxSelectDate, offset: $offset}';
  }
}
