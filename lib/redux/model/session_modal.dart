import 'package:firebase_database/firebase_database.dart';

class SessionModal {
  String key;
  String sessionName;
  String activityType;
  String date;
  String distance;
  String startTime;
  String endTime;
  String userId;


  SessionModal(this.sessionName,this.activityType,this.date,this.distance,this.startTime,this.endTime, this.userId);


  SessionModal.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        sessionName = snapshot.value["sessionName"],
        activityType = snapshot.value["activityType"],
        date = snapshot.value["date"],
        distance = snapshot.value["distance"],
        startTime = snapshot.value["startTime"],
        endTime = snapshot.value["endTime"];

  toJson() {
    return {
      "userId": userId,
      "sessionName": sessionName,
      "activityType": activityType,
      "date": date,
      "distance": distance,
      "startTime": startTime,
      "endTime": endTime
    };
  }
}