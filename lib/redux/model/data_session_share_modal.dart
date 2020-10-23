class SessionViewModal{
  double _greenhouse;
  int _calories;
  int _weightForCalorie;
  String _time;
  double _distanceDisplay;
  double _speedDisplay;
  String _speedDisplayString;

  double get greenhouse => _greenhouse;

  set greenhouse(double value) {
    _greenhouse = value;
  }

  int get calories => _calories;

  String get speedDisplayString => _speedDisplayString;

  set speedDisplayString(String value) {
    _speedDisplayString = value;
  }

  double get speedDisplay => _speedDisplay;

  set speedDisplay(double value) {
    _speedDisplay = value;
  }

  double get distanceDisplay => _distanceDisplay;

  set distanceDisplay(double value) {
    _distanceDisplay = value;
  }

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  int get weightForCalorie => _weightForCalorie;

  set weightForCalorie(int value) {
    _weightForCalorie = value;
  }

  set calories(int value) {
    _calories = value;
  }
}