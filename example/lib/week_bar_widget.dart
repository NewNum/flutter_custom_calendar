import 'package:flutter/material.dart';

/// 顶部的固定的周显示
class WeekBarWidget extends StatelessWidget {
  WeekBarWidget({Key key}) : super(key: key);

  final List<String> _weekList = [
    "日",
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Row(
        children: _getWeekDayWidget(),
      ),
    );
  }

  List<Widget> _getWeekDayWidget() {
    return List.generate(7, (index) {
      return _getChild(index);
    });
  }

  Widget _getChild(int index) {
    return new Expanded(
      child: _getWeekBarItem(index),
    );
  }

  Widget _getWeekBarItem(int index) {
    return new Container(
      height: 40,
      alignment: Alignment.center,
      child: new Text(
        _weekList[index],
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
