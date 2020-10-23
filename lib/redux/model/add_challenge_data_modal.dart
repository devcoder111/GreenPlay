import 'dart:math';

class ChallengeData {
  String challengeId;
  String challengeName;
  String challengeStartDate;
  String challengeEndDate;
  String challengeCreatedBy;
  String challengeDescription;
  String challengeDistance;
  String scheduleType;
  String withdraw;


  ChallengeData(
      {this.challengeId,
        this.challengeName,this.challengeStartDate,this.challengeEndDate,this.challengeCreatedBy,this.challengeDescription
        ,this.challengeDistance,this.scheduleType,this.withdraw});

  ChallengeData.fromJson(Map<String, dynamic> json) {
    challengeId = json['challengeId'] ?? null;
    challengeName = json['challengeName'] ?? null;
    challengeStartDate = json['StartDate'] ?? null;
    challengeEndDate = json['EndDate'] ?? null;
    challengeCreatedBy = json['createdBy'] ?? null;
    challengeDescription = json['Description'] ?? null;
    challengeDistance = json['ChallengeDistance'] ?? null;
    scheduleType = json['ScheduleType'] ?? null;
    withdraw = json['withdraw'] ?? null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['challengeId'] = this.challengeId;
    data['challengeName'] = this.challengeName;
    data['StartDate'] = this.challengeStartDate;
    data['EndDate'] = this.challengeEndDate;
    data['createdBy'] = this.challengeCreatedBy;
    data['Description'] = this.challengeDescription;
    data['ChallengeDistance'] = this.challengeDistance;
    data['ScheduleType'] = this.scheduleType;
    data['withdraw'] = this.withdraw;
    return data;
  }
}