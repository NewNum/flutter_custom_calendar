import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/cache_data.dart';
import 'package:flutter_custom_calendar/widget/month_view.dart';
import 'configuration.dart';
import 'flutter_custom_calendar.dart';
import 'utils/LogUtil.dart';
import 'utils/date_util.dart';
import 'model/date_model.dart';

/// 引入provider的状态管理，保存一些临时信息
/// 目前的情况：只需要获取状态，不需要监听rebuild

class CalendarProvider extends ChangeNotifier {
  double _totalHeight; //当前月视图的整体高度
  HashSet<DateModel> selectedDateList = new HashSet<DateModel>(); //临时保存多选被选中的日期
  DateModel _selectDateModel; //当前选中的日期，用于单选
  ItemContainerState lastClickItemState;
  DateModel _lastClickDateModel;

  double get totalHeight => _totalHeight;

  ValueNotifier<int> _generation =
      new ValueNotifier(0); //生成的int值，每次变化，都会刷新整个日历。

  ValueNotifier<int> get generation => _generation;

  set generation(ValueNotifier<int> value) {
    _generation = value;
  }

  set totalHeight(double value) {
    _totalHeight = value;
  }

  changeTotalHeight(double value) {
    _totalHeight = value;
    notifyListeners();
  }

  DateModel get lastClickDateModel =>
      _lastClickDateModel; //保存最后点击的一个日期，用于周视图与月视图之间的切换和同步

  set lastClickDateModel(DateModel value) {
    _lastClickDateModel = value;
    print("set lastClickDateModel:$lastClickDateModel");
  }

  DateModel get selectDateModel => _selectDateModel;

  set selectDateModel(DateModel value) {
    _selectDateModel = value;
    LogUtil.log(
        TAG: this.runtimeType,
        message: "selectDateModel change:$selectDateModel");
//    notifyListeners();
  }

  //根据lastClickDateModel，去计算需要展示的月视图的index
  int get monthPageIndex {
    //计算当前月视图的index
    DateModel dateModel = lastClickDateModel;
    int index = 0;
    for (int i = 0; i < calendarConfiguration.monthList.length - 1; i++) {
      DateTime preMonth = calendarConfiguration.monthList[i].getDateTime();
      DateTime nextMonth = calendarConfiguration.monthList[i + 1].getDateTime();
      if (!dateModel.getDateTime().isBefore(preMonth) &&
          !dateModel.getDateTime().isAfter(nextMonth)) {
        index = i;
        break;
      } else {
        index++;
      }
    }

    print(
        "lastClickDateModel:$lastClickDateModel, monthPageIndex:$index, totalHeight:$totalHeight");
    return index;
  }

  ValueNotifier<bool> expandStatus; //当前展开状态

  //配置类也放这里吧，这样的话，所有子树，都可以拿到配置的信息
  CalendarConfiguration calendarConfiguration;

  void initData({
    Set<DateModel> selectedDateList,
    DateModel selectDateModel,
    CalendarConfiguration calendarConfiguration,
    EdgeInsetsGeometry padding,
    EdgeInsetsGeometry margin,
    double itemSize,
    double verticalSpacing,
    DayWidgetBuilder dayWidgetBuilder,
    WeekBarItemWidgetBuilder weekBarItemWidgetBuilder,
    CanClick itemCanClick,
  }) {
    LogUtil.log(TAG: this.runtimeType, message: "CalendarProvider initData");
    this.calendarConfiguration = calendarConfiguration;
    this.selectDateModel = this.calendarConfiguration.selectDateModel;
    this.calendarConfiguration.padding = padding;
    this.calendarConfiguration.margin = margin;
    this.calendarConfiguration.itemSize = itemSize;
    this.calendarConfiguration.verticalSpacing = verticalSpacing;
    this.calendarConfiguration.dayWidgetBuilder = dayWidgetBuilder;
    this.calendarConfiguration.weekBarItemWidgetBuilder =
        weekBarItemWidgetBuilder;
    this.calendarConfiguration.itemCanClick = itemCanClick;

    //lastClickDateModel，默认是选中的item，如果为空的话，默认是当前的时间
    this.lastClickDateModel = selectDateModel != null
        ? selectDateModel
        : DateModel.fromDateTime(DateTime.now())
      ..isSelected = true;
    //初始化item的大小。如果itemSize为空，默认是宽度/7。网页版的话是高度/7。需要减去padding和margin值
    if (calendarConfiguration.itemSize == null) {
      MediaQueryData mediaQueryData =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window);
      if (mediaQueryData.orientation == Orientation.landscape) {
        calendarConfiguration.itemSize = (mediaQueryData.size.height -
                calendarConfiguration.padding.vertical -
                calendarConfiguration.margin.vertical) /
            7;
      } else {
        calendarConfiguration.itemSize = (mediaQueryData.size.width -
                calendarConfiguration.padding.horizontal -
                calendarConfiguration.margin.horizontal) /
            7;
      }
    } else {
      //如果指定了itemSize的大小，那就按照itemSize的大小去绘制
    }
    int lineCount = DateUtil.getMonthViewLineCount(
        calendarConfiguration.nowYear,
        calendarConfiguration.nowMonth,
        calendarConfiguration.offset);
    totalHeight = calendarConfiguration.itemSize * (lineCount) +
        calendarConfiguration.verticalSpacing * (lineCount - 1);
  }

  //退出的时候，清除数据
  void clearData() {
    LogUtil.log(TAG: this.runtimeType, message: "CalendarProvider clearData");
    CacheData.getInstance().clearData();
    selectDateModel = null;
    calendarConfiguration = null;
  }
}
