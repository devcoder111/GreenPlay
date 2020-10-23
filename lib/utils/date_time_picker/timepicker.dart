import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//TimeOfDay timeofday = TimeOfDay.now();

class Time{

Future<TimeOfDay> selectTime(BuildContext context, TimeOfDay timeofday) async {
  final TimeOfDay picked = await showTimePicker(
    context: context,
    initialTime: timeofday,
     );

 if (picked != null && picked != timeofday)
 
     timeofday = picked;
    
     return timeofday;
     
  }  
}