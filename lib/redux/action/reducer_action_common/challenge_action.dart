
//loader for challenge


import 'package:flutter/cupertino.dart';
import 'package:greenplayapp/redux/model/add_challenge_data_modal.dart';
import 'package:greenplayapp/redux/model/challenge_list_response.dart';
import 'package:greenplayapp/redux/model/challenge_user_modal.dart';




class ChallengeLoaderAction {
  bool challengeLoader;

  ChallengeLoaderAction(this.challengeLoader);
}
class ChallengeApiAction {
  BuildContext contextChallenge;

  ChallengeApiAction(this.contextChallenge);
}


class ChallengeResponseAction {
  ChallengeResponse challengeListResponse;

  ChallengeResponseAction(this.challengeListResponse);
}

class ChallengeDetailLoaderAction {
  bool challengeDetailLoader;

  ChallengeDetailLoaderAction(this.challengeDetailLoader);
}

class ChallengeParticipantListAction {
  List<User> listParticipant;

  ChallengeParticipantListAction(this.listParticipant);
}

class MyChallengeApiAction {
  BuildContext contextChallenge;

  MyChallengeApiAction();
}

class MyChallengeActiveListAction {
  List<ChallengeData> challengeListActive;

  MyChallengeActiveListAction(this.challengeListActive);
}

class MyChallengePastListAction {
  List<ChallengeData> challengeListPast;

  MyChallengePastListAction(this.challengeListPast);
}

class MyChallengeNextListAction {
  List<ChallengeData> challengeListNext;

  MyChallengeNextListAction(this.challengeListNext);
}
class MyChallengeLoaderAction {
  bool challengeLoader;

  MyChallengeLoaderAction(this.challengeLoader);
}
