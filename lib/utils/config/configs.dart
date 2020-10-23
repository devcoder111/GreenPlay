import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:intl/intl.dart';

class FlutterToast {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: AppColors.colorLightBlue,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  static void showToastCenter(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: AppColors.colorLightBlue,
        textColor: Colors.white,
        fontSize: 15.0);
  }
}

class UtilsApp {
  static RegExp getRegexPassword() {
    Pattern pattern = r'^(?=.*?)(?=.*?)(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);

    return regex;
  }

  static bool validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return false;
    }
    else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }
}

class AWSConstants {
  static String getBucketName() {
    String bucketName = "myswimbuddy";
    return bucketName;
  }
}

class GetDeviceType {
  static String getDeviceType() {
    String _deviceType;
    if( Device.get().isAndroid ){
      _deviceType = "android";
    }else{
      _deviceType = "ios";
    }
    return _deviceType;
  }
}

class GetDeviceToken {
  getDeviceToken() async{
    String _deviceToken;
    final FirebaseMessaging _fcm = FirebaseMessaging();
    _deviceToken = await _fcm.getToken();
    return _deviceToken;
  }
}

class GetDeviceModal {
  static getDeviceModal() async{
     String _deviceModal;
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(GetDeviceType.getDeviceType() == "android"){
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceModal = androidInfo.model;
    }else{
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceModal = iosInfo.utsname.machine;
    }
    return _deviceModal;
  }
}


