import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/OrganisationAction.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/challenge_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/dashboard_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/login_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/session_action.dart';
import 'package:greenplayapp/redux/model/challenge_list_response.dart';
import 'package:greenplayapp/redux/model/gmail_login_model.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:greenplayapp/utils/services/api_provider.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';

//This class provides way to interact with actions that have been dispatched to the store before they reach the store's reducer
//here actions for API are dispatched(async requests)

List<Middleware<AppState>> createAppMiddleware() {
  return <Middleware<AppState>>[
   thunkMiddleware,
    TypedMiddleware<AppState, ChallengeApiAction>(_myChallengeAction),
    TypedMiddleware<AppState, LoginGmailAction>(_loginGmailAction),
    TypedMiddleware<AppState, MyChallengeApiAction>(_myChallengeApiAction),
    TypedMiddleware<AppState, SessionAction>(_sessionListApiAction),
    TypedMiddleware<AppState, OrganisationAction>(_organisationApiAction),
    TypedMiddleware<AppState, BranchOrganisationAction>(_branchOrganisationApiAction),
    TypedMiddleware<AppState, DashboardUsersAction>(_getUsersDashboardApiAction),
//    TypedMiddleware<AppState, LoginNormalAction>(_loginNormalAction),
  ];
}


//to get list of my challenge list
void _myChallengeAction(
    Store<AppState> store, ChallengeApiAction action, NextDispatcher next) async {
  next(action);
  ApiProvider()
      .getChallengeList(store, action)
      .then((ChallengeResponse menuListResponse) {
    store.dispatch(MyChallengeApiAction());
//    store.dispatch(ChallengeResponseAction(menuListResponse));
//    store.dispatch(ChallengeLoaderAction(false));
  });
  print(action);
}


//to get list of my challenge list
void _loginGmailAction(
    Store<AppState> store, LoginGmailAction action, NextDispatcher next) async {
  next(action);
  ApiProvider()
      .signInWithGoogle(store, action)
      .then((value) {
    final FirebaseDatabase _database = FirebaseDatabase.instance;


    if (value.getNewUser) {
      store.dispatch(LoginLoaderAction(false));
      Keys.navKey.currentState
          .pushNamed(Routes.signUpScreen, arguments: value);
    } else {
      _database
          .reference()
          .child(DataBaseConstants.users)
          .orderByChild("userId")
          .equalTo(value.getUserId)
          .once()
          .then((snapshot) async {
        print(snapshot.value);

        if (snapshot.value != null) {
          if (value.getIsVerified) {
            Map<dynamic, dynamic> map = snapshot.value;
            var firstName = map.values.toList()[0]["firstName"];
            var lastName = map.values.toList()[0]["lastName"];
            var email = map.values.toList()[0]["email"];
            var gender = map.values.toList()[0]["gender"];
            var address = map.values.toList()[0]["address"];
            var transportMode = map.values.toList()[0]["transportMode"];

            UserAppModal _modalUser = new UserAppModal();

            SharedPreferences _prefs = PrefsSingleton.prefs;
            await _prefs.setString(PreferenceNames.token, value.getUserId);
            await _prefs.setString(PreferenceNames.firstName, firstName);
            await _prefs.setString(PreferenceNames.lastName, lastName);
            await _prefs.setString(PreferenceNames.email, email);
            await _prefs.setString(PreferenceNames.gender, gender);
            await _prefs.setString(PreferenceNames.address, address);
            await _prefs.setString(
                PreferenceNames.transportType, transportMode);
            FlutterToast.showToastCenter('Signed In......');

            if (map.values.toList()[0]["profileImage"] != null) {
              await _prefs.setString(PreferenceNames.profileImage,
                  map.values.toList()[0]["profileImage"]);
              _modalUser.profileImage =
              map.values.toList()[0]["profileImage"];
            }

            _modalUser.userId = value.getUserId;
            _modalUser.firstName = firstName;
            _modalUser.lastName = lastName;
            _modalUser.address = address;
            _modalUser.transportMode = transportMode;
            store.dispatch(UserDBAction(_modalUser));

            store.dispatch(LoginLoaderAction(false));
            Keys.navKey.currentState.pushNamedAndRemoveUntil(
                Routes.drawerScreen, (Route<dynamic> route) => false);
          } else {
            store.dispatch(LoginLoaderAction(false));
            FlutterToast.showToastCenter('Verify your email...');
          }
        } else {
          print("no exists!");
          store.dispatch(LoginLoaderAction(false));
          Keys.navKey.currentState
              .pushNamed(Routes.signUpScreen, arguments: value);
        }
      });
    }
  });
}



//to get list of my challenge list
void _loginNormalAction(
    Store<AppState> store, LoginNormalAction action, NextDispatcher next) async {
  next(action);
//  ApiProvider()
//      .signInWithNormal(store, action)
//      .then((value) {
//  });
}


void _myChallengeApiAction(
    Store<AppState> store, MyChallengeApiAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(MyChallengeActiveListAction(new List()));
  store.dispatch(MyChallengeNextListAction(new List()));
  store.dispatch(MyChallengePastListAction(new List()));
  ApiProvider()
      .getMyChallenges(store, action)
      .then((value) {
  });
}


void _sessionListApiAction(
    Store<AppState> store, SessionAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(SessionResponseListAction(new List()));
  ApiProvider()
      .getMySessionList(store, action)
      .then((value) {
  });
}


void _organisationApiAction(
    Store<AppState> store, OrganisationAction action, NextDispatcher next) async {
  next(action);
  ApiProvider()
      .getOrganisationsList(store, action)
      .then((value) {
  });
}

void _branchOrganisationApiAction(
    Store<AppState> store, BranchOrganisationAction action, NextDispatcher next) async {
  next(action);
  /*ApiProvider()
      .getBranchOrganisationsList(store, action)
      .then((value) {
  });*/
}

void _getUsersDashboardApiAction(
    Store<AppState> store, DashboardUsersAction action, NextDispatcher next) async {
  next(action);
  ApiProvider()
      .getUsersSameBusiness(store)
      .then((value) {
  });
}




