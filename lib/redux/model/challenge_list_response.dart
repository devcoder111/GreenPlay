import 'package:greenplayapp/redux/model/challenge_user_modal.dart';

import 'challenge_data.dart';

class ChallengeResponse {
  int code;
  String message;
  List<Data> data;
  bool success;

  ChallengeResponse({this.code, this.message, this.data, this.success});

  ChallengeResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['success'] = this.success;
    return data;
  }
}



