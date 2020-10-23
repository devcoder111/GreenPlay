import 'package:firebase_database/firebase_database.dart';

class AddUserModel {
  String key;
  String firstName;
  String lastName;
  String email;
  String password;
  String gender;
  String postalCode;
  String userId;
  String sessionID;
  bool isVerified;
  String createdOn;
  String updatedOn;
  String deviceType;
  String deviceToken;
  String transportMode;
  String address;
  String profileImage;
  String city;
  String country;
  String organisationName;
  String employeeCount;
  String region;
  String dob;
  String motorisedTransport;
  String weight;
  String isSession;
  String deviceModel;
  String branchName;
  String lastConnection;

  AddUserModel(this.firstName,this.lastName,this.email,this.password,this.gender,this.postalCode, this.userId, this.sessionID
      , this.isVerified, this.createdOn, this.updatedOn, this.deviceType, this.deviceToken, this.transportMode, this.address,
      this.profileImage,this.city,this.country,this.organisationName,this.employeeCount,this.region,this.dob,
      this.motorisedTransport, this.weight, this.isSession, this.deviceModel,this.branchName, this.lastConnection);


  AddUserModel.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        firstName = snapshot.value["firstName"],
        email = snapshot.value["email"],
        password = snapshot.value["password"],
        gender = snapshot.value["gender"],
        postalCode = snapshot.value["postalCode"],
        sessionID = snapshot.value["sessionID"],
        lastName = snapshot.value["lastName"],
        createdOn = snapshot.value["createdOn"],
        updatedOn = snapshot.value["updatedOn"],
        deviceType = snapshot.value["deviceType"],
        deviceToken = snapshot.value["deviceToken"],
        transportMode = snapshot.value["transportMode"],
        address = snapshot.value["address"],
        profileImage = snapshot.value["profileImage"],
        city = snapshot.value["city"],
        country = snapshot.value["country"],
        organisationName = snapshot.value["organisationName"],
        employeeCount = snapshot.value["employeeCount"],
        isVerified = snapshot.value["isVerified"],
        region = snapshot.value["region"],
        dob = snapshot.value["dob"],
        motorisedTransport = snapshot.value["motorisedTransport"],
        weight = snapshot.value["weight"],
        isSession = snapshot.value["isSession"],
        deviceModel = snapshot.value["deviceModel"],
        branchName = snapshot.value["branchName"],
        lastConnection = snapshot.value["lastConnection"];

  toJson() {
    return {
      "userId": userId,
      "firstName": firstName,
      "email": email,
      "password": password,
      "gender": gender,
      "postalCode": postalCode,
      "lastName": lastName,
      "sessionID": sessionID,
      "lastName": lastName,
      "createdOn": createdOn,
      "updatedOn": updatedOn,
      "isVerified": isVerified,
      "deviceType": deviceType,
      "transportMode": transportMode,
      "deviceToken": deviceToken,
      "address": address,
      "profileImage": profileImage,
      "city": city,
      "country": country,
      "organisationName": organisationName,
      "employeeCount": employeeCount,
      "region": region,
      "dob": dob,
      "motorisedTransport": motorisedTransport,
      "weight": weight,
      "isSession": isSession,
      "deviceModel": deviceModel,
      "branchName": branchName,
      "lastConnection": lastConnection,
    };
  }
}