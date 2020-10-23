import 'dart:math';

import 'package:flutter/material.dart';

//DateTime selectedDate = DateTime.now();
int date = 0;

class Date {
  Future<DateTime> selectDate(BuildContext context,DateTime selectedDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime(2021));
    if(picked != null && picked != selectedDate)
    {
      selectedDate = picked;
//        birthdayController.text = picked.toString().split(" ")[0].trim();
    }
    return selectedDate;
  }
}