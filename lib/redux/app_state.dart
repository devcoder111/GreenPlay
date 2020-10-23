import 'package:flutter/cupertino.dart';

import 'model/BranchOrganisationResponse.dart';
import 'model/OrganisationResponse.dart';
import 'model/add_challenge_data_modal.dart';
import 'model/add_session_modal.dart';
import 'model/challenge_list_response.dart';
import 'model/challenge_user_modal.dart';
import 'model/data_session_share_modal.dart';
import 'model/user_model.dart';

@immutable
class AppState {
  final bool loginLoader;  //loader for login
  final UserAppModal userAppModal;
  final bool accountLoader; //loader account
  final bool challengeLoaderAll; //loader challenge
  final ChallengeResponse challengeListResponse; //data my list challenge
  final BuildContext contextChallenge; //context for my list challenge
  final bool challengeDetailLoader; //loader for my detail challenge
  final List<User> listParticipant; //participant list in detail challenge
  final bool loaderDashboard; //dashboard list loader
  final double dashboardPercent; //dashboard
  final String dashboardCalories; //dashboard
  final  BuildContext contextLogin; //dashboard
  final  bool loaderLogin;
  final  List<ChallengeData> listChallengeActive ;
  final  List<ChallengeData> challengeListPast ;
  final  List<ChallengeData> challengeListNext ;
  final  bool loaderChallengeMy;
  final  List<AddSession> addSessionList;
  final  OrganisationResponse organisationResponse;
  final  BranchOrganisationResponse branchOrganisationResponse;
  final  String organisationId;
  final  List<UserAppModal> listUserDashboard;
  final  bool isBranch;
  final  SessionViewModal sessionDataView;


  const AppState({
  this.loginLoader,
    this.userAppModal,
    this.accountLoader,
    this.challengeLoaderAll,
    this.challengeListResponse,
    this.contextChallenge,
    this.challengeDetailLoader,
    this.listParticipant,
    this.loaderDashboard,
    this.dashboardPercent,
    this.dashboardCalories, //2 sessions  -  distance * gas - all
    this.contextLogin,
    this.loaderLogin,
    this.listChallengeActive,
    this.challengeListPast,
    this.challengeListNext,
    this.loaderChallengeMy,
    this.addSessionList,
    this.organisationResponse,
    this.branchOrganisationResponse,
    this.organisationId,
    this.listUserDashboard,
    this.isBranch,
    this.sessionDataView,
  });
}
