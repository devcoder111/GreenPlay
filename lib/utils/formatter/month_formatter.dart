import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:mp_chart/mp/controller/bar_line_scatter_candle_bubble_controller.dart';
import 'package:mp_chart/mp/core/value_formatter/value_formatter.dart';

class MonthFormatter extends ValueFormatter {
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

  MonthFormatter(BarLineScatterCandleBubbleController controller, BuildContext context) {
    this._controller = controller;
    this.context = context;
  }

  @override
  String getFormattedValue1(double value) {
    int days = value.toInt();
    print("test: $value");

    int month = DateTime.now().month;
    String monthName;
    if(month == 1){
      monthName = DemoLocalizations.of(context).trans("jan");
    }else if(month == 2){
      monthName = DemoLocalizations.of(context).trans("feb");
    }else if(month == 3){
      monthName = DemoLocalizations.of(context).trans("mar");
    }else if(month == 4){
      monthName = DemoLocalizations.of(context).trans("apr");
    }else if(month == 5){
      monthName = DemoLocalizations.of(context).trans("may");
    }else if(month == 6){
      monthName = DemoLocalizations.of(context).trans("jun");
    }else if(month == 7){
      monthName = DemoLocalizations.of(context).trans("jul");
    }else if(month == 8){
      monthName = DemoLocalizations.of(context).trans("aug");
    }else if(month == 9){
      monthName = DemoLocalizations.of(context).trans("sep");
    }else if(month == 10){
      monthName = DemoLocalizations.of(context).trans("oct");
    }else if(month == 11){
      monthName = DemoLocalizations.of(context).trans("nov");
    }else if(month == 12){
      monthName = DemoLocalizations.of(context).trans("dec");
    }

    days = days + 1;
    return days.toString() + monthName;
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