class SessionName {
  static getSessionName(String time, String activity, BuildContext context){
    print("bb: $time");
    String activityType = activity;
    if(activity.toLowerCase() == "walking" || activity.toLowerCase() == "marche"){
      activityType = "walk";
    }else if(activity.toLowerCase() == "bike" || activity.toLowerCase() == "vélo"){
      activityType = "bike";
    }else if(activity.toLowerCase() == "transit bus" || activity.toLowerCase() == "autobus"){
      activityType = "transit bus";
    }else if(activity.toLowerCase() == "carpooling" || activity.toLowerCase() == "covoiturage"){
      activityType = "carpooling";
    }else if(activity.toLowerCase() == "carpooling electric car" || activity.toLowerCase() == "covoiturage en voiture électrique"){
      activityType = "carpooling electric car";
    }else if(activity.toLowerCase() == "metro" || activity.toLowerCase() == "métro"){
      activityType = "metro";
    }else if(activity.toLowerCase() == "electric car" || activity.toLowerCase() == "voiture électrique"){
      activityType = "electric car";
    }else if(activity.toLowerCase() == "run" || activity.toLowerCase() == "course"){
      activityType = "running";
    }else if(activity.toLowerCase() == "remote work" || activity.toLowerCase() == "travail à distance"){
      activityType = "remote work";
    }else if(activity.toLowerCase() == "in vehicle" || activity.toLowerCase() == "En véhicule"){
      activityType = "in vehicle";
    }else if(activity.toLowerCase() == "driving alone" || activity.toLowerCase() == "conduire seul"){
      activityType = "driving alone";
    }else {
      activityType = "other";
    }


    DateTime dateNowStart5 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
      05,
      01,
      00
    );
    DateTime dateNowStart12 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
      12,
      01,
      00
    );
    DateTime dateNowEnd12 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
      12,
      00,
      00
    );
    DateTime dateNowEnd17 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
      17,
      00,
      00
    );
    DateTime dateNowStart17 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
      17,
      01,
      00
    );
    DateTime dateNowEnd21 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
      21,
      00,
      00
    );

    DateTime dateUpdatedOn = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
        int.parse(time.split(' ')[1].split(
        ':')[0]),int.parse(time.split(' ')[1].split(
        ':')[1]));

    String sessionName = "";
    if(dateUpdatedOn.isAfter(dateNowStart5) && dateUpdatedOn.isBefore(dateNowEnd12)){
      if(activityType == "walk"){
        //morning walk
        sessionName = DemoLocalizations.of(context).trans("morning_walk");
      }else if(activityType == "bike"){
        //morning bike
        sessionName = DemoLocalizations.of(context).trans("morning_bike_ride");
      }else if(activityType == "transit bus"){
        //transit bus
        sessionName = DemoLocalizations.of(context).trans("morning_bus_ride");
      }else if(activityType == "carpooling"){
        //carpool
        sessionName = DemoLocalizations.of(context).trans("morning_carpool");
      }else if(activityType == "carpooling electric car"){
        //carpool electric car
        sessionName = DemoLocalizations.of(context).trans("morning_carpool_elect");
      }else if(activityType == "metro"){
        //metro
        sessionName = DemoLocalizations.of(context).trans("morning_metro");
      }else if(activityType == "electric car"){
        //electric car
        sessionName = DemoLocalizations.of(context).trans("morning_electric");
      }else if(activityType == "running"){
        //running
        sessionName = DemoLocalizations.of(context).trans("morning_run");
      }else if(activityType == "remote work"){
        //remote work
        sessionName = DemoLocalizations.of(context).trans("morning_remote");
      }else if(activityType == "in vehicule"){
        //remote work
        sessionName = DemoLocalizations.of(context).trans("morning_vehicle");
      }else if(activityType == "driving alone"){
        //driving alone
        sessionName = DemoLocalizations.of(context).trans("morning_drive_alone");
      }else {
        //other
        sessionName = DemoLocalizations.of(context).trans("morning_other");
      }
      print("in");
    }
    else if (dateUpdatedOn.isAfter(dateNowStart12) && dateUpdatedOn.isBefore(dateNowEnd17)){
      if(activityType == "walk"){
        //afternoon walk
        sessionName = DemoLocalizations.of(context).trans("after_walk");
      }else if(activityType == "bike"){
        //afternoon bike ride
        sessionName = DemoLocalizations.of(context).trans("after_bike");
      }else if(activityType == "transit bus"){
        //afternoon transit bus
        sessionName = DemoLocalizations.of(context).trans("after_bus");
      }else if(activityType == "carpooling"){
        //afternoon carpool
        sessionName = DemoLocalizations.of(context).trans("after_carpool");
      }else if(activityType == "carpooling electric car"){
        //afternoon carpool electric car
        sessionName = DemoLocalizations.of(context).trans("after_carpool_elect");
      }else if(activityType == "metro"){
        //afternoon metro
        sessionName = DemoLocalizations.of(context).trans("after_metro");
      }else if(activityType == "electric car"){
        //afternoon electric car
        sessionName = DemoLocalizations.of(context).trans("after_car");
      }else if(activityType == "running"){
        //afternoon running
        sessionName = DemoLocalizations.of(context).trans("after_run");
      }else if(activityType == "remote work"){
        //afternoon work at home
        sessionName = DemoLocalizations.of(context).trans("after_wfh");
      }else if(activityType == "in vehicle"){
        //afternoon ride
        sessionName = DemoLocalizations.of(context).trans("after_ride");
      }else if(activityType == "driving alone"){
        //after ride
        sessionName = DemoLocalizations.of(context).trans("after_drive");
      }else {
        //after ride other
        sessionName = DemoLocalizations.of(context).trans("after_other");
      }
    }
    else if (dateUpdatedOn.isAfter(dateNowStart17) && dateUpdatedOn.isBefore(dateNowEnd21)){
      if(activityType == "walk"){
        //eve walk
        sessionName = DemoLocalizations.of(context).trans("eve_walk");
      }else if(activityType == "bike"){
        //eve bike ride
        sessionName = DemoLocalizations.of(context).trans("eve_bike");
      }else if(activityType == "transit bus"){
        //eve transit bus
        sessionName = DemoLocalizations.of(context).trans("eve_bus");
      }else if(activityType == "carpooling"){
        //eve carpool
        sessionName = DemoLocalizations.of(context).trans("eve_carpool");
      }else if(activityType == "carpooling electric car"){
        //eve carpool electric car
        sessionName = DemoLocalizations.of(context).trans("eve_carpool_elect");
      }else if(activityType == "metro"){
        //eve metro
        sessionName = DemoLocalizations.of(context).trans("eve_metro");
      }else if(activityType == "electric car"){
        //eve electric car
        sessionName = DemoLocalizations.of(context).trans("eve_elect");
      }else if(activityType == "running"){
        //eve running
        sessionName = DemoLocalizations.of(context).trans("eve_run");
      }else if(activityType == "remote work"){
        //eve work at home
        sessionName = DemoLocalizations.of(context).trans("eve_wfh");
      }else if(activityType == "in vehicle"){
        //eve ride
        sessionName = DemoLocalizations.of(context).trans("eve_ride");
      }else if(activityType == "driving alone"){
        //eve ride
        sessionName = DemoLocalizations.of(context).trans("eve_drive_alone");
      }else {
        //eve ride other
        sessionName = DemoLocalizations.of(context).trans("eve_other");
      }
    }
    else /*if (dateUpdatedOn.isAfter(dateNowEnd21) && dateUpdatedOn.isBefore(dateNowStart5))*/{
      if(activityType == "walk"){
        //eve walk
        sessionName = DemoLocalizations.of(context).trans("night_walk");
      }else if(activityType == "bike"){
        //eve bike ride
        sessionName = DemoLocalizations.of(context).trans("night_bike");
      }else if(activityType == "transit bus"){
        //eve transit bus
        sessionName = DemoLocalizations.of(context).trans("night_bus");
      }else if(activityType == "carpooling"){
        //eve carpool
        sessionName = DemoLocalizations.of(context).trans("night_carpool");
      }else if(activityType == "carpooling electric car"){
        //eve carpool electric car
        sessionName = DemoLocalizations.of(context).trans("night_carpool_elect");
      }else if(activityType == "metro"){
        //eve metro
        sessionName = DemoLocalizations.of(context).trans("night_metro");
      }else if(activityType == "electric car"){
        //eve electric car
        sessionName = DemoLocalizations.of(context).trans("night_elect");
      }else if(activityType == "running"){
        //eve running
        sessionName = DemoLocalizations.of(context).trans("night_run");
      }else if(activityType == "remote work"){
        //eve work at home
        sessionName = DemoLocalizations.of(context).trans("night_wfh");
      }else if(activityType == "in vehicle"){
        //eve ride
        sessionName = DemoLocalizations.of(context).trans("night_ride");
      }else if(activityType == "driving alone"){
        //eve ride
        sessionName = DemoLocalizations.of(context).trans("night_drive");
      }else {
        //eve ride other
        sessionName = DemoLocalizations.of(context).trans("night_drive_other");
      }
    }
    return sessionName;
  }
}


