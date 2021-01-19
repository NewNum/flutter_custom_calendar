import 'package:flutter/foundation.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';

class CalendarViewModel extends ChangeNotifier {
  int _year;

  int _month;

  CalendarSelectedMode _mode = CalendarSelectedMode.singleSelect;

  ValueNotifier<int> calendarToLeft = ValueNotifier(0);

  ValueNotifier<int> calendarToRight = ValueNotifier(0);

  bool haveNextPage = true;

  bool havePreviousPage = false;

  CalendarViewModel(this._year, this._month);

  set selectMode(CalendarSelectedMode mode) {
    _mode = mode;
    notifyListeners();
  }

  CalendarSelectedMode get selectMode => _mode;

  void setDate(int year, int month) {
    _year = year;
    _month = month;
    notifyListeners();
  }

  String getDate() => "$_year年 $_month月";
}
