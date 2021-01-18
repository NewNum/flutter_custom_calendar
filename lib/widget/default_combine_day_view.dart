import 'package:flutter/material.dart';
import '../flutter_custom_calendar.dart';
import '../style/style.dart';

import 'base_day_view.dart';

/// 默认的利用组合widget的方式构造item

class DefaultCombineDayWidget extends BaseCombineDayWidget {
  DefaultCombineDayWidget(DateModel dateModel) : super(dateModel);

  @override
  Widget getNormalWidget(DateModel dateModel) {
    return Container(
      margin: EdgeInsets.all(8),
      child:  Stack(
        alignment: Alignment.center,
        children: <Widget>[
           Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //公历
               Expanded(
                child: Center(
                  child:  Text(
                    dateModel.day.toString(),
                    style: currentMonthTextStyle,
                  ),
                ),
              ),

              //农历
               Expanded(
                child: Center(
                  child:  Text(
                    "${dateModel.lunarString}",
                    style: lunarTextStyle,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget getSelectedWidget(DateModel dateModel) {
    return Container(
      margin: EdgeInsets.all(8),
      foregroundDecoration:
           BoxDecoration(border: Border.all(width: 2, color: Colors.blue)),
      child:  Stack(
        alignment: Alignment.center,
        children: <Widget>[
           Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //公历
               Expanded(
                child: Center(
                  child:  Text(
                    dateModel.day.toString(),
                    style: currentMonthTextStyle,
                  ),
                ),
              ),

              //农历
               Expanded(
                child: Center(
                  child:  Text(
                    "${dateModel.lunarString}",
                    style: lunarTextStyle,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
