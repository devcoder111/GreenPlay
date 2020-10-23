import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/user_settings_model.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:greenplayapp/utils/views_common/OptionalDialogListener.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> implements OptionalDialogListener{
  bool _isLoader = false;
  bool _isFollowActivity = false;
  bool _isAllowNotification = false;
  bool _isPrecision = false;
  bool _isDelAcc = false;
  String _createdOn ;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  SharedPreferences _prefs;
  Store<AppState> store;

  var _style = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(17),
    color: Color(0xFF646E8D),
    fontWeight: FontWeight.w600,
  );

  var _styleDel = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(17),
    color: Colors.red,
    fontWeight: FontWeight.w600,
  );
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  var _key;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPref();
  }

  //initialize shared preference here.......
  void initPref() async {
    _prefs = PrefsSingleton.prefs;
    await _loadProfile();
  }



  Future<void> _loadProfile() async{
    _database.reference().child(DataBaseConstants.userSettings).orderByChild("userId").equalTo(_prefs.getString(PreferenceNames.token)).once().then((snapshot )async{
      if (snapshot .value != null){
        Map<dynamic, dynamic> map = snapshot.value;
        _key = map.keys.toList()[0];
        print(_key);
        if (this.mounted){
          setState(() {
            _isFollowActivity = map.values.toList()[0]["isMyActivity"];
            _isAllowNotification = map.values.toList()[0]["isAllowNotification"];
            _isPrecision = map.values.toList()[0]["isPrecision"];
            _createdOn = map.values.toList()[0]["createdOn"];
          });
        }else {
          _isFollowActivity = map.values.toList()[0]["isMyActivity"];
          _isAllowNotification = map.values.toList()[0]["isAllowNotification"];
          _isPrecision = map.values.toList()[0]["isPrecision"];
          _createdOn = map.values.toList()[0]["createdOn"];
        }
      }else{
        if (this.mounted){
          setState(() {
            _isFollowActivity = false;
            _isAllowNotification = false;
            _isPrecision = false;
          });
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)
      ..init(context);
    return Scaffold(
      backgroundColor: AppColors.colorBgGray,
      body:  _isLoader
          ? InkWell(
          onTap: (){},
          child:   Container(
            color: Colors.transparent,
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ) ) :Container(
        color: AppColors.colorBgGray,
        child:
        Scaffold(
          backgroundColor: AppColors.colorBgGray,
          body:
          SingleChildScrollView(
            child:
            Container(
              child:
              Column(
                children: <Widget>[
                  _followActivity(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 4,
                    color: AppColors.colorWhite,
                  ),
                  _allowNotification(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 4,
                    color: AppColors.colorWhite,
                  ),
                  _precisionData(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 4,
                    color: AppColors.colorWhite,
                  ),
                  _deleteAccount(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 4,
                    color: AppColors.colorWhite,
                  ),
//                  _logOut(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }




  /*Toggle to turn notification on/off*/
  Widget _followActivity() {
    return
      new Padding(
        padding:  EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(30, 20, 0, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DemoLocalizations.of(context).trans('follow_act'),
                  style: _style,textScaleFactor: 1.0
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Transform.scale (
                scale: 1.2,
                child: Switch(
                  value: _isFollowActivity,
                  onChanged: (bool isOn) {
                    setState(() {
                      _isFollowActivity = isOn;
                    });
                    _updateDB();
                  },
                  activeColor: Color(0xFF646E8D),
                  activeTrackColor: AppColors.colorWhite,
                  inactiveTrackColor: AppColors.colorWhite,
                  inactiveThumbColor: AppColors.colorWhite,
                ),
              ),
            ),
          ],
        ),
      );
  }



  /*Toggle to turn notification on/off*/
  Widget _allowNotification() {
    return
      new Padding(
        padding:  EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(30, 20, 0, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DemoLocalizations.of(context).trans('allow_notification'),
                  style: _style,textScaleFactor: 1.0
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Transform.scale (
                scale: 1.2,
                child: Switch(
                  value: _isAllowNotification,
                  onChanged: (bool isOn) {
                    setState(() {
                      _isAllowNotification = isOn;
                    });
                    _updateDB();
                  },
                  activeColor: Color(0xFF646E8D),
                  activeTrackColor: AppColors.colorWhite,
                  inactiveTrackColor: AppColors.colorWhite,
                  inactiveThumbColor: AppColors.colorWhite,

                ),
              ),
            ),
          ],
        ),
      );
  }

  /*Toggle to turn notification on/off*/
  Widget _precisionData() {
    return
      new Padding(
        padding:  EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(30, 20, 0, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DemoLocalizations.of(context).trans('precision'),
                  style: _style,textScaleFactor: 1.0
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Transform.scale (
                scale: 1.2,
                child: Switch(
                  value: _isPrecision,
                  onChanged: (bool isOn) {
                    setState(() {
                      _isPrecision = isOn;
                    });
                    _updateDB();
                  },
                  activeColor: Color(0xFF646E8D),
                  activeTrackColor: AppColors.colorWhite,
                  inactiveTrackColor: AppColors.colorWhite,
                  inactiveThumbColor: AppColors.colorWhite,
                ),
              ),
            ),
          ],
        ),
      );
  }


  /*Toggle to turn delete acc user*/
  Widget _deleteAccount() {
    return
      InkWell(
        onTap: (){
          AppDialogs().showAlertDialog(
              context, DemoLocalizations.of(context).trans('del_acc'),
              DemoLocalizations.of(context).trans('del_acc_content'),
              DemoLocalizations.of(context).trans('okay'),
              DemoLocalizations.of(context).trans('dialog_cancel'), this);
        },
        child:
        new Padding(
          padding:  EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(30, 20, 0, 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      DemoLocalizations.of(context).trans('del_acc'),
                      style: _styleDel,textScaleFactor: 1.0
                  ),
                ),
              ),

            ],
          ),
        ),
      );
  }



  Future<void> _updateDB() async{
    UserSettingsModal todo = new UserSettingsModal(
        _isFollowActivity,
        _isAllowNotification,
        _isPrecision,
        _createdOn,
        DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now()),
        _prefs.getString(PreferenceNames.token));
    print(todo.toJson());
    if(_key != null) {
      _database.reference().child(DataBaseConstants.userSettings).child(_key).update(
          todo.toJson());
    }else{
      _database.reference().child(DataBaseConstants.userSettings).push().set(todo.toJson());
    }

    FlutterToast.showToast(DemoLocalizations.of(context).trans('settings_added'));
  }

  @override
  void onNegativeClick() {
    // TODO: implement onNegativeClick
    setState(() {
      _isDelAcc = false;
    });
    Navigator.pop(context);
  }


  @override
  void onPositiveClick(BuildContext context)async {
    // TODO: implement onPositiveClick
    await Navigator.pop(context);
    setState(() {
      _isLoader = true;
    });
    await _database.reference().child(DataBaseConstants.users)
        .orderByChild("userId")
        .equalTo(_prefs.getString(PreferenceNames.token)).once().then((snapshot) {
      Map<dynamic, dynamic> map = snapshot.value;
      try{
        var _key = map.keys.toList()[0]??"";
        print(_prefs.getString(PreferenceNames.token));
        _database.reference().child(DataBaseConstants.users).child(_key).remove();
      }catch(Ex){}
    });

    await _database.reference().child(DataBaseConstants.sessionData)
        .orderByChild("userId")
        .equalTo(_prefs.getString(PreferenceNames.token)).once().then((snapshot) {
      Map<dynamic, dynamic> map = snapshot.value;
      try{
        var _key = map.keys.toList()[0]??"";
        print(_prefs.getString(PreferenceNames.token));
        _database.reference().child(DataBaseConstants.sessionData).child(_key).remove();
      }catch(Ex){}
    });

    await _database.reference().child(DataBaseConstants.userChallenges)
        .orderByChild("userId")
        .equalTo(_prefs.getString(PreferenceNames.token)).once().then((snapshot) {
      Map<dynamic, dynamic> map = snapshot.value;
      try{
        var _key = map.keys.toList()[0]??"";
        print(_prefs.getString(PreferenceNames.token));
        _database.reference().child(DataBaseConstants.userChallenges).child(_key).remove();
      }catch(Ex){}
    });

    await _database.reference().child(DataBaseConstants.challengeParticipant)
        .orderByChild("userId")
        .equalTo(_prefs.getString(PreferenceNames.token)).once().then((snapshot) {
      Map<dynamic, dynamic> map = snapshot.value;
      try{
        var _key = map.keys.toList()[0]??"";
        print(_prefs.getString(PreferenceNames.token));
        _database.reference().child(DataBaseConstants.challengeParticipant).child(_key).remove();
      }catch(Ex){}
    });

    try{
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      await user.delete();
    }catch(Ex){}
    setState(() {
      _isLoader = false;
    });
    signOutGoogle();

  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    await _prefs.setString(PreferenceNames.token, null);
    await _prefs.setString(PreferenceNames.timePrevious, null);
    await _prefs.setString(PreferenceNames.timeInit, null);
    await _prefs.setString(PreferenceNames.transportTypeUpdated, null);
    await _prefs.setString(PreferenceNames.transportType, null);
    await _prefs.setDouble(PreferenceNames.distanceNow, null);
    await _prefs.setDouble(PreferenceNames.sessionId, null);
    await _prefs.setDouble(PreferenceNames.timeInit, null);


    Keys.navKey.currentState.pushNamedAndRemoveUntil(
        Routes.loginScreen, (Route<dynamic> route) => false);
  }
}
