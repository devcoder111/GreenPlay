class User {
  String userId;
  String userName;
  String distance;

  User(
      {this.userId,
        this.userName,this.distance});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] ?? null;
    userName = json['userName'] ?? null;
    distance = json['distance'] ?? null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['distance'] = this.distance;
    return data;
  }
}