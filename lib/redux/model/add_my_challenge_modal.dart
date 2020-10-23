import 'package:firebase_database/firebase_database.dart';

import 'add_challenge_data_modal.dart';

class MyChallengeAddModal {
  String key;
  String userId;
  String userFirstName;
  String userLastName;
  List<ChallengeData> challenges;

  MyChallengeAddModal(this.userId,this.userFirstName,this.userLastName,this.challenges);


  MyChallengeAddModal.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["isMyActivity"],
        userFirstName = snapshot.value["userFirstName"],
        userLastName = snapshot.value["userLastName"],
        challenges = snapshot.value["challenges"];


  toJson() {
    return {
      "userId": userId,
      "userFirstName": userFirstName,
      "userLastName": userLastName,
      "challenges": this.challenges.map((v) => v.toJson()).toList()
    };
  }
}