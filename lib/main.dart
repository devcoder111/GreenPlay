import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/middleware/middleware.dart';
import 'package:greenplayapp/redux/model/add_session_modal.dart';
import 'package:greenplayapp/redux/model/data_add_session.dart';
import 'package:greenplayapp/redux/model/session_data.dart';
import 'package:greenplayapp/redux/reducer/app_reducer.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/config/env.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'application.dart';
import 'redux/model/challenge_list_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: AppColors.colorBlue, // status bar color
    statusBarIconBrightness: Brightness.light,
    // statusBarBrightness: Brightness.dark
  ));

  PrefsSingleton.prefs = await SharedPreferences.getInstance();

  //add redux store provider function at app init
  final store = Store<AppState>(
    appReducer,
    initialState: AppState(
        accountLoader: false,
        challengeLoaderAll: false,
        listParticipant: new List(),
        challengeListResponse: new ChallengeResponse(),
        challengeDetailLoader: false,
        loaderDashboard: false,
        loginLoader: false,
        dashboardPercent: 0.0,
        dashboardCalories: '0',
        loaderLogin: false,
        loaderChallengeMy: false,
        listChallengeActive: new List(),
        challengeListNext: new List(),
        challengeListPast: new List(),
        organisationResponse: null,
        branchOrganisationResponse: null,
        isBranch: false), //initialize value if you want!!
    middleware: createAppMiddleware(),
    //custom middleware function initialized
  );

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(StoreProvider(store: store, child: Application(store)));
  });
//  bg.BackgroundGeolocation.changePace(true);
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
//    disableElasticity: true,
  )).then((bg.State state) {
    if (!state.enabled) {
      if (PrefsSingleton.prefs.getString(PreferenceNames.token) != null) {
        bg.BackgroundGeolocation.start();
        bg.BackgroundGeolocation.changePace(true);
      } else {
//        bg.BackgroundGeolocation.stop();
      }
    }
  });

  if (PrefsSingleton.prefs.getString(PreferenceNames.token) != null) {
    bg.BackgroundGeolocation.registerHeadlessTask(
        backgroundGeolocationHeadlessTask);

    /// Register BackgroundFetch headless-task.
//    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  } else {
//    BackgroundGeolocation.stop();
  }

  bg.BackgroundGeolocation.onLocation((bg.Location location) {
    print('[locationyy] - $location');
    var hh = GetDeviceType.getDeviceType();
    print("hh:... $hh");
    if (GetDeviceType.getDeviceType() == "ios") {
      String session =
          PrefsSingleton.prefs.getString(PreferenceNames.isSession);
      if (session == null) {
        session = "Automatic";
      }

      if (PrefsSingleton.prefs.getString(PreferenceNames.token) != null &&
          session == "Automatic") {
        if (location.activity.type.toLowerCase() != 'still') {
          _updateDataBase(location, PrefsSingleton.prefs);
        }
//        _updateDataBase(location, PrefsSingleton.prefs);
      }
    }
  });
  bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
    print('[motionchange] - $location');
    if (PrefsSingleton.prefs.getString(PreferenceNames.token) != null) {
      if (location.activity.type.toLowerCase() != 'still') {
//        _updateDataBase(location, PrefsSingleton.prefs);
      }
    }
  });
}

void _sendCurrentTabToAnalytics(String eventName, Map<String, int> map) {}

/// Receive events from BackgroundFetch in Headless state.
void backgroundFetchHeadlessTask(String taskId) async {
  // Get current-position from BackgroundGeolocation in headless mode.
  //bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
  print("[BackgroundFetch] HeadlessTask: $taskId");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int count = 0;
  if (prefs.get("fetch-count") != null) {
    count = prefs.getInt("fetch-count");
  }
  prefs.setInt("fetch-count", ++count);
  print('[BackgroundFetch] count: $count');

  BackgroundFetch.finish(taskId);
}

final FirebaseDatabase _database = FirebaseDatabase.instance;

