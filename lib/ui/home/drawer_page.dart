import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_session_modal.dart';
import 'package:greenplayapp/redux/model/data_add_session.dart';
import 'package:greenplayapp/redux/model/session_data.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/ui/home/sessions/session_list_page.dart';
import 'package:greenplayapp/ui/home/sessions/session_add_page.dart';
import 'package:greenplayapp/ui/home/settings/settings_page.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/language/language_application.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:greenplayapp/utils/views_common/logo.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'account/account_page.dart';
import 'challenges/my_challenges_tab_page.dart';
import 'dashboard/dashboard_page.dart';
import 'faq/faq_screen.dart';
import 'newsfeed/newsfeed_page.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;


class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class DrawerPage extends StatefulWidget {

  final drawerItems = [
    new DrawerItem("Dashboard", Icons.dashboard),
    new DrawerItem("NewsFeed", Icons.rss_feed),
//    new DrawerItem("All Challenges", Icons.drive_eta),
    new DrawerItem("Challenges", Icons.drive_eta),
    new DrawerItem("Sessions", Icons.settings),
    new DrawerItem("Account", Icons.account_box),
    new DrawerItem("Settings", Icons.add_to_home_screen),
    new DrawerItem("Faq", Icons.add_to_home_screen),
    new DrawerItem("Logout", Icons.add_to_home_screen)
  ];

  DrawerPage();


  @override
  State<StatefulWidget> createState() {
    return new DrawerPageState();
  }
}

class DrawerPageState extends State<DrawerPage> {
  int _selectedDrawerIndex = 0;
  Store<AppState> store;
  List<DrawerItem> drawerItems;
  var drawerOptions;
  SharedPreferences _prefs;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bg.Location _lastKnownPosition;
  bg.Location _currentPosition;
  var geoLocator = Geolocator();


  final FirebaseDatabase _database = FirebaseDatabase.instance;

  int _radioValue = -1; //Initial definition of radio button value
  String _radioLanguage = 'english'; //Initial definition of radio button value
  String choice;


