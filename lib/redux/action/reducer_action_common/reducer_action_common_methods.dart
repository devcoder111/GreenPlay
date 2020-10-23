import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/session_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/sessiondata_action.dart';
import 'package:greenplayapp/redux/model/BranchOrganisationResponse.dart';
import 'package:greenplayapp/redux/model/OrganisationResponse.dart';
import 'package:greenplayapp/redux/model/add_challenge_data_modal.dart';
import 'package:greenplayapp/redux/model/add_session_modal.dart';
import 'package:greenplayapp/redux/model/challenge_list_response.dart';
import 'package:greenplayapp/redux/model/challenge_user_modal.dart';
import 'package:greenplayapp/redux/model/data_session_share_modal.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:redux/redux.dart';

import 'OrganisationAction.dart';
import 'account_action.dart';
import 'challenge_action.dart';
import 'dashboard_action.dart';
import 'login_action.dart';


final userDBReducer = TypedReducer<UserAppModal, UserDBAction>(_userDBActionReducer); //user db values saved
final accountLoaderReducer = TypedReducer<bool, AccountLoaderAction>(_accountLoaderActionReducer); //loader for account
final challengeLoaderReducer = TypedReducer<bool, ChallengeLoaderAction>(_challengeLoaderActionReducer); //loader for challenge list
final contextChallengeReducer = TypedReducer<BuildContext, ChallengeApiAction>(_contextChallengeActionReducer); //context for challenge list
final challengeListResponseReducer = TypedReducer<ChallengeResponse, ChallengeResponseAction>(_listChallengeActionReducer); //context for challenge list
final challengeDetailLoaderReducer = TypedReducer<bool, ChallengeDetailLoaderAction>(_challengeDetailLoaderActionReducer); //context for challenge list
final challengeListParticipantReducer = TypedReducer<List<User>, ChallengeParticipantListAction>(_challengeListParticipantActionReducer); //context for challenge list
final dashLoaderReducer = TypedReducer<bool, DashboardLoaderAction>(_dashActionReducer); //context for challenge list
final dashboardPercentReducer = TypedReducer<double, DashboardPercentAction>(_dashboardPercentReducer); //context for challenge list
final dashboardCalorieReducer = TypedReducer<String, DashboardCaloriesAction>(_dashboardCaloryReducer); //context for challenge list
final contextLoginReducer = TypedReducer<BuildContext, LoginGmailAction>(_contextLoginReducer); //context for challenge list
final loaderLoginReducer = TypedReducer<bool, LoginLoaderAction>(_loaderLoginReducer); //context for challenge list
final myChallengeActiveReducer = TypedReducer<List<ChallengeData>, MyChallengeActiveListAction>(_myChallengeActiveReducer); //context for challenge list
final myChallengeNextReducer = TypedReducer<List<ChallengeData>, MyChallengeNextListAction>(_myChallengeNextReducer); //context for challenge list
final myChallengePastReducer = TypedReducer<List<ChallengeData>, MyChallengePastListAction>(_myChallengePastReducer); //context for challenge list
final myChallengeLoaderReducer = TypedReducer<bool, MyChallengeLoaderAction>(_myChallengeLoaderReducer); //context for challenge list
final sessionListReducer = TypedReducer<List<AddSession>, SessionResponseListAction>(_sessionListReducer); //context for challenge list
final organResponseReducer = TypedReducer<OrganisationResponse, OrganisationResponseAction>(_organisationResponseReducer); //context for challenge list
final branchOrganResponseReducer = TypedReducer<BranchOrganisationResponse, BranchOrganisationResponseAction>(_branchOrganisationResponseReducer); //context for challenge list
final branchIdReducer = TypedReducer<String, BranchOrganisationAction>(_branchIdReducer); //context for challenge list
final userDashboardReducer = TypedReducer< List<UserAppModal> , DashboardUsersResponseAction>(_userDashboardReducer); //context for challenge list
final isBranchReducer = TypedReducer<bool , AccountBranchAction>(_isBranchReducer); //context for challenge list
final sessionViewReducer = TypedReducer<SessionViewModal , SessionData>(_viewSessionReducer); //context for challenge list


//All methods declared in reducer are defined here...part of reducer only!


//............................................Reducer..............................................

UserAppModal _userDBActionReducer(UserAppModal state, UserDBAction action) { //user db values saved action
  return action.userAppModal;
}

bool _accountLoaderActionReducer(bool state, AccountLoaderAction action) { //user db values saved action
  return action.accountLoader;
}

bool _challengeLoaderActionReducer(bool state, ChallengeLoaderAction action) { //my challenge loader action
  return action.challengeLoader;
}

BuildContext _contextChallengeActionReducer(BuildContext state, ChallengeApiAction action) { //my challenge context action
  return action.contextChallenge;
}

ChallengeResponse _listChallengeActionReducer(ChallengeResponse state, ChallengeResponseAction action) { //my challenge context action
  return action.challengeListResponse;
}

bool _challengeDetailLoaderActionReducer(bool state, ChallengeDetailLoaderAction action) { //my challenge context action
  return action.challengeDetailLoader;
}

List<User> _challengeListParticipantActionReducer(List<User> state, ChallengeParticipantListAction action) { //my challenge context action
  return action.listParticipant;
}

bool _dashActionReducer(bool state, DashboardLoaderAction action) { //my challenge context action
  return action.dashLoader;
}

double _dashboardPercentReducer(double state, DashboardPercentAction action) { //my challenge context action
  return action.dashboardPercent;
}

String _dashboardCaloryReducer(String state, DashboardCaloriesAction action) { //my challenge context action
  return action.caloriesCount;
}

BuildContext _contextLoginReducer(BuildContext state, LoginGmailAction action) {
  return action.contextLogin;
}

bool _loaderLoginReducer(bool state, LoginLoaderAction action) {
  return action.loaderLogin;
}

List<ChallengeData> _myChallengeActiveReducer(List<ChallengeData> state, MyChallengeActiveListAction action) {
  return action.challengeListActive;
}

List<ChallengeData> _myChallengeNextReducer(List<ChallengeData> state, MyChallengeNextListAction action) {
  return action.challengeListNext;
}

List<ChallengeData> _myChallengePastReducer(List<ChallengeData> state, MyChallengePastListAction action) {
  return action.challengeListPast;
}

bool _myChallengeLoaderReducer(bool state, MyChallengeLoaderAction action) {
  return action.challengeLoader;
}

List<AddSession> _sessionListReducer(List<AddSession> state, SessionResponseListAction action) {
  return action.addSessionList;
}

OrganisationResponse _organisationResponseReducer(OrganisationResponse state, OrganisationResponseAction action) {
  return action.organisationResponse;
}

BranchOrganisationResponse _branchOrganisationResponseReducer(BranchOrganisationResponse state, BranchOrganisationResponseAction action) {
  return action.branchOrganisationResponse;
}

String _branchIdReducer(String state, BranchOrganisationAction action) {
  return action.organisationId;
}

List<UserAppModal> _userDashboardReducer(List<UserAppModal> state, DashboardUsersResponseAction action) {
  return action.listUserDashboard;
}

bool _isBranchReducer(bool state, AccountBranchAction action) {
  return action.isBranch;
}

SessionViewModal _viewSessionReducer(SessionViewModal state, SessionData action) {
  return action.sessionDataView;
}