Future<void> _updateDataBase(
    bg.Location location, SharedPreferences _prefs) async {
  SessionData _sessionData = new SessionData();
  double distanceInMeters = 0.0;
  if (_prefs.getString(PreferenceNames.timeInit) == null) {
    _prefs.setString(
        PreferenceNames.timeInit,
        DateTime.now().year.toString() +
            "-" +
            DateTime.now().month.toString() +
            "-" +
            DateTime.now().day.toString() +
            " " +
            DateTime.now().hour.toString() +
            ":" +
            DateTime.now().minute.toString());
  }
  if (_prefs.getDouble(PreferenceNames.lastLat) == null) {
    _prefs.setDouble(PreferenceNames.distanceNow, 1.0);
    _prefs.setDouble(PreferenceNames.lastLat, location.coords.latitude);
    _prefs.setDouble(PreferenceNames.lastLong, location.coords.longitude);
    _sessionData.distance = '300.0';
    distanceInMeters = 300.0;
  } else {
    distanceInMeters = await Geolocator().distanceBetween(
        location.coords.latitude,
        location.coords.longitude,
        _prefs.getDouble(PreferenceNames.lastLat),
        _prefs.getDouble(PreferenceNames.lastLong));
    _prefs.setDouble(PreferenceNames.lastLat, location.coords.latitude);
    _prefs.setDouble(PreferenceNames.lastLong, location.coords.longitude);

    if (distanceInMeters < 1.0) {
      return;
    }
    _sessionData.distance = distanceInMeters.toString();
    _prefs.setDouble(PreferenceNames.distanceNow, distanceInMeters);
  }
  if (_prefs.getString(PreferenceNames.sessionId) == null) {
    _prefs.setString(PreferenceNames.sessionId,
        DateTime.now().millisecondsSinceEpoch.toString());
  }

  _sessionData.startTime = _prefs.getString(PreferenceNames.timeInit);
  String activity = location.activity.type.toString().toLowerCase();
  if (location.activity.type.toString().toLowerCase() == "in_vehicle") {
    activity = "In vehicle";
  } else if (location.activity.type.toString().toLowerCase() == "on_bicycle") {
    activity = "Bike";
  } else if (location.activity.type.toString().toLowerCase() == "on_foot") {
    activity = "Walking";
  } else if (location.activity.type.toString().toLowerCase() == "running") {
    activity = "Running";
  } else if (location.activity.type.toString().toLowerCase() == "unknown") {
    activity = "Unknown";
  } else if (location.activity.type.toString().toLowerCase() == "walking") {
    activity = "Walking";
  }
  _sessionData.activityType = activity;
  _sessionData.speed = location.coords.speed.toString();
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

  if (_prefs.getString(PreferenceNames.timeInit) == null ||
      _prefs.getString(PreferenceNames.timeInit) == "") {
    _prefs.setString(
        PreferenceNames.timeInit,
        DateTime.now().year.toString() +
            "-" +
            DateTime.now().month.toString() +
            "-" +
            DateTime.now().day.toString() +
            " " +
            DateTime.now().hour.toString() +
            ":" +
            DateTime.now().minute.toString());
  }
  print(_prefs.getString(PreferenceNames.timeInit));
  final _prevDate = DateTime(
      int.parse(_prefs
          .getString(PreferenceNames.timeInit)
          .split(' ')[0]
          .split('-')[0]),
      int.parse(_prefs
          .getString(PreferenceNames.timeInit)
          .split(' ')[0]
          .split('-')[1]),
      int.parse(_prefs
          .getString(PreferenceNames.timeInit)
          .split(' ')[0]
          .split('-')[2]),
      int.parse(_prefs
          .getString(PreferenceNames.timeInit)
          .split(' ')[1]
          .split(':')[0]),
      int.parse(_prefs
          .getString(PreferenceNames.timeInit)
          .split(' ')[1]
          .split(':')[1]));
  final differenceTime = DateTime.now().difference(_prevDate).inDays;

  if (differenceTime < 1) {
    if (_prefs.getString(PreferenceNames.transportType) ==
        location.activity.type) {
      print('aaaaaaaaaa1: ');
      _database
          .reference()
          .child(DataBaseConstants.sessionData)
          .orderByChild("sessionId")
          .equalTo(_prefs.getString(PreferenceNames.sessionId))
          .once()
          .then((snapshot) async {
        if (snapshot.value != null) {
          _database
              .reference()
              .child(DataBaseConstants.sessionData)
              .orderByChild("sessionId")
              .equalTo(_prefs.getString(PreferenceNames.sessionId))
              .once()
              .then((snapshot) async {
            if (snapshot.value != null) {
              Map<dynamic, dynamic> map = snapshot.value;
              _session.createdOn = map.values.toList()[0]["createdOn"];
              var _key = map.keys.toList()[0];
              if (map.values.toList()[0]["data"] != null) {
                var value = double.parse(map.values
                    .toList()[0]["data"]["SessionData"]["distance"]) +
                    distanceInMeters;
                var speedValue = double.parse(map.values
                    .toList()[0]["data"]["SessionData"]["Speed"]) +
                    location.coords.speed;
                double avgSpeed = speedValue / 2;
                _sessionData.distance = value.toString();
                _sessionData.speed = avgSpeed.toString();
              }

              String updatedOn = map.values.toList()[0]["updatedOn"];
              final _updatedDate = DateTime(
                  int.parse(updatedOn.split(' ')[0].split('-')[0]),
                  int.parse(updatedOn.split(' ')[0].split('-')[1]),
                  int.parse(updatedOn.split(' ')[0].split('-')[2]),
                  int.parse(updatedOn.split(' ')[1].split(':')[0]),
                  int.parse(updatedOn.split(' ')[1].split(':')[1]));
              final differenceTime =
                  DateTime.now().difference(_updatedDate).inMinutes;
              if (differenceTime > 20) {
                _prefs.setString(PreferenceNames.transportTypeUpdated,
                    location.activity.type);
                _prefs.setString(
                    PreferenceNames.transportType, location.activity.type);
                _prefs.setDouble(PreferenceNames.distanceNow,
                    _prefs.getDouble(PreferenceNames.distanceNow));
                _prefs.setString(
                    PreferenceNames.sessionId,
                    DateTime.now().millisecondsSinceEpoch.toString() +
                        _prefs.get(PreferenceNames.token));
                _prefs.setString(
                    PreferenceNames.timePrevious,
                    DateTime.now().year.toString() +
                        "-" +
                        DateTime.now().month.toString() +
                        "-" +
                        DateTime.now().day.toString() +
                        " " +
                        DateTime.now().hour.toString() +
                        ":" +
                        DateTime.now().minute.toString());
                _prefs.setString(
                    PreferenceNames.timeInit,
                    DateTime.now().year.toString() +
                        "-" +
                        DateTime.now().month.toString() +
                        "-" +
                        DateTime.now().day.toString() +
                        " " +
                        DateTime.now().hour.toString() +
                        ":" +
                        DateTime.now().minute.toString());

                _prefs.setDouble(
                    PreferenceNames.lastLat, location.coords.latitude);
                _prefs.setDouble(
                    PreferenceNames.lastLong, location.coords.longitude);
                _sessionData.distance = "300";

                _sessionData.startTime =
                    _prefs.getString(PreferenceNames.timeInit);
                _session.sessionId =
                    _prefs.getString(PreferenceNames.sessionId);
                _database
                    .reference()
                    .child(DataBaseConstants.sessionData)
                    .push()
                    .set(_session.toJson());
                print("greenplay 0");
                final Map<String, int> someMap = {
                  "a": 0,
                  "b": 0,
                };
                _sendCurrentTabToAnalytics("init", someMap);
              } else {
                _database
                    .reference()
                    .child(DataBaseConstants.sessionData)
                    .child(_key)
                    .update(_session.toJson());
                print("greenplay 1");
                final Map<String, int> someMap = {
                  "a": 1,
                  "b": 1,
                };
//                _sendCurrentTabToAnalytics("init", someMap);
              }
            }
          });
        } else {
          _prefs.setString(
              PreferenceNames.transportTypeUpdated, location.activity.type);
          _prefs.setString(
              PreferenceNames.transportType, location.activity.type);
          _prefs.setDouble(PreferenceNames.distanceNow,
              _prefs.getDouble(PreferenceNames.distanceNow));
          _prefs.setString(
              PreferenceNames.sessionId,
              DateTime.now().millisecondsSinceEpoch.toString() +
                  _prefs.get(PreferenceNames.token));
          _prefs.setString(
              PreferenceNames.timePrevious,
              DateTime.now().year.toString() +
                  "-" +
                  DateTime.now().month.toString() +
                  "-" +
                  DateTime.now().day.toString() +
                  " " +
                  DateTime.now().hour.toString() +
                  ":" +
                  DateTime.now().minute.toString());
          _prefs.setString(
              PreferenceNames.timeInit,
              DateTime.now().year.toString() +
                  "-" +
                  DateTime.now().month.toString() +
                  "-" +
                  DateTime.now().day.toString() +
                  " " +
                  DateTime.now().hour.toString() +
                  ":" +
                  DateTime.now().minute.toString());

          _prefs.setDouble(PreferenceNames.lastLat, location.coords.latitude);
          _prefs.setDouble(PreferenceNames.lastLong, location.coords.longitude);
          _sessionData.distance = "300";

          _sessionData.startTime = _prefs.getString(PreferenceNames.timeInit);
          _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
          _database
              .reference()
              .child(DataBaseConstants.sessionData)
              .push()
              .set(_session.toJson());
          print("greenplay 2");
          final Map<String, int> someMap = {
            "a": 3,
            "b": 3,
          };
          _sendCurrentTabToAnalytics("init", someMap);
        }
      });
    } else {
      print('aaaaaaaa2');
      _prefs.setString(
          PreferenceNames.transportTypeUpdated, location.activity.type);
      _prefs.setString(PreferenceNames.transportType, location.activity.type);
      _prefs.setDouble(PreferenceNames.distanceNow, 300.0);
      _prefs.setString(
          PreferenceNames.sessionId,
          DateTime.now().millisecondsSinceEpoch.toString() +
              _prefs.get(PreferenceNames.token));
      _prefs.setString(
          PreferenceNames.timePrevious,
          DateTime.now().year.toString() +
              "-" +
              DateTime.now().month.toString() +
              "-" +
              DateTime.now().day.toString() +
              " " +
              DateTime.now().hour.toString() +
              ":" +
              DateTime.now().minute.toString());
      _prefs.setString(
          PreferenceNames.timeInit,
          DateTime.now().year.toString() +
              "-" +
              DateTime.now().month.toString() +
              "-" +
              DateTime.now().day.toString() +
              " " +
              DateTime.now().hour.toString() +
              ":" +
              DateTime.now().minute.toString());

      _sessionData.startTime = _prefs.getString(PreferenceNames.timeInit);
      _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
      _prefs.setDouble(PreferenceNames.lastLat, location.coords.latitude);
      _prefs.setDouble(PreferenceNames.lastLong, location.coords.longitude);
      _sessionData.distance = "300";
      _database
          .reference()
          .child(DataBaseConstants.sessionData)
          .push()
          .set(_session.toJson());
      print("greenplay 3");
    }
  } else {
    _prefs.setString(
        PreferenceNames.transportTypeUpdated, location.activity.type);
    _prefs.setString(PreferenceNames.transportType, location.activity.type);
    _prefs.setDouble(PreferenceNames.distanceNow, 300.0);
    _prefs.setString(
        PreferenceNames.sessionId,
        DateTime.now().millisecondsSinceEpoch.toString() +
            _prefs.get(PreferenceNames.token));
    _prefs.setString(
        PreferenceNames.timePrevious,
        DateTime.now().year.toString() +
            "-" +
            DateTime.now().month.toString() +
            "-" +
            DateTime.now().day.toString() +
            " " +
            DateTime.now().hour.toString() +
            ":" +
            DateTime.now().minute.toString());
    _prefs.setString(
        PreferenceNames.timeInit,
        DateTime.now().year.toString() +
            "-" +
            DateTime.now().month.toString() +
            "-" +
            DateTime.now().day.toString() +
            " " +
            DateTime.now().hour.toString() +
            ":" +
            DateTime.now().minute.toString());

    _sessionData.startTime = _prefs.getString(PreferenceNames.timeInit);
    _session.sessionId = _prefs.getString(PreferenceNames.sessionId);
    _prefs.setDouble(PreferenceNames.lastLat, location.coords.latitude);
    _prefs.setDouble(PreferenceNames.lastLong, location.coords.longitude);
    _sessionData.distance = "300";
    _database
        .reference()
        .child(DataBaseConstants.sessionData)
        .push()
        .set(_session.toJson());
    print("greenplay 4");
  }
}

