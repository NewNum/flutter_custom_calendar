import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/calendar_provider.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/model/date_model.dart';
import 'package:flutter_custom_calendar/utils/date_util.dart';
import 'package:flutter_custom_calendar/widget/month_view.dart';
import 'package:provider/provider.dart';

class MonthViewPager extends StatefulWidget {
  MonthViewPager();

  @override
  _MonthViewPagerState createState() => _MonthViewPagerState();
}

class _MonthViewPagerState extends State<MonthViewPager> {
  CalendarProvider calendarProvider;

  var totalHeight;

  @override
  void initState() {
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    //计算当前月视图的index
    DateModel dateModel = calendarProvider.lastClickDateModel;
    List<DateModel> monthList =
        calendarProvider.calendarConfiguration.monthList;
    int index = 0;
    for (int i = 0; i < monthList.length; i++) {
      DateModel firstDayOfMonth = monthList[i];
      DateModel lastDayOfMonth = DateModel.fromDateTime(firstDayOfMonth
          .getDateTime()
          .add(Duration(
              days: DateUtil.getMonthDaysCount(
                  firstDayOfMonth.year, firstDayOfMonth.month))));

      if ((dateModel.isAfter(firstDayOfMonth) ||
              dateModel.isSameWith(firstDayOfMonth)) &&
          dateModel.isBefore(lastDayOfMonth)) {
        index = i;
        break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      calendarProvider.calendarConfiguration.pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    获取到当前的CalendarProvider对象,设置listen为false，不需要刷新
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    CalendarConfiguration configuration =
        calendarProvider.calendarConfiguration;

    return PageView.builder(
      onPageChanged: (position) {
        //月份的变化
        DateModel dateModel = configuration.monthList[position];
        configuration.monthChange(dateModel.year, dateModel.month);
        //
        calendarProvider.lastClickDateModel = configuration.monthList[position];
        //计算下高度，使PageView自适应高度

//        double itemHeight = MediaQuery.of(context).size.width / 7;
//
//        int lineCount =
//            DateUtil.getMonthViewLineCount(dateModel.year, dateModel.month);
//        double newHeight = itemHeight * lineCount +
//            configuration.verticalSpacing * (lineCount - 1);
//       if(totalHeight!=newHeight){
//         totalHeight=newHeight;
//         setState(() {
//
//         });
//       }
      },
      controller: configuration.pageController,
      itemBuilder: (context, index) {
        DateModel dateModel = configuration.monthList[index];
        return new MonthView(
          year: dateModel.year,
          month: dateModel.month,
          minSelectDate: DateModel.fromDateTime(DateTime(
              configuration.minSelectYear,
              configuration.minSelectMonth,
              configuration.minSelectDay)),
          maxSelectDate: DateModel.fromDateTime(DateTime(
              configuration.maxSelectYear,
              configuration.maxSelectMonth,
              configuration.maxSelectDay)),
          extraDataMap: configuration.extraDataMap,
        );
      },
      itemCount: configuration.monthList.length,
    );
  }
}