import 'dart:collection';

import 'package:example/date_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/controller.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:flutter_custom_calendar/utils/date_util.dart';
import 'package:provider/provider.dart';

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
  HashSet<DateTime> _selectedDate =  HashSet();
  HashSet<DateModel> _selectedModels =  HashSet();
  GlobalKey<CalendarContainerState> _globalKey =  GlobalKey();

  @override
  void initState() {
    var startDateTime = DateTime.now();
    var endDateTime = DateUtil.getAfterMonthLastDay(2, startDateTime);
    controller =  CalendarController(
      minYear: startDateTime.year,
      minYearMonth: startDateTime.month,
      maxYear: endDateTime.year,
      maxYearMonth: endDateTime.month,
      selectedDateTimeList: _selectedDate,
      selectMode: CalendarSelectedMode.singleSelect,
    )
      ..addMonthChangeListener((year, month) {
        context.read<DateViewModel>().setDate(year, month);
      })
      ..calendarConfiguration.calendarSelect = (dateModel) {
        _selectedModels.add(dateModel);
      }
      ..calendarConfiguration.unCalendarSelect = (dateModel) {
        if (_selectedModels.contains(dateModel)) {
          _selectedModels.remove(dateModel);
        }
      };
    calendar =  CalendarViewWidget(
      key: _globalKey,
      calendarController: controller,
      verticalSpacing: 0,
      itemCanClick: (model) {
        var dateTime = DateTime(model.year, model.month, model.day);
        return DateUtil.isToday(dateTime) ||
            (model.day != 0 && DateTime.now().isBefore(dateTime));
      },
      dayWidgetBuilder: (DateModel model) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CupertinoScrollbar(
        child: CustomScrollView(
          slivers: [
            _topButtons(),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.watch<DateViewModel>().getDate()),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: calendar,
            ),
          ],
        ),
      ),
    );
  }


  Widget _topButtons() {
    return SliverToBoxAdapter(
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: <Widget>[
          Text('请选择mode'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FlatButton(
                child: Text(
                  '单选',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    controller.calendarConfiguration.selectMode =
                        CalendarSelectedMode.singleSelect;
                  });
                },
                color: controller.calendarConfiguration.selectMode ==
                        CalendarSelectedMode.singleSelect
                    ? Colors.teal
                    : Colors.black38,
              ),
              FlatButton(
                child: Text(
                  '多选',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    controller.calendarConfiguration.selectMode =
                        CalendarSelectedMode.multiSelect;
                  });
                },
                color: controller.calendarConfiguration.selectMode ==
                        CalendarSelectedMode.multiSelect
                    ? Colors.teal
                    : Colors.black38,
              ),
              FlatButton(
                child: Text(
                  '多选 选择开始和结束',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    controller.calendarConfiguration.selectMode =
                        CalendarSelectedMode.multiStartToEndSelect;
                  });
                },
                color: controller.calendarConfiguration.selectMode ==
                        CalendarSelectedMode.multiStartToEndSelect
                    ? Colors.teal
                    : Colors.black38,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
