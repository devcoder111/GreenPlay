import 'package:greenplayapp/redux/model/data_add_session.dart';

class AddSession {
  String sessionId;
  String createdOn;
  String updatedOn;
  String currentDay;
  String source;
  String userId;
  Data data;
  String key;
  String sessionName;
  String sessionYear;
  String delete;

  AddSession(
      {this.sessionId, this.createdOn, this.updatedOn, this.source, this.data});

  AddSession.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    createdOn = json['createdOn'];
    updatedOn = json['updatedOn'];
    currentDay = json['currentDay'];
    source = json['source'];
    userId = json['userId'];
    key = json['key'];
    sessionName = json['sessionName'];
    sessionYear = json['sessionYear'];
    delete = json['delete'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['createdOn'] = this.createdOn;
    data['updatedOn'] = this.updatedOn;
    data['updatedOn'] = this.updatedOn;
    data['currentDay'] = this.currentDay;
    data['userId'] = this.userId;
    data['sessionName'] = this.sessionName;
    data['sessionYear'] = this.sessionYear;
    data['delete'] = this.delete;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }if (this.key != null) {
      data['key'] = this.key;
    }
    return data;
  }
}



