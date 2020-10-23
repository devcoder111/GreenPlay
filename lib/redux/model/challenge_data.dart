import 'challenge_user_modal.dart';

class Data {
  String idChallenge;
  String challengeName;
  String startDate;
  String endDate;
  String scheduleType;
  String scheduleStart;
  String scheduleEnd;
  String description;
  String challengeType;
  String challengeDistance;
  String disciplineTime;
  String discipline;
  String idReward;
  String organisationOwner;
  String createdBy;
  String createdOn;
  String updatedOn;
  String isDeleted;
  int isAccepted;
  List<User> userData;

  Data(
      {this.idChallenge,
        this.challengeName,
        this.startDate,
        this.endDate,
        this.scheduleType,
        this.scheduleStart,
        this.scheduleEnd,
        this.description,
        this.challengeType,
        this.challengeDistance,
        this.disciplineTime,
        this.discipline,
        this.idReward,
        this.organisationOwner,
        this.createdBy,
        this.createdOn,
        this.updatedOn,
        this.isDeleted,
        this.isAccepted,
        this.userData});

  Data.fromJson(Map<String, dynamic> json) {
    idChallenge = json['idChallenge'];
    challengeName = json['ChallengeName'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
    scheduleType = json['ScheduleType'];
    scheduleStart = json['ScheduleStart'];
    scheduleEnd = json['ScheduleEnd'];
    description = json['Description'];
    challengeType = json['ChallengeType'];
    challengeDistance = json['ChallengeDistance'];
    disciplineTime = json['DisciplineTime'];
    discipline = json['Discipline'];
    idReward = json['IdReward'];
    organisationOwner = json['OrganisationOwner'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedOn = json['UpdatedOn'];
    isDeleted = json['IsDeleted'];
    isAccepted = json['isAccepted'] ?? 2;
    if (json['userData'] != null) {
      userData = new List<User>();
      json['user'].forEach((v) {
        userData.add(new User.fromJson(v));
      });
    }else{
      userData = new List();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idChallenge'] = this.idChallenge;
    data['ChallengeName'] = this.challengeName;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    data['ScheduleType'] = this.scheduleType;
    data['ScheduleStart'] = this.scheduleStart;
    data['ScheduleEnd'] = this.scheduleEnd;
    data['Description'] = this.description;
    data['ChallengeType'] = this.challengeType;
    data['ChallengeDistance'] = this.challengeDistance;
    data['DisciplineTime'] = this.disciplineTime;
    data['Discipline'] = this.discipline;
    data['IdReward'] = this.idReward;
    data['OrganisationOwner'] = this.organisationOwner;
    data['CreatedBy'] = this.createdBy;
    data['CreatedOn'] = this.createdOn;
    data['UpdatedOn'] = this.updatedOn;
    data['IsDeleted'] = this.isDeleted;
    data['isAccepted'] = this.isAccepted;
    if (this.userData != null) {
      data['userData'] = this.userData.map((v) => v.toJson()).toList();
    }
    return data;
  }
}