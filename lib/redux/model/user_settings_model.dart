import 'package:firebase_database/firebase_database.dart';

class UserSettingsModal {
  String key;
  bool isMyActivity;
  bool isAllowNotification;
  bool isPrecision;
  String createdOn;
  String updatedOn;
  String userId;

  UserSettingsModal(this.isMyActivity,this.isAllowNotification,this.isPrecision,this.createdOn,this.updatedOn,this.userId);


  UserSettingsModal.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        isMyActivity = snapshot.value["isMyActivity"],
        isAllowNotification = snapshot.value["isAllowNotification"],
        isPrecision = snapshot.value["isPrecision"],
        createdOn = snapshot.value["createdOn"],
        updatedOn = snapshot.value["updatedOn"],
        userId = snapshot.value["userId"];


  toJson() {
    return {
      "userId": userId,
      "isMyActivity": isMyActivity,
      "isAllowNotification": isAllowNotification,
      "isPrecision": isPrecision,
      "createdOn": createdOn,
      "updatedOn": updatedOn
    };
  }
}