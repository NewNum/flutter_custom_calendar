import 'dart:collection';

import 'package:example/date_time_util.dart';
import 'package:example/date_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/controller.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:provider/provider.dart';

import 'week_bar_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime.now();
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            focusColor: Colors.teal),
        home: ChangeNotifierProvider<DateViewModel>(
            create: (_) => DateViewModel(dateTime.year, dateTime.month),
            builder: (context, _) {
              return MyHomePage(title: 'Flutter Demo Home Page');
            }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarController controller;
  CalendarViewWidget calendar;
  HashSet<DateTime> _selectedDate = new HashSet();
  HashSet<DateModel> _selectedModels = new HashSet();
  GlobalKey<CalendarContainerState> _globalKey = new GlobalKey();

  @override
  void initState() {
    var startDateTime = DateTime.now();
    var endDateTime = DateTimeUtil.getAfterMonthLastDay(2, startDateTime);
    controller = new CalendarController(
      minYear: startDateTime.year,
      minYearMonth: startDateTime.month,
      maxYear: endDateTime.year,
      maxYearMonth: endDateTime.month,
      selectedDateTimeList: _selectedDate,
      offset: 1,
    )
      ..addMonthChangeListener((year, month) {
        context.read<DateViewModel>().setDate(year, month);
      })
      ..addOnCalendarSelectListener((dateModel) {
        _selectedModels.add(dateModel);
      })
      ..addOnCalendarUnSelectListener((dateModel) {
        if (_selectedModels.contains(dateModel)) {
          _selectedModels.remove(dateModel);
        }
      });
    calendar = new CalendarViewWidget(
      key: _globalKey,
      weekBarItemWidgetBuilder: () => WeekBarWidget(),
      calendarController: controller,
      verticalSpacing: 0,
      itemCanClick: (model) {
        var dateTime = DateTime(model.year, model.month, model.day);
        return isToday(dateTime) ||
            (model.day != 0 && DateTime.now().isBefore(dateTime));
      },
      dayWidgetBuilder: (DateModel model) {
        var modelDateTime = DateTime(model.year, model.month, model.day);
        return ColoredBox(
          color: model.isSelected ? Colors.red : Colors.white,
          child: Center(
            child: Text(
              model.day == 0 ? "" : model.day.toString(),
              style: TextStyle(
                  color: DateTime.now().isBefore(modelDateTime) ||
                      isToday(modelDateTime)
                      ? model.isSelected
                      ? Colors.white
                      : Colors.black
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.watch<DateViewModel>().getDate()),
            ],
          ),
          calendar
        ],
      ),
    );
  }

  bool isToday(DateTime dateTime) {
    var now = DateTime.now();
    return now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
  }
}
