import 'data_branch.dart';

class BranchOrganisationResponse {
  int code;
  String message;
  List<DataBranch> data;
  bool success;

  BranchOrganisationResponse({this.code, this.message, this.data, this.success});

  BranchOrganisationResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<DataBranch>();
      json['data'].forEach((v) {
        data.add(new DataBranch.fromJson(v));
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

