import 'package:greenplayapp/redux/model/session_data.dart';

class Data {
  String movementDateTime;
  String userId;
  SessionData sessionData;

  Data({this.movementDateTime, this.userId, this.sessionData});

  Data.fromJson(Map<String, dynamic> json) {
    movementDateTime = json['movementDateTime'];
    userId = json['userId'];
    sessionData = json['SessionData'] != null
        ? new SessionData.fromJson(json['SessionData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['movementDateTime'] = this.movementDateTime;
    data['userId'] = this.userId;
    if (this.sessionData != null) {
      data['SessionData'] = this.sessionData.toJson();
    }
    return data;
  }
}