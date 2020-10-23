class DataOrg {
  int organizationNo;
  String organization;


  DataOrg(
      {this.organizationNo,
        this.organization,
      });

  DataOrg.fromJson(Map<String, dynamic> json) {
    organizationNo = json['organisationNo'] ;
    organization = json['organization'] !=null ? json['organization'] :
    json['organization '] !=null ? json['organization '] :
    json[' organization'] !=null ? json[' organization']:
    json['organisation'] !=null ? json['organisation'] :json[' organization '] ;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organisationNo'] = this.organizationNo;
    data['organisation'] = this.organization;

    return data;
  }
}