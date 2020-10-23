

import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/OrganisationAction.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/account_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/challenge_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/dashboard_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/login_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/session_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/BranchOrganisationResponse.dart';
import 'package:greenplayapp/redux/model/OrganisationResponse.dart';
import 'package:greenplayapp/redux/model/add_challenge_data_modal.dart';
import 'package:greenplayapp/redux/model/add_session_modal.dart';
import 'package:greenplayapp/redux/model/challenge_data.dart';
import 'package:greenplayapp/redux/model/challenge_list_response.dart';
import 'package:greenplayapp/redux/model/data_add_session.dart';
import 'package:greenplayapp/redux/model/gmail_login_model.dart';
import 'package:greenplayapp/redux/model/data_add_session.dart' as prefix1;
import 'package:greenplayapp/redux/model/challenge_data.dart' as prefixchallenge;
import 'package:greenplayapp/redux/model/session_data.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:redux/redux.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


enum Environment { DEV, PROD }

class ApiProvider {
  //Live
  String baseUrl = "https://defisansautosolo.greenplay.social/api/";
  String version = "v1";
  String organisationName = "organisations/name";
  String branchOrganisationName = "organisation/branch/";

  static final ApiProvider _apiProvider = ApiProvider._internal();
  static final Environment _setEnv = Environment.DEV;

  ApiProvider._internal() {
    // initialization logic here

  }

  factory ApiProvider() {
    return _apiProvider;
  }

  Future<ChallengeResponse> getChallengeList(
      Store<AppState> store, ChallengeApiAction action) async {

    ChallengeResponse _response = new ChallengeResponse();
    _response.data = new List();

    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(DataBaseConstants.allChallenge)
        .once();
    Map notificationMap = snapshot.value;
    if (notificationMap != null) {
      var chatList = snapshot.value; //-M5e8eLYYEPAsbYHTpcl
      Map<dynamic, dynamic> chatListMap = chatList;
      for (int i = 0; i < chatListMap.values.toList()[0].length; i++) {
        Map<dynamic, dynamic> v22 = chatListMap.values.toList()[0];
        var element =
            chatListMap[chatListMap.keys.elementAt(0)][v22.keys.elementAt(i)];
        prefixchallenge.Data _modal = new prefixchallenge.Data();
        _modal.idChallenge = element['idChallenge'];
        _modal.challengeName = element['ChallengeName'] ?? '-';
        _modal.createdBy = element['createdBy'] ?? '-';
        _modal.description = element['Description'] ?? '-';
        _modal.challengeType = element['ChallengeType'] ?? '';
        _modal.challengeDistance = element['ChallengeDistance'] ?? '0';
        _modal.scheduleType = element['ScheduleType'] ?? '-';
        String startDate = element['StartDate'] ?? element['ScheduleStart'];
        if(startDate != null){
          if(startDate.split('-')[1].length == 1){
            startDate = startDate.split('-')[0] + '-0' + startDate.split('-')[1] + '-' + startDate.split('-')[2];
          }if(startDate.split('-')[2].length == 1){
            startDate = startDate.split('-')[0] + '-' + startDate.split('-')[1] + '-0' + startDate.split('-')[2];
          }
        }else{
          String month =  DateTime.now().month.toString().length == 1 ?  '0'+DateTime.now().month.toString() :  DateTime.now().month.toString();
          String day =  DateTime.now().day.toString().length == 1 ?  '0'+DateTime.now().day.toString() :  DateTime.now().day.toString();
          startDate = DateTime.now().year.toString() +
              '-' +
              month +
              '-' +
              day;
        }

        String endDate = element['EndDate'];
        if(endDate != null){
          if(endDate.split('-')[1].length == 1){
            endDate = endDate.split('-')[0] + '-0' + endDate.split('-')[1] + '-' + endDate.split('-')[2];
          }if(endDate.split('-')[2].length == 1){
            endDate = endDate.split('-')[0] + '-' + endDate.split('-')[1] + '-0' + endDate.split('-')[2];
          }
        }else{
          String month =  DateTime.now().month.toString().length == 1 ?  '0'+DateTime.now().month.toString() :  DateTime.now().month.toString();
          String day =  DateTime.now().day.toString().length == 1 ?  '0'+DateTime.now().day.toString() :  DateTime.now().day.toString();
          endDate = DateTime.now().year.toString() +
              '-' +
              month +
              '-' +
              day;
        }
        _modal.endDate = endDate;
        _modal.startDate = startDate;

//        if(element['userData'] != null) {
//          List<dynamic> userData = element["userData"];
//          List<User> _us = new List();
//          userData.forEach((user) {
//            var userName = user['userName'];
//            var userId = user['userId'];
//            User _userModalDetail = new User();
//            _userModalDetail.userId = userId;
//            _userModalDetail.userName = userName;
//
//            _us.add(_userModalDetail);
//          });
//          _modal.userData.addAll(_us);
//        }

        _response.data.add(_modal);
      }
      store.dispatch(ChallengeLoaderAction(false));
      store.dispatch(ChallengeResponseAction(_response));
    } else {
      store.dispatch(ChallengeLoaderAction(false));
      store.dispatch(ChallengeResponseAction(_response));
    }
    return null;
  }


