import 'package:flutter/material.dart';

import '../flutter_custom_calendar.dart';

///顶部的固定的周显示
class DefaultWeekBar extends StatelessWidget {
  const DefaultWeekBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: _getWeekDayWidget(),
      ),
    );
  }

  List<Widget> _getWeekDayWidget() {
    return List.generate(7, _getChild);
  }

  Widget _getChild(int index) {
    return Expanded(
      child: _getWeekBarItem(index),
    );
  }

  Widget _getWeekBarItem(int index) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(
        CalendarConstants.weekList[index],
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
