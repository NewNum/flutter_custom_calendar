import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../calendar_provider.dart';
import '../flutter_custom_calendar.dart';
import '../utils/date_util.dart';
import 'month_view.dart';

class MonthViewPager extends StatefulWidget {
  const MonthViewPager({Key key}) : super(key: key);

  @override
  _MonthViewPagerState createState() => _MonthViewPagerState();
}

class _MonthViewPagerState extends State<MonthViewPager>
    with AutomaticKeepAliveClientMixin {
  CalendarProvider calendarProvider;

  @override
  void initState() {
    super.initState();
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    //计算当前月视图的index
    var dateModel = calendarProvider.lastClickDateModel;
    var monthList = calendarProvider.calendarConfiguration.monthList;
    var index = 0;
    for (var i = 0; i < monthList.length; i++) {
      var firstDayOfMonth = monthList[i];
      var monthDaysCount = DateUtil.getMonthDaysCount(
        firstDayOfMonth.year,
        firstDayOfMonth.month,
      );
      var duration = Duration(days: monthDaysCount);
      var add = firstDayOfMonth.getDateTime().add(duration);
      var lastDayOfMonth = DateModel.fromDateTime(add);

      if ((dateModel.isAfter(firstDayOfMonth) ||
              dateModel.isSameWith(firstDayOfMonth)) &&
          dateModel.isBefore(lastDayOfMonth)) {
        index = i;
        break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      calendarProvider.calendarConfiguration.monthController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
//    获取到当前的CalendarProvider对象,设置listen为false，不需要刷新
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    var configuration = calendarProvider.calendarConfiguration;

    return PageView.builder(
      onPageChanged: (position) {
        //月份的变化
        var dateModel = configuration.monthList[position];
        for (var listener in configuration.monthChangeListeners) {
          listener.call(dateModel.year, dateModel.month);
        }
      },
      controller: configuration.monthController,
      itemBuilder: (context, index) {
        final dateModel = configuration.monthList[index];
        return MonthView(
          configuration: configuration,
          year: dateModel.year,
          month: dateModel.month,
        );
      },
      itemCount: configuration.monthList.length,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
