import 'package:flutter/foundation.dart';

class DateViewModel extends ChangeNotifier {
  int _year;

  int _month;

  DateViewModel(this._year, this._month);

  void setDate(int year, int month) {
    _year = year;
    _month = month;
    notifyListeners();
  }

  String getDate() => "$_month月 $_year";
}