  Future<GmailLoginModel> signInWithGoogle(Store<AppState> store, LoginGmailAction action) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    store.dispatch(LoginLoaderAction(true));
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    GmailLoginModel _model = new GmailLoginModel();
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    if (authResult.additionalUserInfo.isNewUser) {
      //User logging in for the first time
      // Redirect user to tutorial
      _model.newUser = true;
      await user.sendEmailVerification();
    } else {
      //User has already logged in before.
      //Show user profile
      _model.newUser = false;
    }
    _model.userId = user.uid.toString();
    _model.email = user.email.toString();
    _model.firstName = user.displayName.toString();
    _model.setFirebaseUser = user;
    if (user.isEmailVerified) {
      _model.setVerified = true;
    } else {
      _model.setVerified = false;
    }
    return _model;
  }


  //gmail login
  Future<void> getMyChallenges(Store<AppState> store, MyChallengeApiAction action) async {
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    print("insidee1");
    List<ChallengeData> challengeData = new List();
    List<ChallengeData> challengeDataPast = new List();
    List<ChallengeData> challengeDataActive = new List();
    List<ChallengeData> challengeDataNext = new List();

    store.dispatch(MyChallengeActiveListAction(new List()));
    store.dispatch(MyChallengeNextListAction(new List()));
    store.dispatch(MyChallengePastListAction(new List()));
    print(store.state.userAppModal.userId);
    _database.reference().child(DataBaseConstants.userChallenges).orderByChild("userId").equalTo(store.state.userAppModal.userId).
    once().then((snapshot )async{
      if (snapshot .value != null){
        Map<dynamic, dynamic> map = snapshot.value;
        List<dynamic> userData = map.values.toList()[0]["challenges"];

        DateTime _currentDateTime = new DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day);

        userData.forEach((user) {
          if (user == null){
            return;
          }
          var challengeStartDate = user['StartDate'];
          var challengeEndDate = user['EndDate'];

          DateTime _startDateTime = new DateTime(int.parse(challengeStartDate.split('-')[0]),
              int.parse(challengeStartDate.split('-')[1]),
              int.parse(challengeStartDate.split('-')[2]));
          DateTime _endDateTime = new DateTime(int.parse(challengeEndDate.split('-')[0]),
              int.parse(challengeEndDate.split('-')[1]),
              int.parse(challengeEndDate.split('-')[2]));


          ChallengeData _modalChallenge = new ChallengeData();
          _modalChallenge.challengeName = user['challengeName'];
          _modalChallenge.challengeId = user['challengeId'].toString();
          _modalChallenge.challengeDescription = user['Description'].toString() ?? '-';
          _modalChallenge.challengeCreatedBy = user['createdBy'].toString();
          _modalChallenge.challengeDistance = user['ChallengeDistance'].toString();
          _modalChallenge.challengeStartDate = user['StartDate'].toString() ?? '-';
          _modalChallenge.challengeEndDate = user['EndDate'].toString() ?? '-';

          if(user['withdraw'] !=null && user['withdraw'] == "2"){
            challengeData
                .add(_modalChallenge);
            if(_currentDateTime.isAtSameMomentAs(_startDateTime)  ){
              challengeDataActive.add(_modalChallenge);
            }
            else if(_currentDateTime.isAfter(_startDateTime) && _currentDateTime.isBefore(_endDateTime) ){
              challengeDataActive.add(_modalChallenge);
            }
            else if(_currentDateTime.isBefore(_startDateTime)){
              challengeDataNext.add(_modalChallenge);
            }
            else if(_currentDateTime.isAfter(_endDateTime)){
              challengeDataPast.add(_modalChallenge);
            }
          }



        });

        print("insidee");
        store.dispatch(MyChallengeActiveListAction(challengeDataActive));
        store.dispatch(MyChallengeNextListAction(challengeDataNext));
        store.dispatch(MyChallengePastListAction(challengeDataPast));

      }else{
        print("no exists!");
      }
    });
  }

