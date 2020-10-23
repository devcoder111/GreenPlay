//This class takes the current state and an action, and returns the next state >>>>> Reducer

import 'package:greenplayapp/redux/action/reducer_action_common/reducer_action_common_methods.dart';

import '../app_state.dart';

AppState appReducer(AppState state, action) {
  return AppState(
    userAppModal: userDBReducer(state.userAppModal, action), //user db saved
    accountLoader: accountLoaderReducer(state.accountLoader, action), //loader for account
    challengeLoaderAll: challengeLoaderReducer(state.challengeLoaderAll, action), //loader for my challenge list
    contextChallenge: contextChallengeReducer(state.contextChallenge, action), //context for my challenge list
    challengeListResponse: challengeListResponseReducer(state.challengeListResponse, action), //data for my challenge list
    challengeDetailLoader: challengeDetailLoaderReducer(state.challengeDetailLoader, action), //loader for my challenge detail
    listParticipant: challengeListParticipantReducer(state.listParticipant, action), //list participant for my challenge detail
    loaderDashboard: dashLoaderReducer(state.loaderDashboard, action), //list participant for my challenge detail
    dashboardPercent: dashboardPercentReducer(state.dashboardPercent, action), //list participant for my challenge detail
    dashboardCalories: dashboardCalorieReducer(state.dashboardCalories, action), //list participant for my challenge detail
    contextLogin: contextLoginReducer(state.contextLogin, action), //list participant for my challenge detail
    loaderLogin: loaderLoginReducer(state.loaderLogin, action),
    listChallengeActive: myChallengeActiveReducer(state.listChallengeActive, action),
    challengeListNext: myChallengeNextReducer(state.challengeListNext, action),
    challengeListPast: myChallengePastReducer(state.challengeListPast, action),
    loaderChallengeMy: myChallengeLoaderReducer(state.loaderChallengeMy, action),
    addSessionList: sessionListReducer(state.addSessionList, action),
    organisationResponse: organResponseReducer(state.organisationResponse, action),
    branchOrganisationResponse: branchOrganResponseReducer(state.branchOrganisationResponse, action),
    organisationId: branchIdReducer(state.organisationId, action),
    listUserDashboard: userDashboardReducer(state.listUserDashboard, action),
    isBranch: isBranchReducer(state.isBranch, action),
    sessionDataView: sessionViewReducer(state.sessionDataView, action),
  );
}

