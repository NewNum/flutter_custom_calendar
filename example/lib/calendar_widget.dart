import 'dart:collection';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:provider/provider.dart';

import 'calendar_view_model.dart';


class WKCalendarWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WKCalendarWidgetState();
}

class _WKCalendarWidgetState extends State<WKCalendarWidget> {
  CalendarController controller;
  CalendarViewWidget calendar;
  final HashSet<DateTime> _selectedDate = HashSet();
  final HashSet<DateModel> _selectedModels = HashSet();
  final GlobalKey<CalendarContainerState> _globalKey = GlobalKey();

  @override
  void initState() {
    var startDateTime = DateTime.now();
    var endDateTime = DateUtil.getAfterMonthLastDay(2, startDateTime);
    controller = CalendarController(
      minYear: startDateTime.year,
      minYearMonth: startDateTime.month,
      maxYear: endDateTime.year,
      maxYearMonth: endDateTime.month,
      selectedDateTimeList: _selectedDate,
      selectMode: CalendarSelectedMode.singleSelect,
    )
      ..addMonthChangeListener((year, month) {
        context.read()<CalendarViewModel>().setDate(year, month);
      })
      ..calendarConfiguration.calendarSelect = _selectedModels.add
      ..calendarConfiguration.unCalendarSelect = (dateModel) {
        if (_selectedModels.contains(dateModel)) {
          _selectedModels.remove(dateModel);
        }
      };

    calendar = CalendarViewWidget(
      key: _globalKey,
      calendarController: controller,
      verticalSpacing: 0,
      itemCanClick: (model) {
        if (model == null) {
          return false;
        }
        var dateTime = DateTime(model.year, model.month, model.day);
        return DateUtil.isToday(dateTime) ||
            (model.day != 0 && DateTime.now().isBefore(dateTime));
      },
      dayWidgetBuilder: (model) {
        var modelDateTime = DateTime(model.year, model.month, model.day);
        var today = DateUtil.isToday(modelDateTime);
        return ColoredBox(
          color: model.isSelected ? Colors.red : Colors.white,
          child: Center(
            child: Text(
              model.day == 0 ? "" : (today ? "今" : model.day.toString()),
              style: TextStyle(
                  color: DateTime.now().isBefore(modelDateTime) || today
                      ? (model.isSelected ? Colors.white : Colors.black)
                      : Colors.grey),
            ),
          ),
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.calendarConfiguration.selectMode =
        context.watch<CalendarViewModel>().selectMode;
    return calendar;
  }
}
