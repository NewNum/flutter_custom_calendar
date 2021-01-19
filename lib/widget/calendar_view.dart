import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../calendar_provider.dart';
import '../controller.dart';
import '../utils/date_util.dart';
import 'month_view_pager.dart';

/// 暂时默认是周一开始的

//由于旧的代码关系。。所以现在需要抽出一个StatefulWidget放在StatelessWidget里面
class CalendarViewWidget extends StatefulWidget {
  //整体的背景设置
  final BoxDecoration boxDecoration;

  //日历的padding和margin
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  //默认是屏幕宽度/7
  final double itemSize;

  //日历item之间的竖直方向间距，默认10
  final double verticalSpacing;

  //自定义日历item
  final DayWidgetBuilder dayWidgetBuilder;
  final WeekBarItemWidgetBuilder weekBarItemWidgetBuilder;

  //控制器
  final CalendarController calendarController;
  final CanClick itemCanClick;

  CalendarViewWidget({
    Key key,
    this.itemCanClick = defaultItemClick,
    this.dayWidgetBuilder = defaultCustomDayWidget,
    this.weekBarItemWidgetBuilder = defaultWeekBarWidget,
    @required this.calendarController,
    this.boxDecoration,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.verticalSpacing = 10,
    this.itemSize,
  }) : super(key: key);

  @override
  _CalendarViewWidgetState createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  @override
  void initState() {
    //初始化一些数据，一些跟状态有关的要放到provider中
    widget.calendarController.calendarProvider.initData(
      calendarConfiguration: widget.calendarController.calendarConfiguration,
      padding: widget.padding,
      margin: widget.margin,
      itemSize: widget.itemSize,
      verticalSpacing: widget.verticalSpacing,
      dayWidgetBuilder: widget.dayWidgetBuilder,
      weekBarItemWidgetBuilder: widget.weekBarItemWidgetBuilder,
      itemCanClick: widget.itemCanClick,
    );

    super.initState();
  }

  @override
  void dispose() {
//    widget.calendarController.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalendarProvider>.value(
      value: widget.calendarController.calendarProvider,
      child: Container(
          //外部可以自定义背景设置
          decoration: widget.boxDecoration,
          padding: widget.padding,
          margin: widget.margin,
          //使用const，保证外界的setState不会刷新日历这个widget
          child: CalendarContainer(widget.calendarController)),
    );
  }
}

class CalendarContainer extends StatefulWidget {
  final CalendarController calendarController;

  const CalendarContainer(this.calendarController);

  @override
  CalendarContainerState createState() => CalendarContainerState();
}

class CalendarContainerState extends State<CalendarContainer>
    with SingleTickerProviderStateMixin {
  double itemHeight;
  double totalHeight;

  CalendarProvider calendarProvider;

  List<Widget> widgets = [];

  int index = 0;

  @override
  void initState() {
    super.initState();
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    widgets.add(const MonthViewPager());
    index = 0;

    widget.calendarController.addMonthChangeListener((year, month, position) {
      //月份切换的时候，如果高度发生变化的话，需要setState使高度整体自适应
      var lineCount = DateUtil.getMonthViewLineCount(
          year, month, widget.calendarController.calendarConfiguration.offset);
      var height = itemHeight * (lineCount) +
          calendarProvider.calendarConfiguration.verticalSpacing *
              (lineCount - 1);

      if (totalHeight.toInt() != height.toInt()) {
        setState(() {
          totalHeight = height;
        });
      }
    });

    itemHeight = calendarProvider.calendarConfiguration.itemSize;
    totalHeight = calendarProvider.totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: itemHeight * 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          /**
           * 利用const，避免每次setState都会刷新到这顶部的view
           */
          calendarProvider.calendarConfiguration.weekBarItemWidgetBuilder(),
          AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: totalHeight,
              child: IndexedStack(
                index: index,
                children: widgets,
              )),
        ],
      ),
    );
  }
}
