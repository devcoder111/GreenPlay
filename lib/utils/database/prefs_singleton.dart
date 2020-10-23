import 'package:shared_preferences/shared_preferences.dart';

class PrefsSingleton {
  factory PrefsSingleton() {
    return _singleton;
  }

  PrefsSingleton._internal();

  static final PrefsSingleton _singleton = PrefsSingleton._internal();

  static SharedPreferences prefs;
}


class PreferenceNames {
  static const userId = "user_id";
  static const token = "token";
  static const firstName = "firstName";
  static const lastName = "lastName";
  static const email = "email";
  static const gender = "gender";
  static const address = "address";
  static const city = "city";
  static const profileImage = "image";
  static const transportType = "transport";
  static const transportTypeUpdated = "transportUpdated";
  static const distanceNow = "distance";
  static const timePrevious = "time";
  static const timeInit = "timeInit";
  static const sessionId = "user_session";
  static const lastLat = "lastLat";
  static const lastLong = "lastLong";
  static const language = "language";
  static const isSession = "session";
  static const weight = "weight";
  static const orgName = "orgName";
  static const id = "id";
}
