class DataBranch {
  int branchNo;
  int organisationNo;
  String branchName;
  int regionNo;
  int isDeleted;
  String regionName;
  int cGDno;

  DataBranch(
      {this.branchNo,
        this.organisationNo,
        this.branchName,
        this.regionNo,
        this.isDeleted,
        this.regionName,
        this.cGDno});

  DataBranch.fromJson(Map<String, dynamic> json) {
    branchNo = json['branchNo'];
    organisationNo = json['organisationNo'];
    branchName = json['branchName'];
    regionNo = json['regionNo'];
    isDeleted = json['isDeleted'];
    regionName = json['regionName'];
    cGDno = json['CGDno'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['branchNo'] = this.branchNo;
    data['organisationNo'] = this.organisationNo;
    data['branchName'] = this.branchName;
    data['regionNo'] = this.regionNo;
    data['isDeleted'] = this.isDeleted;
    data['regionName'] = this.regionName;
    data['CGDno'] = this.cGDno;
    return data;
  }
}