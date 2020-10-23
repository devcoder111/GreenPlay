import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:mp_chart/mp/controller/bar_line_scatter_candle_bubble_controller.dart';
import 'package:mp_chart/mp/core/value_formatter/value_formatter.dart';

class WeekFormatter extends ValueFormatter {
  final List<String> _months = List()
    ..add("Sunday")
    ..add("Monday")
    ..add("Tuesday")
    ..add("Wednesday")
    ..add("Thursday")
    ..add("Friday")
    ..add("Saturday");

  BarLineScatterCandleBubbleController _controller;
  BuildContext context;

  WeekFormatter(BarLineScatterCandleBubbleController controller, BuildContext context) {
    this._controller = controller;
    this.context = context;
  }

  @override
  String getFormattedValue1(double value) {
    int days = value.toInt();
    print("test: $value");

    if(value == 0.0){
      return DemoLocalizations.of(context).trans("sun");
    }else if(value == 1.0){
      return DemoLocalizations.of(context).trans("mon");
    }else if(value == 2.0){
      return DemoLocalizations.of(context).trans("tue");
    }else if(value == 3.0){
      return DemoLocalizations.of(context).trans("wed");
    }else if(value == 4.0){
      return DemoLocalizations.of(context).trans("thu");
    }else if(value == 5.0){
      return DemoLocalizations.of(context).trans("fri");
    }else if(value == 6.0){
      return DemoLocalizations.of(context).trans("sat");
    }
  }

  int getDaysForMonth(int month, int year) {
    // month is 0-based

    if (month == 1) {
      bool is29Feb = false;

      if (year < 1582)
        is29Feb = (year < 1 ? year + 1 : year) % 4 == 0;
      else if (year > 1582)
        is29Feb = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

      return is29Feb ? 29 : 28;
    }

    if (month == 3 || month == 5 || month == 8 || month == 10)
      return 30;
    else
      return 31;
  }

  int determineMonth(int dayOfYear) {
    int month = -1;
    int days = 0;

    while (days < dayOfYear) {
      month = month + 1;

      if (month >= 12) month = 0;

      int year = determineYear(days);
      days += getDaysForMonth(month, year);
    }

    return max(month, 0);
  }

  int determineDayOfMonth(int days, int month) {
    int count = 0;
    int daysForMonths = 0;

    while (count < month) {
      int year = determineYear(daysForMonths);
      daysForMonths += getDaysForMonth(count % 12, year);
      count++;
    }

    return days - daysForMonths;
  }

  int determineYear(int days) {
    if (days <= 366)
      return 2016;
    else if (days <= 730)
      return 2017;
    else if (days <= 1094)
      return 2018;
    else if (days <= 1458)
      return 2019;
    else
      return 2020;
  }
}