//z
  //"wP079Pmg2lbdWbAwqr8AjSRxkhu1"
  //BrN8extcwXd4xSOVFJMxS5GbXG22
  //IdQVIrncryYsDfFrXHXLmNcwyI62
  Future<void> getMySessionList(Store<AppState> store, SessionAction action) async {
    final FirebaseDatabase _database = FirebaseDatabase.instance;

    print(store.state.userAppModal.userId);
    List<AddSession> addSessionData = new List();
   try{
     _database.reference().child(DataBaseConstants.sessionData).orderByChild("userId").
     equalTo(store.state.userAppModal.userId).once().then((snapshot )async{
//      snapshot.
       if (snapshot .value != null){

         Map<dynamic, dynamic> map = snapshot.value;

         var newMap = Map.fromEntries(map.entries.toList()..sort((e1, e2) =>
             DateTime.parse(e1.value["createdOn"].toString()).compareTo(DateTime.parse(e2.value["createdOn"].toString()))));
         print(newMap);

         for(int value=0;  value < newMap.length; value ++){
           Map<dynamic, dynamic>  userData = newMap.values.toList()[value]["data"];

           String isDelete = newMap.values.toList()[value]["delete"] ?? "0";

           //{movementDateTime: 1590601642313, SessionData: {Speed: -1.0,
           // distance: 1, StartTime: 2020-5-27 13:47, sessionType: Automatic, activityType: Vehicle},
           // userId: 0g3d6BX0ntTbmCdtYRkWoksdacj2}
//          Map<dynamic, dynamic> map = snapshot.value;
           var _key = newMap.keys.toList()[value];
           print(_key+" key");
           print(isDelete+" del");

           AddSession _sessionModal = new AddSession();
           _sessionModal.createdOn = newMap.values.toList()[value]["createdOn"];
           _sessionModal.delete = newMap.values.toList()[value]["delete"] ?? "0";
           _sessionModal.sessionId = newMap.values.toList()[value]["sessionId"];
           _sessionModal.updatedOn = newMap.values.toList()[value]["updatedOn"];
           _sessionModal.userId = newMap.values.toList()[value]["userId"];
           _sessionModal.sessionName = newMap.values.toList()[value]["sessionName"]??"";
           _sessionModal.currentDay = newMap.values.toList()[value]["currentDay"]??"";
           _sessionModal.sessionYear = newMap.values.toList()[value]["sessionYear"]??"";
           _sessionModal.key = _key;

           prefix1.Data _dataSession = new prefix1.Data();
           _dataSession.movementDateTime = userData["movementDateTime"];
           _dataSession.userId = userData["userId"];

           SessionData _sessionInsideData = new SessionData();

           Map<dynamic, dynamic>  sessionInMap = userData["SessionData"];
           _sessionInsideData.speed = sessionInMap["Speed"];
           _sessionInsideData.startTime = sessionInMap["StartTime"];
           _sessionInsideData.activityType = sessionInMap["activityType"];
           _sessionInsideData.distance = sessionInMap["distance"];
           _sessionInsideData.sessionType = sessionInMap["sessionType"];
           _dataSession.sessionData = _sessionInsideData;
           _sessionModal.data = _dataSession;

           print(double.parse(sessionInMap["distance"]));
          if(double.parse(sessionInMap["distance"]) > 500.0 && isDelete == "0") {
            addSessionData.add(_sessionModal);
          }
         }
         List<AddSession> reversedSessions = addSessionData.reversed.toList();
         store.dispatch(SessionResponseListAction(reversedSessions));

       }
       else{
         store.dispatch(SessionResponseListAction(new List()));
         print("no exists!");
       }
     });
   }catch(Exc){
     print(Exc);
   }
  }


  Future<OrganisationResponse> getOrganisationsList(Store<AppState> store,
      OrganisationAction moactiondel) async {
    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";

    store.dispatch(LoginLoaderAction(true));

    OrganisationResponse _organisationResponse;

    try {
      final response = await http.get(baseUrl + organisationName,
          headers: header);
      if (response.statusCode == 200 || response.statusCode == 201) {
        store.dispatch(LoginLoaderAction(false));
        print("response login: ${response.body}");

        _organisationResponse = OrganisationResponse.fromJson(json.decode(response.body));
        store.dispatch(OrganisationResponseAction(_organisationResponse));
        return _organisationResponse;
      } else if (response.statusCode == 403) {
        print("response login: ${response.body}");
        store.dispatch(OrganisationResponseAction(null));
        return null;
      } else {
        print("response login: ${response.body}");
        store.dispatch(OrganisationResponseAction(null));
        return null;
      }
    } catch (e) {
      print("response login: $e");
      store.dispatch(OrganisationResponseAction(null));
      return null;
    }
  }


  Future<BranchOrganisationResponse> getBranchOrganisationsList(Store<AppState> store,
      String moactiondel) async {
    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";

    store.dispatch(LoginLoaderAction(true));

    BranchOrganisationResponse _organisationResponse;

    print(baseUrl + branchOrganisationName + moactiondel);
    try {
      final response = await http.get(baseUrl + branchOrganisationName + moactiondel,
          headers: header);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("1");
        store.dispatch(LoginLoaderAction(false));
        print("response login: ${response.body}");

        _organisationResponse = BranchOrganisationResponse.fromJson(json.decode(response.body));
        if(_organisationResponse.success == false){
          store.dispatch(
              BranchOrganisationResponseAction(null));
          store.dispatch(AccountBranchAction(false));
        }else {
          store.dispatch(
              BranchOrganisationResponseAction(_organisationResponse));
          store.dispatch(AccountBranchAction(true));
        }
        return _organisationResponse;
      } else if (response.statusCode == 403) {
        print("2");
        print("response login: ${response.body}");
        store.dispatch(BranchOrganisationResponseAction(null));
        store.dispatch(AccountBranchAction(false));
        print("dis[atch0");
        return null;
      } else {
        print("3");
        print("response login: ${response.body}");
        print("dis[atch0d");
        store.dispatch(BranchOrganisationResponseAction(null));
        store.dispatch(AccountBranchAction(false));
        print("dis[atch0");
        return null;
      }
    } catch (e) {
      print("4");
      print("response login: $e");
      store.dispatch(OrganisationResponseAction(null));
      store.dispatch(AccountBranchAction(false));
      print("dis[atch0");
      return null;
    }
  }


  Future<void> getUsersSameBusiness(Store<AppState> store) async {
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    List<UserAppModal> list = new List();
    store.dispatch(DashboardUsersResponseAction(list));
    print("in");
    SharedPreferences _prefs = PrefsSingleton.prefs;
    var aa = store.state.userAppModal.organisationName;
    _database
        .reference()
        .child("Users")
        .orderByChild("organisationName")
        .equalTo(_prefs.getString(PreferenceNames.orgName))
        .once()
        .then((snapshot) async {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> map = snapshot.value;
        print(map);
        for(int i = 0 ; i<map.length; i++ ){
          if(map.values.toList()[i]["userId"]  != store.state.userAppModal.userId) {
            UserAppModal modal = new UserAppModal();
            var firstName = map.values.toList()[i]["firstName"] ?? '';
            var lastName = map.values.toList()[i]["lastName"] ?? '';
            var userId = map.values.toList()[i]["userId"] ?? '';
            modal.firstName = firstName;
            modal.lastName = lastName;
            modal.userId = userId;
            list.add(modal);
          }
        }
        var _key = map.keys.toList()[0];
        print(_key);

        store.dispatch(DashboardUsersResponseAction(list));
      } else {
        print("no exists!");
        store.dispatch(DashboardUsersResponseAction(list));
      }
    });
  }
}
