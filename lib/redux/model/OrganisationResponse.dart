

import 'package:greenplayapp/redux/model/data_organisation.dart';

class OrganisationResponse {
  int code;
  String message;
  List<DataOrg> data;
  bool success;

  OrganisationResponse({this.code, this.message, this.data, this.success});

  OrganisationResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<DataOrg>();
      json['data'].forEach((v) {
        data.add(new DataOrg.fromJson(v));
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