class GetDate{
   static String getDate(String type, BuildContext context){
    String _date = "";
    var now = new DateTime.now();

    var monday = 1;
    var tuesday = 2;
    var wednesday = 3;
    var thursday = 4;
    var friday = 5;
    var saturday = 6;
    var sunday = 7;

    int _dayIntStart = 0;
    int _dayIntEnd = 0;

    DateTime startDate = now;
    DateTime endDate = now;

    if(type == "week"){

      if (now.weekday == tuesday) {
        startDate = now.subtract(new Duration(days: 2));
        endDate = now.add(new Duration(days: 5));
      } else if (now.weekday == wednesday) {
        startDate = now.subtract(new Duration(days: 3));
        endDate = now.add(new Duration(days: 4));
      } else if (now.weekday == thursday) {
        startDate = now.subtract(new Duration(days: 4));
        endDate = now.add(new Duration(days: 3));
      } else if (now.weekday == friday) {
        startDate = now.subtract(new Duration(days: 5));
        endDate = now.add(new Duration(days: 2));
      } else if (now.weekday == saturday) {
        startDate = now.subtract(new Duration(days: 6));
      } else if (now.weekday == monday) {
        startDate = now.subtract(new Duration(days: 1));
        endDate = now.add(new Duration(days: 6));
      } else if (now.weekday == sunday) {
        endDate = now.add(new Duration(days: 6));
      }
      startDate = DateTime(startDate.year,startDate.month,startDate.day);
      endDate = DateTime(endDate.year,endDate.month,endDate.day);

    }else if(type == "month"){
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month, 31);
      if (now.month == 4 ||
          now.month == 6 ||
          now.month == 9 ||
          now.month == 11) {
        endDate = DateTime(now.year, now.month, 30);
      }

    }else if(type == "year"){
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year, 12, 31);

    }

    if(startDate.month == 01 || startDate.month == 1){
      _date = DemoLocalizations.of(context).trans("jan") + " " + startDate.day.toString();
    }else if(startDate.month == 2 || startDate.month == 02){
      _date = DemoLocalizations.of(context).trans("feb") + " " + startDate.day.toString();
    }else if(startDate.month == 3 || startDate.month == 03){
      _date = DemoLocalizations.of(context).trans("mar") + " " + startDate.day.toString();
    }else if(startDate.month == 4 || startDate.month == 04){
      _date = DemoLocalizations.of(context).trans("apr") + " " + startDate.day.toString();
    }else if(startDate.month == 5 || startDate.month == 05){
      _date = DemoLocalizations.of(context).trans("may") + " " + startDate.day.toString();
    }else if(startDate.month == 6 || startDate.month == 06){
      _date = DemoLocalizations.of(context).trans("jun") + " " + startDate.day.toString();
    }else if(startDate.month == 7 || startDate.month == 07){
      _date = DemoLocalizations.of(context).trans("jul") + " " + startDate.day.toString();
    }else if(startDate.month == 8 || startDate.month == 08){
      _date = DemoLocalizations.of(context).trans("aug") + " " + startDate.day.toString();
    }else if(startDate.month == 9 || startDate.month == 09){
      _date = DemoLocalizations.of(context).trans("sep") + " " + startDate.day.toString();
    }else if(startDate.month == 10){
      _date = DemoLocalizations.of(context).trans("oct") + " " + startDate.day.toString();
    }else if(startDate.month == 11){
      _date = DemoLocalizations.of(context).trans("nov") + " " + startDate.day.toString();
    }else{
      _date = DemoLocalizations.of(context).trans("dec") + " " + startDate.day.toString();
    }

    if(endDate.month == 01 || endDate.month == 1){
      _date = _date + "-" + DemoLocalizations.of(context).trans("jan") + " " + endDate.day.toString();
    }else if(endDate.month == 2 || endDate.month == 02){
      _date = _date + "-" + DemoLocalizations.of(context).trans("feb") + " " + endDate.day.toString();
    }else if(endDate.month == 3 || endDate.month == 03){
      _date = _date + "-" + DemoLocalizations.of(context).trans("mar") + " " + endDate.day.toString();
    }else if(endDate.month == 4 || endDate.month == 04){
      _date = _date + "-" + DemoLocalizations.of(context).trans("apr") + " " + endDate.day.toString();
    }else if(endDate.month == 5 || endDate.month == 05){
      _date = _date + "-" + DemoLocalizations.of(context).trans("may") + " " + endDate.day.toString();
    }else if(endDate.month == 6 || endDate.month == 06){
      _date = _date + "-" + DemoLocalizations.of(context).trans("jun") + " " + endDate.day.toString();
    }else if(endDate.month == 7 || endDate.month == 07){
      _date = _date + "-" + DemoLocalizations.of(context).trans("jul") + " " + endDate.day.toString();
    }else if(endDate.month == 8 || endDate.month == 08){
      _date = _date + "-" + DemoLocalizations.of(context).trans("aug") + " " + endDate.day.toString();
    }else if(endDate.month == 9 || endDate.month == 09){
      _date = _date + "-" + DemoLocalizations.of(context).trans("sep") + " " + endDate.day.toString();
    }else if(endDate.month == 10){
      _date = _date + "-" + DemoLocalizations.of(context).trans("oct") + " " + endDate.day.toString();
    }else if(endDate.month == 11){
      _date = _date + "-" + DemoLocalizations.of(context).trans("nov") + " " + endDate.day.toString();
    }else{
      _date = _date + "-" + DemoLocalizations.of(context).trans("dec") + " " + endDate.day.toString();
    }

    return _date;
  }
}


