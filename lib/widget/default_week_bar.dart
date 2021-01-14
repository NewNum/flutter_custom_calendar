import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/style/style.dart';

import 'base_week_bar.dart';

///顶部的固定的周显示
class DefaultWeekBar extends BaseWeekBar {
  const DefaultWeekBar({Key key}) : super(key: key);

  @override
  Widget getWeekBarItem(int index) {
    return new Container(
      height: 40,
      alignment: Alignment.center,
      child: new Text(
        CalendarConstants.WEEK_LIST[index],
        style: topWeekTextStyle,
      ),
    );
  }
}