  static final List<String> languagesList =
      languageApplication.supportedLanguages;
  static final List<String> languageCodesList =
      languageApplication.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    observer.subscribe(this, ModalRoute.of(context));
  }



  _getDrawerItemWidget(int pos, BuildContext context) {
    switch (pos) {
      case 0:
        return new DashboardPage();
      case 1:
        return new NewsFeedTabPage();
//      case 2:
//        return new AllChallengeScreen();
      case 2:
        return new ChallengeTabScreen();
      case 3:
        return new SessionListScreen();
//        return new SessionAddPage();
      case 4:
        return new AccountPage();
      case 5:
        return new SettingsPage();
      case 6:
//        _launchURL('');
        return new FaqScreen();
        return;
      case 7:
        Future.delayed(Duration.zero, () => signOutGoogle());
        return new Container(
        );

      default:
        return new Text("In progress");
    }
  }


  void _sendCurrentTabToAnalytics(String eventName, Map<String,int> map) {
    observer.analytics.logEvent(
        name: eventName,
        parameters: map

    );

    analytics.setCurrentScreen(
      screenName: 'Analytics Demo',
      screenClassOverride: 'AnalyticsDemo',
    );
//    setMessage('setCurrentScreen succeeded');

    analytics.logEvent(
      name: 'test_event',
      parameters: <String, dynamic>{
        'string': 'string',
        'int': 42,
        'long': 12345678910,
        'double': 42.0,
        'bool': true,
      },
    );
    print("message");
  }


  void signOutGoogle() async {
    await googleSignIn.signOut();
    await _prefs.setString(PreferenceNames.token, null);
    await _prefs.setString(PreferenceNames.timePrevious, null);
    await _prefs.setString(PreferenceNames.timeInit, null);
    await _prefs.setString(PreferenceNames.transportTypeUpdated, null);
    await _prefs.setString(PreferenceNames.transportType, null);
    await _prefs.setDouble(PreferenceNames.distanceNow, null);
    await _prefs.setDouble(PreferenceNames.sessionId, null);
    await _prefs.setDouble(PreferenceNames.timeInit, null);

    bg.BackgroundGeolocation.stop();

    Keys.navKey.currentState.pushNamedAndRemoveUntil(
        Routes.loginScreen, (Route<dynamic> route) => false);
  }


  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }



  Future<void> _getDistance() async{
    print('aaaa: '+'inside1');
    if(_currentPosition != null &&  _lastKnownPosition != null&&  _prefs.getString(PreferenceNames.timePrevious) != null) {
      print('aaaa: '+'inside');
      double distanceInMeters = await Geolocator().distanceBetween(
          _currentPosition.coords.latitude, _currentPosition.coords.longitude,
          _lastKnownPosition.coords.latitude, _lastKnownPosition.coords.longitude);

//      distanceInMeters = 2000;
      if(distanceInMeters < 1.0) {
//        return;
      }

        if(_prefs != null){
        if(_prefs.getDouble(PreferenceNames.distanceNow) != null){
          final Map<String, int> someMap = {
            "a": 1,
            "b": 3,
          };
          _sendCurrentTabToAnalytics("init", someMap);

          double _prevDist = _prefs.getDouble(PreferenceNames.distanceNow);
          double _diff = 0.0;
          if(distanceInMeters > _prevDist){
            _diff = distanceInMeters - _prevDist;
          }else{
            _diff = _prevDist - distanceInMeters;
          }

          print('now: '+_prefs.getString(PreferenceNames.timePrevious));
          final _prevDate = DateTime(int.parse(_prefs.getString(PreferenceNames.timePrevious).split(' ')[0].split('-')[0]),
              int.parse(_prefs.getString(PreferenceNames.timePrevious).split(' ')[0].split('-')[1]),
              int.parse(_prefs.getString(PreferenceNames.timePrevious).split(' ')[0].split('-')[2]),
              int.parse(_prefs.getString(PreferenceNames.timePrevious).split(' ')[1].split(':')[0]),
              int.parse(_prefs.getString(PreferenceNames.timePrevious).split(' ')[1].split(':')[1]));
          final differenceTime = DateTime.now().difference(_prevDate).inMinutes;


          print('now: '+distanceInMeters.toString());
          print('diff: '+_diff.toString());
          print('diffTime: '+differenceTime.toString());
          print('aaaa: '+_prefs.getString(PreferenceNames.transportTypeUpdated));
          print('aaaa: '+_prefs.getString(PreferenceNames.transportType));
          if(_currentPosition == null){
            return ;
          }
          print('acceleration: '+_currentPosition.coords.speed.toString());
          print('activityType: '+_currentPosition.activity.type.toString());



          print('aaa Time is more ');

          if(_prefs.getString(PreferenceNames.transportType) == _currentPosition.activity.type){
            print('aaaaaaaaaa1: ');
            _updateDataBase(distanceInMeters,_currentPosition).then((value){

            });
          }else {
            print('aaaaaaaa2');
            _prefs.setString(PreferenceNames.transportTypeUpdated, _currentPosition.activity.type);
            _prefs.setString(PreferenceNames.transportType, _currentPosition.activity.type);
            _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
            _prefs.setString(PreferenceNames.transportTypeUpdated, _currentPosition.activity.type);
            _prefs.setString(PreferenceNames.sessionId, DateTime.now().millisecondsSinceEpoch.toString()+_prefs.get(PreferenceNames.token));
            _prefs.setString(PreferenceNames.timePrevious,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
                + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());
            _prefs.setString(PreferenceNames.timeInit,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
                + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());

            _addDataBase(distanceInMeters,_currentPosition).then((value){
              _lastKnownPosition = _currentPosition;
              _prefs.setDouble(PreferenceNames.lastLat, _currentPosition.coords.latitude);
              _prefs.setDouble(PreferenceNames.lastLong, _currentPosition.coords.longitude);
              _currentPosition = null;
            });
          }

          if(differenceTime > 5 &&  _diff > 5.0){

          }else{
            print('aaa Time is less ');
          }
        }else{
          _prefs.setString(PreferenceNames.transportTypeUpdated, _currentPosition.activity.type);
          _prefs.setString(PreferenceNames.transportType, _currentPosition.activity.type);
          _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
          _prefs.setString(PreferenceNames.transportTypeUpdated, _currentPosition.activity.type);
          _prefs.setString(PreferenceNames.sessionId, DateTime.now().millisecondsSinceEpoch.toString()+_prefs.get(PreferenceNames.token));
          _prefs.setString(PreferenceNames.timePrevious,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
              + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());
          _prefs.setString(PreferenceNames.timeInit,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
              + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());

          _addDataBase(distanceInMeters,_currentPosition).then((value){
            _lastKnownPosition = _currentPosition;
            _prefs.setDouble(PreferenceNames.lastLat, _currentPosition.coords.latitude);
            _prefs.setDouble(PreferenceNames.lastLong, _currentPosition.coords.longitude);
            _currentPosition = null;
          });
        }
      }


    }else{
      print('aaaa: '+'inside2');
      _prefs.setString(PreferenceNames.timePrevious,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
          + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());
    }
  }


  Future<void> _addDataBase(double distanceInMeters, bg.Location currentPosition) async{
    SessionData _sessionData = new SessionData();
    _sessionData.startTime = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
//    _sessionData.distance = distanceInMeters.toString();
    _prefs.setDouble(PreferenceNames.lastLat, currentPosition.coords.latitude);
    _prefs.setDouble(PreferenceNames.lastLong, currentPosition.coords.longitude);
    _sessionData.distance = "300.0";
    _prefs.setString(PreferenceNames.timeInit,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
        + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());


    String activity = currentPosition.activity.type.toString().toLowerCase();
    if(currentPosition.activity.type.toString().toLowerCase() == "in_vehicle"){
      activity = "In vehicle";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "on_bicycle"){
      activity = "Bike";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "on_foot"){
      activity = "Walking";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "running"){
      activity = "Running";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "unknown"){
      activity = "Unknown";
    }

    _sessionData.activityType = activity ;
    _sessionData.speed = currentPosition.coords.speed.toString();
    _sessionData.sessionType = 'Automatic';

    Data _data = new Data();
    _data.userId = _prefs.getString(PreferenceNames.token);
    _data.movementDateTime = DateTime.now().millisecondsSinceEpoch.toString();
    _data.sessionData = _sessionData;

    AddSession _session = new AddSession();
    _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
    _session.userId = _prefs.getString(PreferenceNames.token);
    _session.source = GetDeviceType.getDeviceType();
    _session.createdOn = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
    _session.updatedOn = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
    _session.currentDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _session.sessionYear = DateFormat('yyyy-MM').format(DateTime.now());
    _session.delete = "0";
    _session.data = _data;


    print("pushed");
    _database.reference().child(DataBaseConstants.sessionData).push().set(_session.toJson());
    _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
  }


  Future<void> _updateDataBase(double distanceInMeters, bg.Location currentPosition) async{
    SessionData _sessionData = new SessionData();
    _sessionData.startTime =_prefs.getString(PreferenceNames.timeInit);
    _sessionData.distance = distanceInMeters.toString();

    String activity = currentPosition.activity.type.toString().toLowerCase();
    if(currentPosition.activity.type.toString().toLowerCase() == "in_vehicle"){
      activity = "In vehicle";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "on_bicycle"){
      activity = "Bike";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "on_foot"){
      activity = "Walking";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "running"){
      activity = "Running";
    }else if(currentPosition.activity.type.toString().toLowerCase() == "unknown"){
      activity = "Unknown";
    }
    _sessionData.activityType = activity;
    _sessionData.speed = currentPosition.coords.speed.toString();
    _sessionData.sessionType = 'Automatic';

    _prefs.setDouble(PreferenceNames.lastLat, currentPosition.coords.latitude);
    _prefs.setDouble(PreferenceNames.lastLong, currentPosition.coords.longitude);

    Data _data = new Data();
    _data.userId = _prefs.getString(PreferenceNames.token);
    _data.movementDateTime = DateTime.now().millisecondsSinceEpoch.toString();
    _data.sessionData = _sessionData;

    AddSession _session = new AddSession();
    _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
    _session.userId = _prefs.getString(PreferenceNames.token);
    _session.source = GetDeviceType.getDeviceType();
    _session.createdOn = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
    _session.updatedOn = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
    _session.currentDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _session.sessionYear = DateFormat('yyyy-MM').format(DateTime.now());
    _session.data = _data;


    final _prevDate = DateTime(int.parse(_prefs.getString(PreferenceNames.timeInit).split(' ')[0].split('-')[0]),
        int.parse(_prefs.getString(PreferenceNames.timeInit).split(' ')[0].split('-')[1]),
        int.parse(_prefs.getString(PreferenceNames.timeInit).split(' ')[0].split('-')[2]),
        int.parse(_prefs.getString(PreferenceNames.timeInit).split(' ')[1].split(':')[0]),
        int.parse(_prefs.getString(PreferenceNames.timeInit).split(' ')[1].split(':')[1]));
    final differenceTime = DateTime.now().difference(_prevDate).inDays;
    print('bbb:'+_prefs.getString(PreferenceNames.timeInit));
    print(differenceTime);

    if(differenceTime <  1) {
      _database.reference().child(DataBaseConstants.sessionData).orderByChild("sessionId")
          .equalTo(_prefs.getString(PreferenceNames.sessionId)).once().
      then((snapshot) async {
        if (snapshot.value != null) {
          _database.reference().child(DataBaseConstants.sessionData).orderByChild("sessionId")
              .equalTo(_prefs.getString(PreferenceNames.sessionId)).once().
          then((snapshot) async {
            if (snapshot.value != null) {
              Map<dynamic, dynamic> map = snapshot.value;
              _session.createdOn = map.values.toList()[0]["createdOn"];
              String updatedOn = map.values.toList()[0]["updatedOn"];

              final _updatedDate = DateTime(int.parse(updatedOn.split(' ')[0].split('-')[0]),
                  int.parse(updatedOn.split(' ')[0].split('-')[1]),
                  int.parse(updatedOn.split(' ')[0].split('-')[2]),
                  int.parse(updatedOn.split(' ')[1].split(':')[0]),
                  int.parse(updatedOn.split(' ')[1].split(':')[1]));
              final differenceTime = DateTime.now().difference(_updatedDate).inMinutes;
              if(differenceTime > 10){
                var _key = map.keys.toList()[0];
                if (map.values.toList()[0]["data"] != null) {
                  _sessionData.distance = distanceInMeters.toString();
                  _sessionData.startTime = map.values.toList()[0]["StartTime"];
                }
                _prefs.setString(PreferenceNames.transportTypeUpdated, currentPosition.activity.type);
                _prefs.setString(PreferenceNames.transportType, currentPosition.activity.type);
                _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
                _prefs.setString(PreferenceNames.transportTypeUpdated, currentPosition.activity.type);
                _prefs.setString(PreferenceNames.sessionId, DateTime.now().millisecondsSinceEpoch.toString()+_prefs.get(PreferenceNames.token));
                _prefs.setString(PreferenceNames.timePrevious,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
                    + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());
                _prefs.setString(PreferenceNames.timeInit,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
                    + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());

                _sessionData.startTime =_prefs.getString(PreferenceNames.timeInit);
                _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
                _addDataBase(distanceInMeters, currentPosition);
//                return;
              }else{
                var _key = map.keys.toList()[0];
                if (map.values.toList()[0]["data"] != null) {
                  var value = double.parse(map.values
                      .toList()[0]["data"]["SessionData"]["distance"]) +
                      distanceInMeters;
                  _sessionData.distance = value.toString();
                  _sessionData.startTime = map.values.toList()[0]["StartTime"];

                  var speedValue = double.parse(map.values
                      .toList()[0]["data"]["SessionData"]["Speed"]) +
                      currentPosition.coords.speed;
                  double avgSpeed = speedValue/2;
                  _sessionData.speed = avgSpeed.toString();
                }
                print("pushed1");
                _database.reference().child(DataBaseConstants.sessionData).child(_key).update(
                    _session.toJson());
              }
            }
          });
          _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
          _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
        } else {
          _prefs.setString(PreferenceNames.transportTypeUpdated, currentPosition.activity.type);
          _prefs.setString(PreferenceNames.transportType, currentPosition.activity.type);
          _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
          _prefs.setString(PreferenceNames.transportTypeUpdated, currentPosition.activity.type);
          _prefs.setString(PreferenceNames.sessionId, DateTime.now().millisecondsSinceEpoch.toString()+_prefs.get(PreferenceNames.token));
          _prefs.setString(PreferenceNames.timePrevious,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
              + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());
          _prefs.setString(PreferenceNames.timeInit,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
              + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());

          _sessionData.startTime =_prefs.getString(PreferenceNames.timeInit);
          _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
          _addDataBase(distanceInMeters, currentPosition);
        }
        _lastKnownPosition = currentPosition;
        _currentPosition = null;
        return;
      });
    }else{
      _prefs.setString(PreferenceNames.transportTypeUpdated, currentPosition.activity.type);
      _prefs.setString(PreferenceNames.transportType, currentPosition.activity.type);
      _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
      _prefs.setString(PreferenceNames.transportTypeUpdated, currentPosition.activity.type);
      _prefs.setString(PreferenceNames.sessionId, DateTime.now().millisecondsSinceEpoch.toString()+_prefs.get(PreferenceNames.token));
      _prefs.setString(PreferenceNames.timePrevious,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
          + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());
      _prefs.setString(PreferenceNames.timeInit,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
          + "-" + DateTime.now().day.toString() + " " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString());

      _sessionData.startTime =_prefs.getString(PreferenceNames.timeInit);
      _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
      _addDataBase(distanceInMeters, currentPosition);
    }


  }


  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }



  @override
  void initState() {
//    initPlatformState();

    initPref();
//    _acceleration();
    final Map<String, int> someMap = {
      "a": 1,
      "b": 3,
    };
    _sendCurrentTabToAnalytics("init", someMap);
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
      if(_lastKnownPosition == null){
        _lastKnownPosition = location;
        _prefs.setDouble(PreferenceNames.lastLat, location.coords.latitude);
        _prefs.setDouble(PreferenceNames.lastLong, location.coords.longitude);
        return;
      }
        _currentPosition = location;
      //[Location {odometer: 3247.0, activity: {confidence: 100, type: still}, extras: {},
      // battery: {level: 0.67, is_charging: true}, uuid: b961a6d5-13ed-4bf2-85c6-8882267906f3,
      // coords: {altitude: -1.0, heading: 30.19, latitude: 30.8993781, accuracy: 67.3, speed: 0.01, longitude: 75.9216836},
      // is_moving: true, timestamp: 2020-05-01T12:46:21.105Z}]
//      _getActivity().then(( status) {
//
////
//        });
      String session = PrefsSingleton.prefs.getString(PreferenceNames.isSession);
      if(session == null){
        session = "Automatic";
      }
      if(location.activity.type.toLowerCase() != 'still' && location.isMoving && session == "Automatic"){
        _getDistance();
      }
      print("eeeee");

//      location.


    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    /// /
    // 2.  Configure the plugin
    //l
    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0,
      stopOnTerminate: false,
      startOnBoot: true,
      allowIdenticalLocations: true,
      notificationTitle: "Greenplay",
      notificationText: "Fetching location",
      debug: false,
      enableHeadless: true,
      foregroundService: true,
      forceReloadOnMotionChange: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      fastestLocationUpdateInterval: 1,
      isMoving: true,
    )).then((bg.State state) {
      if (!state.enabled) {
        ////
        // 3.  Start the plugin.
        //
        bg.BackgroundGeolocation.start();
        bg.BackgroundGeolocation.changePace(true);
      }
    });

    bg.BackgroundGeolocation.getCurrentPosition(
        persist: false,     // <-- do not persist this location
        desiredAccuracy: 0, // <-- desire best possible accuracy
        timeout: 30000,     // <-- wait 30s before giving up.
        samples: 3          // <-- sample 3 location before selecting best.
    ).then((bg.Location location) {
      print('[getCurrentPosition] - $location');
      _lastKnownPosition =  location;
      _prefs.setDouble(PreferenceNames.lastLat, location.coords.latitude);
      _prefs.setDouble(PreferenceNames.lastLong, location.coords.longitude);
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
    // Manually fetch the current position.


    super.initState();
  }


  //initialize shared preference here.......
  Future<void> initPref() async {
    _prefs = PrefsSingleton.prefs;
    if(_prefs.getString(PreferenceNames.language) != null){
    if(_prefs.getString(PreferenceNames.language).toLowerCase() == 'english'){
      _radioLanguage = 'english';
      _radioValue = 0;
    }else{
      _radioLanguage = 'french';
      _radioValue = 1;
     }
    }else{
      _radioLanguage = 'english';
      _radioValue = 0;
    }

  }


  Future<void> _dialogLanguage() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.colorWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              title: Text(DemoLocalizations.of(context).trans('sel_language'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(18),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  ),textScaleFactor: 1.0),
              content: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,color: AppColors.colorWhite,
                        borderRadius: BorderRadius.all(new Radius.circular(20))
                    ),
                    height: ScreenUtil.getInstance().setHeight(140),
                    // Change as per your requirement
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              new Radio(
                                value: 0,
                                groupValue: _radioValue,
                                activeColor: AppColors.colorBlack,
                                onChanged: (int value) {
                                  setState(() {
                                    _radioValue = value;
                                  });
                                  // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                },
                              ),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('english'),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance()
                                      .setWidth(15),
                                  color: AppColors.colorBlack,
                                  fontWeight: FontWeight.w400,
                                ),textScaleFactor: 1.0
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              new Radio(
                                value: 1,
                                groupValue: _radioValue,
                                activeColor: AppColors.colorBlack,
                                onChanged: (int value) {
                                  setState(() {
                                    _radioValue = value;
                                  });
                                  // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                },
                              ),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('french'),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance()
                                      .setWidth(15),
                                  color: AppColors.colorBlack,
                                  fontWeight: FontWeight.w400,
                                ),textScaleFactor: 1.0
                              )
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_cancel')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      ),textScaleFactor: 1.0),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_ok')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      ),textScaleFactor: 1.0),
                  onPressed: ()async {
                    if(_radioValue == 0) {
                      _radioLanguage = 'english';
                    }else{
                      _radioLanguage = 'french';
                    }
                    if(_radioLanguage == 'english'){
                      await languageApplication.onLocaleChanged(Locale('en'));
                    }else{
                      await languageApplication.onLocaleChanged(Locale('fr_FR'));
                    }
                    _prefs.setString(PreferenceNames.language, _radioLanguage);
                    FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('language_changed'));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, _DrawerModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _DrawerModel.create(store, context);
        },
        onInit: (appState) async {},
        builder: (BuildContext context, _DrawerModel data) {
          return
            Theme(
              data: ThemeData(primaryIconTheme: IconThemeData(color: AppColors.colorBlue),), // use this
          child:Scaffold(
            appBar: new AppBar(
              title:Container(
                child: Text(
                    _selectedDrawerIndex == 0 ? DemoLocalizations.of(context).trans('dashboard') :
                    _selectedDrawerIndex == 1 ? DemoLocalizations.of(context).trans('news') :
                    _selectedDrawerIndex == 2 ? DemoLocalizations.of(context).trans('challenges') :
                    _selectedDrawerIndex == 3 ? DemoLocalizations.of(context).trans('session') :
                    _selectedDrawerIndex == 4 ? DemoLocalizations.of(context).trans('acc') :
                    _selectedDrawerIndex == 5 ? DemoLocalizations.of(context).trans('settings') :
                    _selectedDrawerIndex == 6 ? DemoLocalizations.of(context).trans('faq').toUpperCase() :
                    DemoLocalizations.of(context).trans('logout_drawer'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(22),
                    color: AppColors.colorBlue,
                    fontWeight: FontWeight.w600,
                  ),
                    textScaleFactor: 1.0
                ),
              ),
              centerTitle: true,
              backgroundColor:AppColors.colorBgGray,
              elevation: 0,
              actions: <Widget>[
                _selectedDrawerIndex == 5 ? InkWell(
                  onTap: ( ){
                    _dialogLanguage( );
                  },
                  child:
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        ScreenUtil.getInstance().setWidth(10),
                        ScreenUtil.getInstance().setWidth(0),
                        ScreenUtil.getInstance().setWidth(20),
                        ScreenUtil.getInstance().setWidth(5)),
                    child: SvgPicture.asset(
                      'asset/language.svg',
                      height: ScreenUtil.getInstance().setWidth(25),
                      width: ScreenUtil.getInstance().setHeight(25),
                      allowDrawingOutsideViewBox: true,
                      color: AppColors.colorBgBlue,
                    ),
                  ),
                ) :
                    Container()
              ],
            ),
            drawer: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: AppColors
                      .colorBlue, //This will change the drawer background to blue.
                  //other styles
                ),
                child:
                Drawer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Color(0xFF347AAE),
                            Color(0xFF4C95CC),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(40),
                          right: ScreenUtil.getInstance().setWidth(20),
                          left: ScreenUtil.getInstance().setWidth(20)),
                      child:  SingleChildScrollView(
                        child:
                        Column(
                          children: <Widget>[
                            Container(
                              child:
                              TopLogo('drawer'),
                              margin: EdgeInsets.only(bottom: 10),
                            ),
                            InkWell(
                              onTap: () async {
                                Keys.navKey.currentState.pushNamed(Routes.accountScreen, arguments: "drawer");
//                                return new AccountPage();
                              },
                              child:
                              Row(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  _userImage(data),
//                              Spacer(),
                                  Container(
                                    margin: EdgeInsets.only(left: 20,bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            child: Text(
                                              data.userAppModal.firstName ?? ""+
                                                  " " +
                                                  data.userAppModal.lastName??"",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .display1,
                                                fontSize:
                                                ScreenUtil.getInstance().setSp(12),
                                                color: Color(0xFFF2F4F7),
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textScaleFactor: 1.0,
                                              textAlign: TextAlign.start,
                                            ),
                                            width: ScreenUtil.getInstance().setWidth(120)
                                        ),
                                        Container(
                                            child: Row(
                                              children: <Widget>[
                                                data.userAppModal.city == ''?
                                                Container() : Container(
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: Color(0xFFF2F4F7),
                                                    size: ScreenUtil.getInstance()
                                                        .setWidth(15),
                                                  ),
                                                  height: ScreenUtil.getInstance()
                                                      .setWidth(20),
                                                  width: ScreenUtil.getInstance()
                                                      .setWidth(20),
                                                ),
                                                Text(
                                                    data.userAppModal.city,
                                                    textScaleFactor: 1.0,
                                                    style: GoogleFonts.poppins(
                                                      textStyle: Theme.of(context)
                                                          .textTheme
                                                          .display1,
                                                      fontSize: ScreenUtil.getInstance()
                                                          .setSp(12),
                                                      color: Color(0xFFB3C2D8),
                                                      fontWeight: FontWeight.w300,
                                                    ))
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child:  ListView.builder(
                                  itemCount: widget.drawerItems.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: <Widget>[
                                        index == 0 ? Container() : Container(
                                          color: AppColors.colorWhiteLight,
                                          height: 1,
                                          width:
                                          MediaQuery.of(context).size.width,
                                        ),
                                        ListTile(
                                          trailing: new Icon(
                                            _selectedDrawerIndex == index
                                                ? Icons.keyboard_arrow_down
                                                : Icons.keyboard_arrow_right,
                                            color: Color(0xFFB3C2D8),
                                          ),
                                          title: new Text(
                                        index == 0 ? DemoLocalizations.of(context).trans('dashboard').toUpperCase() :
                                        index == 1 ? DemoLocalizations.of(context).trans('news') .toUpperCase():
                                            index == 2 ? DemoLocalizations.of(context).trans('challenges').toUpperCase() :
                                            index == 3 ? DemoLocalizations.of(context).trans('session').toUpperCase() :
                                            index == 4 ? DemoLocalizations.of(context).trans('acc').toUpperCase() :
                                        index == 5 ? DemoLocalizations.of(context).trans('settings').toUpperCase() :
                                        index == 6 ? DemoLocalizations.of(context).trans('faq').toUpperCase() :
                                        DemoLocalizations.of(context).trans('logout_drawer').toUpperCase()
                                                  .toUpperCase(),
                                        textScaleFactor: 1.0,
                                              style: GoogleFonts.roboto(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .display1,
                                                fontSize:
                                                ScreenUtil.getInstance()
                                                    .setSp(14),
                                                letterSpacing: 2,
                                                color: AppColors.colorWhite,
                                                fontWeight: FontWeight.w300,
                                              )),
                                          selected:
                                          index == _selectedDrawerIndex,
                                          onTap: () => _onSelectItem(index),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
            body: _getDrawerItemWidget(_selectedDrawerIndex,context),
          ));
        });
  }

  /*Top user image......*/
  Widget _userImage(_DrawerModel data) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            child: ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image:data.store.state.userAppModal.profileImage!= null ?
                        NetworkImage(data.store.state.userAppModal.profileImage) : AssetImage(
                          'asset/placeholder.png',
                        )),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DrawerModel {
  final Store<AppState> store;
  final UserAppModal userAppModal;

  _DrawerModel(this.store, this.userAppModal);

  factory _DrawerModel.create(Store<AppState> store, BuildContext context) {
    return _DrawerModel(store, store.state.userAppModal);
  }
}
