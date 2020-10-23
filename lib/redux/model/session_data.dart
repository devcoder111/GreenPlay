class SessionData {
  String startTime;
  String endTime;
  String distance;
  String activityType;
  String speed;
  String sessionType;

  SessionData(
      {this.startTime,
        this.endTime,
        this.distance,
        this.activityType,
        this.speed,
      this.sessionType});

  SessionData.fromJson(Map<String, dynamic> json) {
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    distance = json['distance'];
    activityType = json['activityType'] ?? "";
    speed = json['Speed'];
    sessionType = json['sessionType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StartTime'] = this.startTime;
    data['EndTime'] = this.endTime;
    data['distance'] = this.distance;
    data['activityType'] = this.activityType;
    data['Speed'] = this.speed;
    data['sessionType'] = this.sessionType;
    return data;
  }
}