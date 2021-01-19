import 'dart:collection';

import 'package:example/calendar_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:provider/provider.dart';

import 'calendar_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime.now();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          focusColor: Colors.teal),
      home: ChangeNotifierProvider<CalendarViewModel>(
          create: (_) => CalendarViewModel(dateTime.year, dateTime.month),
          builder: (context, _) {
            return MyHomePage(title: 'Flutter Demo Home Page');
          }),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return CupertinoScrollbar(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ModelSwitchTab(),
          ),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.watch<CalendarViewModel>().getDate()),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: WKCalendarWidget(),
          ),
        ],
      ),
    );
  }
}

class _ModelSwitchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var isSingle = context.watch<CalendarViewModel>().selectMode ==
        CalendarSelectedMode.singleSelect;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
      width: double.minPositive,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<CalendarViewModel>().selectMode =
                    CalendarSelectedMode.singleSelect;
              },
              child: ColoredBox(
                  color: isSingle ? Colors.red : Colors.transparent,
                  child: Center(
                    child: Text(
                      '单选',
                      style: TextStyle(
                        color: isSingle ? Colors.white : Colors.red,
                      ),
                    ),
                  )),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<CalendarViewModel>().selectMode =
                    CalendarSelectedMode.multiStartToEndSelect;
              },
              child: ColoredBox(
                color: isSingle ? Colors.transparent : Colors.red,
                child: Center(
                  child: Text(
                    '多选',
                    style: TextStyle(
                      color: isSingle ? Colors.red : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.red, width: 1), //边框
        borderRadius: BorderRadius.all(
          //圆角
          Radius.circular(3.0),
        ),
      ),
    );
  }
}