/// Receive events from BackgroundGeolocation in Headless state.
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  print('📬 --> $headlessEvent');
  var vv = headlessEvent.name;
  print('📬 --> $vv');
  PrefsSingleton.prefs = await SharedPreferences.getInstance();

  switch (headlessEvent.name) {
    case bg.Event.TERMINATE:
      try {
        //bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
        print('[getCurrentPosition] Headless: $headlessEvent');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      break;
    case bg.Event.HEARTBEAT:
      /* DISABLED getCurrentPosition on heartbeat
      try {
        bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
        print('[getCurrentPosition] Headless: $location');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      */
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      print(location);
      String session =
          PrefsSingleton.prefs.getString(PreferenceNames.isSession);
      if (session == null) {
        session = "Automatic";
      }

      if (PrefsSingleton.prefs.getString(PreferenceNames.token) != null &&
          session == "Automatic") {
        if (location.activity.type.toLowerCase() != 'still') {
          _updateDataBase(location, PrefsSingleton.prefs);
        }
//        _updateDataBase(location, PrefsSingleton.prefs);
      }

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        // I am connected to a mobile network.
//        print("aaaaaaaaaaaaaa: mobile");
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
//        print("aaaaaaaaaaaaaa: wi fi");
      }
      accelerometerEvents.listen((AccelerometerEvent event) {
        var kk = event.x;
//        print("aaaaaaaaa: $kk");
      });

      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print(location);
      print('aaaa111');
      if (PrefsSingleton.prefs.getString(PreferenceNames.token) != null) {
        if (location.activity.type.toLowerCase() != 'still') {
//          _updateDataBase(location, PrefsSingleton.prefs);
        }
      }
      break;
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      print(geofenceEvent);
      break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print(state);
      break;
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print(event);
      bg.ActivityChangeEvent location = headlessEvent.event;
      print("act_change: $location");
      break;
    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print(response);
      break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.AUTHORIZATION:
      bg.AuthorizationEvent event = headlessEvent.event;
      print(event);
      bg.BackgroundGeolocation.setConfig(
          bg.Config(url: "${ENV.TRACKER_HOST}/api/locations"));
      break;
  }
}
