import 'package:greenplayapp/redux/model/add_session_modal.dart';

class SessionAction {

  SessionAction();
}

class SessionResponseListAction {
  List<AddSession> addSessionList;

  SessionResponseListAction(this.addSessionList);
}