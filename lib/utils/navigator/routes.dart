import 'package:flutter/cupertino.dart';

//define key used to navigate to routes...to be used globally
class Keys {
  static final navKey = GlobalKey<NavigatorState>();
}

//define all classes routes/screens here......
class Routes {
  static final loginScreen = "/LoginPage";
  static final signUpScreen = "/RegisterPage";
  static final forgotPasswordScreen = "/ForgotPasswordPage";
  static final drawerScreen = "/DrawerPage";
  static final challengeDetailScreen = "/ChallengeDetailScreen";
  static final addSessionScreen = "/SessionAddPage";
  static final editSessionScreen = "/SessionEditPage";
  static final viewSessionScreen = "/SessionViewPage";
  static final accountScreen = "/AccountPage";
}
