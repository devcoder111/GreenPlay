
//loader for login


import 'package:flutter/cupertino.dart';
import 'package:greenplayapp/redux/model/user_model.dart';


class UserDBAction {
  UserAppModal userAppModal;

  UserDBAction(this.userAppModal);
}

class AccountLoaderAction {
  bool accountLoader;

  AccountLoaderAction(this.accountLoader);
}

class LoginGmailAction {
  BuildContext contextLogin;

  LoginGmailAction(this.contextLogin);
}

class LoginLoaderAction {
  bool loaderLogin;

  LoginLoaderAction(this.loaderLogin);
}

class LoginNormalAction {

  LoginNormalAction();
}
