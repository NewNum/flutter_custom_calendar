import 'package:flutter/material.dart';

import '../flutter_custom_calendar.dart';
import '../style/style.dart';
import 'base_day_view.dart';

/// 这里定义成一个StatelessWidget，状态是外部的父控件传进来参数控制就行，自己不弄state类
class DefaultCustomDayWidget extends BaseCustomDayWidget {
  const DefaultCustomDayWidget(DateModel dateModel) : super(dateModel);

  @override
  void drawNormal(DateModel dateModel, Canvas canvas, Size size) {
    defaultDrawNormal(dateModel, canvas, size);
  }

  @override
  void drawSelected(DateModel dateModel, Canvas canvas, Size size) {
    defaultDrawSelected(dateModel, canvas, size);
  }
}

/// 默认的样式
void defaultDrawNormal(DateModel dateModel, Canvas canvas, Size size) {
  //顶部的文字
  var dayTextPainter =  TextPainter()
    ..text = TextSpan(
        text: dateModel.day.toString(),
        style: dateModel.isCurrentDay
            ? currentDayTextStyle
            : currentMonthTextStyle)
    ..textDirection = TextDirection.ltr
    ..textAlign = TextAlign.center;

  dayTextPainter.layout(minWidth: size.width, maxWidth: size.width);
  dayTextPainter.paint(canvas, Offset(0, 10));

  //下面的文字
  var lunarTextPainter =  TextPainter()
    ..text =  TextSpan(text: dateModel.lunarString, style: lunarTextStyle)
    ..textDirection = TextDirection.ltr
    ..textAlign = TextAlign.center;

  lunarTextPainter.layout(minWidth: size.width, maxWidth: size.width);
  lunarTextPainter.paint(canvas, Offset(0, size.height / 2));
}

/// 被选中的样式
void defaultDrawSelected(DateModel dateModel, Canvas canvas, Size size) {
  //绘制背景
  var backGroundPaint =  Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  var padding = 8.0;
  canvas.drawRect(
      Rect.fromPoints(Offset(padding, padding),
          Offset(size.width - padding, size.height - padding)),
      backGroundPaint);

  //顶部的文字
  var dayTextPainter =  TextPainter()
    ..text =
        TextSpan(text: dateModel.day.toString(), style: currentMonthTextStyle)
    ..textDirection = TextDirection.ltr
    ..textAlign = TextAlign.center;

  dayTextPainter.layout(minWidth: size.width, maxWidth: size.width);
  dayTextPainter.paint(canvas, Offset(0, 10));

  //下面的文字
  var lunarTextPainter =  TextPainter()
    ..text =  TextSpan(text: dateModel.lunarString, style: lunarTextStyle)
    ..textDirection = TextDirection.ltr
    ..textAlign = TextAlign.center;

  lunarTextPainter.layout(minWidth: size.width, maxWidth: size.width);
  lunarTextPainter.paint(canvas, Offset(0, size.height / 2));
}