class GetMonth{
   static String getMonth(String dateBackend, BuildContext context){
    String _date;
    //yyyy-mm-dd for challege
    String day = dateBackend.split("-")[2];
    String year = dateBackend.split("-")[0];
    String month = dateBackend.split("-")[1];
    print(month);
    if(month == "01" || month == "1"){
      month = DemoLocalizations.of(context).trans("jan");
    }else if(month == "2" || month == "02"){
      month = DemoLocalizations.of(context).trans("feb");
    }else if(month == "3" || month == "03"){
      month = DemoLocalizations.of(context).trans("mar");
    }else if(month == "4" || month == "04"){
      month = DemoLocalizations.of(context).trans("apr");
    }else if(month == "5" || month == "05"){
      month = DemoLocalizations.of(context).trans("may");
    }else if(month == "6" || month == "06"){
      month = DemoLocalizations.of(context).trans("jun");
    }else if(month == "7" || month == "07"){
      month = DemoLocalizations.of(context).trans("jul");
    }else if(month == "8" || month == "08"){
      month = DemoLocalizations.of(context).trans("aug");
    }else if(month == "9" || month == "09"){
      month = DemoLocalizations.of(context).trans("sep");
    }else if(month == "10"){
      month = DemoLocalizations.of(context).trans("oct");
    }else if(month == "11"){
      month = DemoLocalizations.of(context).trans("nov");
    }else{
      month = DemoLocalizations.of(context).trans("dec");
    }
    return day + " " + month + " " + year;
  }
}