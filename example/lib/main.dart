import 'dart:collection';

import 'package:example/calendar_view_model.dart';
import 'package:example/utils/colors_extension.dart';
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _ModelSwitchTab(),
        ),
        SliverToBoxAdapter(
          child: _CalendarTitle(context.watch<CalendarViewModel>()),
        ),
        SliverToBoxAdapter(
          child: WKCalendarWidget(),
        ),
      ],
    );
  }
}

class _CalendarTitle extends StatelessWidget {
  final CalendarViewModel viewModel;

  _CalendarTitle(this.viewModel);

  @override
  Widget build(BuildContext context) {
    var empty = IconButton(
      icon: ColoredBox(color: Colors.transparent),
      onPressed: () {},
    );
    var children = <Widget>[];
    if (viewModel.havePreviousPage) {
      children.add(IconButton(
        icon: Image.asset(
          "images/no_rent_left.png",
          width: 7,
          height: 12,
        ),
        onPressed: () =>
            context.read<CalendarViewModel>().calendarToLeft.value++,
      ));
    } else {
      children.add(empty);
    }
    children.add(Text(
      viewModel.getDate(),
      style: TextStyle(
        fontSize: 17,
        color: WKColors.hex222222,
      ),
    ));
    if (viewModel.haveNextPage) {
      children.add(
        IconButton(
          onPressed: () =>
              context.read<CalendarViewModel>().calendarToRight.value++,
          icon: Image.asset(
            "images/no_rent_right.png",
            width: 7,
            height: 12,
          ),
        ),
      );
    } else {
      children.add(empty);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }
}

class _ModelSwitchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var selectMode = context.watch<CalendarViewModel>().selectMode;
    CalendarSelectedMode.singleSelect;
    return Container(
      margin: EdgeInsets.only(top: 15, left: 50, right: 50, bottom: 5),
      width: double.minPositive,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _newTab(
            context,
            '按天设置',
            selectMode,
            CalendarSelectedMode.singleSelect,
          ),
          _newTab(
            context,
            '批量设置',
            selectMode,
            CalendarSelectedMode.multiStartToEndSelect,
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: WKColors.hexCB2A1E, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(3.0)),
      ),
    );
  }

  Widget _newTab(
    BuildContext context,
    String text,
    CalendarSelectedMode selectedMode,
    CalendarSelectedMode targetMode,
  ) {
    var isSelect = selectedMode == targetMode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<CalendarViewModel>().selectMode = targetMode;
        },
        child: Container(
          color: isSelect ? WKColors.hexCB2A1E : Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isSelect ? Colors.white : WKColors.hexCB2A1E,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
