import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/login_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors/app_colors.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen> {
  Store<AppState> store;
  SharedPreferences _prefs;


  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide'); //hide keyboard
  }


  @override
  void dispose() {
    super.dispose();
  }

//initialize shared preference here.......
  void initPref() async {
    _prefs = PrefsSingleton.prefs;
    //4D3wJwg2XUd40SblRuhI6IRatqj2
    //kxCAAy2cRIObdPQTjSBxmfNBdKy2
//    _prefs.setString(PreferenceNames.id, null);
//    _prefs.setString(PreferenceNames.userId, "Wt7zway4y4SM2R9fv5TLzZ0ZCvX2");
//    _prefs.setString(PreferenceNames.token, "Wt7zway4y4SM2R9fv5TLzZ0ZCvX2");
//    _prefs.setString(PreferenceNames.orgName, "");
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, AppState>(
        converter: (Store<AppState> store) {
          this.store = store;
          return store.state;
        },
        onInit: (appState) {
          initPref();
          startTime(); //start splash timer
        },
        builder: (BuildContext context, data) {
          return Scaffold(
            body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFF347AAE), Color(0xFF4C95CC)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child:
                      Container(
                        alignment: Alignment.center,
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _appLogo(),

                          ],
                        ),
                      ),
                    ),
//                    _logoText(),
                  ],
                )),
          );
        });
  }


  startTime() async {
    var _duration = Duration(seconds: 3); //splash timer = 2
    return Timer(_duration, navigationPage);
  }


  //navigate to screen based on user shared preference values......
  void navigationPage() async {
    String _token      = _prefs.getString(PreferenceNames.token);

    if(_token == null){
      Keys.navKey.currentState.pushReplacementNamed(Routes.loginScreen);
    }else{
      UserAppModal _modalUser = new UserAppModal();
      _modalUser.userId = _token;
      _modalUser.firstName = _prefs.getString(PreferenceNames.firstName);
      _modalUser.lastName = _prefs.getString(PreferenceNames.lastName);
      _modalUser.address = _prefs.getString(PreferenceNames.address) ?? '';
      _modalUser.city = _prefs.getString(PreferenceNames.city) ?? '';
      _modalUser.transportMode = _prefs.getString(PreferenceNames.transportType);
      _modalUser.isSession = _prefs.getString(PreferenceNames.isSession) ?? "Automatic";
//      _modalUser.transportMode = _prefs.getString(PreferenceNames.transportTypeUpdated);
      if(_prefs.getString(PreferenceNames.profileImage) != null){
        _modalUser.profileImage = _prefs.getString(PreferenceNames.profileImage);
      }
      await  store.dispatch(UserDBAction(_modalUser));

      Keys.navKey.currentState.pushReplacementNamed(Routes.drawerScreen);
    }
  }


  Widget _appLogo() {
    return Align(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setWidth(36), 0, ScreenUtil.getInstance().setWidth(36), 0),
        child: SvgPicture.asset(
          'asset/logo_splash.svg',
          height: ScreenUtil.getInstance().setWidth(80),
          width: ScreenUtil.getInstance().setHeight(100),
          allowDrawingOutsideViewBox: true,
          color: AppColors.colorWhite,
        ),
      ),
    );
  }
}
