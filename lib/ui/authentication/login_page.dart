import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/login_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_user_model.dart';
import 'package:greenplayapp/redux/model/gmail_login_model.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoader = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  Store<AppState> store;
  String _passwordDecoded;

  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodePassword = new FocusNode();

  bool _obscureTextPassword = true;

  SharedPreferences _prefs;

  var _labelStyle = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorWhiteTextLabel,
    fontWeight: FontWeight.w300,
  );

  var _style = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorWhite,
    fontWeight: FontWeight.w600,
  );

  var _hintStyle = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorWhite,
    fontWeight: FontWeight.w200,
  );

  final FirebaseMessaging _fcm = FirebaseMessaging();
  String _deviceToken = '';

  getDeviceToken() async {
    _deviceToken = await _fcm.getToken();
    print(_deviceToken);
    return _deviceToken;
  }


  Future<GmailLoginModel> signInWithGoogle() async {
    setState(() {
      isLoader = true;
    });
    store.dispatch(LoginLoaderAction(true));
    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      GmailLoginModel _model = new GmailLoginModel();
      final AuthResult authResult = await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      if (authResult.additionalUserInfo.isNewUser) {
        //User logging in for the first time
        // Redirect user to tutorial
        _model.newUser = true;
        await user.sendEmailVerification();
      } else {
        //User has already logged in before.
        //Show user profile
        _model.newUser = false;
      }
      _model.userId = user.uid.toString();
      _model.email = user.email.toString();
      _model.firstName = user.displayName.toString();
      _model.setFirebaseUser = user;
      if (user.isEmailVerified) {
        _model.setVerified = true;
      } else {
        _model.setVerified = false;
      }
      return _model;
    }catch(e){
      print("a222");
      setState(() {
        isLoader = false;
      });
      store.dispatch(LoginLoaderAction(false));
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, _LoginModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _LoginModel.create(store, context);
        },
        onInit: (appState) {
          _prefs = PrefsSingleton.prefs;
          getDeviceToken();
        },
        builder: (BuildContext context, _LoginModel reducerSetup) {
          return Scaffold(
            body: reducerSetup.loader
                ? InkWell(
                    onTap: () {},
                    child: Container(
                      color: Colors.transparent,
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                    ))
                :
            Container(
              color: AppColors.colorBlue,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: SingleChildScrollView(
                      child: Stack(
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _logo(),
                              Container(
                                height: MediaQuery.of(context).size.height / 1.2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [AppColors.colorBgBlue, AppColors.colorBgBlueGradLight],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                ),
                                child:
                                Column(
                                  children: <Widget>[
                                    _greenPlay(),
                                    _signInWithGoogleButton(),
                                    SizedBox(height: 10),
                                    _signUpText()
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )

          );
        });
  }



  Widget _greenPlay() {
    return Container(
      child: Column(
        children: <Widget>[
          _emailField(), //email

          _passwordField(), //password

          _buttonLogin(),

          forgotText(),

          SizedBox(height: 10),
        ],
      ),
    );
  }


  Widget _emailField() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil.getInstance().setWidth(38),
          ScreenUtil.getInstance().setWidth(40),
          ScreenUtil.getInstance().setWidth(38),
          0.0),
      child: new TextFormField(
        maxLines: 1,
        focusNode: _focusNodeEmail,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        style: _style,
        cursorColor: AppColors.colorWhiteText,
        decoration: new InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.colorBgEditField,
            focusColor: AppColors.colorBgEditField,
            hoverColor: AppColors.colorBgEditField,
            border: OutlineInputBorder(
                borderSide: new BorderSide(color: AppColors.colorBgEditField)),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.colorBgEditField, width: 0.0),
                borderRadius: BorderRadius.all(new Radius.circular(10))),
            disabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.colorBgEditField, width: 0.0),
                borderRadius: BorderRadius.all(new Radius.circular(10))),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.colorBgEditField, width: 0.0),
                borderRadius: BorderRadius.all(new Radius.circular(10))),
            hintText: DemoLocalizations.of(context).trans('login_email'),
            hintStyle: _hintStyle,
            helperStyle: _hintStyle,
            prefixText: ' '),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil.getInstance().setWidth(38),
          ScreenUtil.getInstance().setWidth(10),
          ScreenUtil.getInstance().setWidth(38),
          0.0),
      child: new TextFormField(
        maxLines: 1,
        maxLength: 15,
        controller: _passwordController,
        obscureText: _obscureTextPassword,
        focusNode: _focusNodePassword,
        autofocus: false,
        style: _style,
        cursorColor: AppColors.colorWhiteText,
        decoration: new InputDecoration(
            counterText: '',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureTextPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.colorWhiteText,size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureTextPassword = !_obscureTextPassword;
                });
              },
            ),
            labelStyle: _labelStyle,
            filled: true,
            fillColor: AppColors.colorBgEditField,
            focusColor: AppColors.colorBgEditField,
            hoverColor: AppColors.colorBgEditField,
            border: new OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.colorBgEditField)),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.colorBgEditField, width: 0.0),
                borderRadius: BorderRadius.all(new Radius.circular(10))),
            disabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.colorBgEditField, width: 0.0),
                borderRadius: BorderRadius.all(new Radius.circular(10))),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.colorBgEditField, width: 0.0),
                borderRadius: BorderRadius.all(new Radius.circular(10))),
            hintText: DemoLocalizations.of(context).trans('login_password'),
            hintStyle: _hintStyle,
            prefixText: ' '),
      ),
    );
  }

  Widget _logo() {
    return Align(
      child: Container(
        height: MediaQuery.of(context).size.height / 2.8,
        color: AppColors.colorBgGray,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              height: ScreenUtil.getInstance().setWidth(129),
              width: ScreenUtil.getInstance().setWidth(129),
              child: SvgPicture.asset(
                'asset/logo_login.svg',
                height: ScreenUtil.getInstance().setWidth(129),
                width: ScreenUtil.getInstance().setHeight(129),
                allowDrawingOutsideViewBox: true,
                color: AppColors.colorBgBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget forgotText() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Keys.navKey.currentState.pushNamed(Routes.forgotPasswordScreen);
      },
      child: Padding(
        padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
            left: ScreenUtil.getInstance().setWidth(30),
            right: ScreenUtil.getInstance().setWidth(30)),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            DemoLocalizations.of(context).trans('login_forgot_pass'),
            style: GoogleFonts.openSans(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: ScreenUtil.getInstance().setWidth(12),
              color: AppColors.colorWhite,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.end,
              textScaleFactor: 1.0
          ),
        ),
      ),
    );
  }

  Widget _buttonLogin() {
    return Container(
      height: 52,
      margin: EdgeInsets.only(left: 38.0, right: 38.0, top: 20),
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Colors.white,
        child: Text(
          DemoLocalizations.of(context).trans('login_sign_green'),
          style: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: ScreenUtil.getInstance().setWidth(16),
            color: AppColors.colorGrayDarkButton,
            fontWeight: FontWeight.w600,
          ),
            textScaleFactor: 1.0
        ),
        onPressed: () async {
          if (_emailController.text.isEmpty) {
            FlutterToast.showToastCenter(
                DemoLocalizations.of(context).trans('login_enter_email'));
          } else if (!EmailValidator.validate(_emailController.text, true)) {
            FlutterToast.showToastCenter(
                DemoLocalizations.of(context).trans('login_not_email'));
          } else if (_passwordController.text.isEmpty) {
            FlutterToast.showToastCenter(
                DemoLocalizations.of(context).trans('login_enter_password'));
          } else if (_passwordController.text.length < 6) {
            FlutterToast.showToastCenter(
                DemoLocalizations.of(context).trans('login_atleast_password'));
          } else {
            _signInWithCredentialValidate();
          }
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Colors.white,
            )),
      ),
    );
  }

  void _signInWithCredentialValidate() async {
    setState(() {
      isLoader = true;
    });
    store.dispatch(LoginLoaderAction(true));
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    _passwordDecoded = stringToBase64.encode(_passwordController.text);
    try {
      final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      print('Signed in: $user.uid');
      if (user.isEmailVerified || !user.isEmailVerified) {
        _database
            .reference()
            .child(DataBaseConstants.users)
            .orderByChild("userId")
            .equalTo(user.uid)
            .once()
            .then((snapshot) async {
          Map<dynamic, dynamic> map = snapshot.value;
          var firstName = map.values.toList()[0]["firstName"];
          var lastName = map.values.toList()[0]["lastName"];
          var email = map.values.toList()[0]["email"];
          var gender = map.values.toList()[0]["gender"]??"";
          var address = map.values.toList()[0]["address"]?? '';
          var transportMode = map.values.toList()[0]["transportMode"];
          var isSession = map.values.toList()[0]["isSession"]??"Automatic";
          var city = map.values.toList()[0]["city"]??"";
          var weight = map.values.toList()[0]["weight"]??"";
          var orgName = map.values.toList()[0]["organisationName"]??"";

          UserAppModal _modalUser = new UserAppModal();

          await _prefs.setString(PreferenceNames.token, user.uid);
          await _prefs.setString(PreferenceNames.firstName, firstName);
          await _prefs.setString(PreferenceNames.city, city);
          await _prefs.setString(PreferenceNames.lastName, lastName);
          await _prefs.setString(PreferenceNames.email, email);
          await _prefs.setString(PreferenceNames.gender, gender);
          await _prefs.setString(PreferenceNames.address, address);
          await _prefs.setString(PreferenceNames.transportType, "");
          await _prefs.setString(PreferenceNames.isSession, isSession);
          await _prefs.setString(PreferenceNames.weight, weight);
          await _prefs.setString(PreferenceNames.orgName, orgName);
//          await _prefs.setString(PreferenceNames.transportTypeUpdated, transportMode);
          if (map.values.toList()[0]["profileImage"] != null) {
            await _prefs.setString(PreferenceNames.profileImage,
                map.values.toList()[0]["profileImage"]);
            _modalUser.profileImage = map.values.toList()[0]["profileImage"];
          }

          var _key = map.keys.toList()[0];

          AddUserModel todo = new AddUserModel(
              map.values.toList()[0]["firstName"],
              map.values.toList()[0]["lastName"],
              map.values.toList()[0]["email"],
              map.values.toList()[0]["password"],
              map.values.toList()[0]["gender"],
              map.values.toList()[0]["postalCode"] ,
              _prefs.getString(PreferenceNames.token),
              '121212121',
              true,
              map.values.toList()[0]["createdOn"],
              map.values.toList()[0]["updatedOn"],
              GetDeviceType.getDeviceType(),
              _deviceToken,
              map.values.toList()[0]["transportMode"],
              map.values.toList()[0]["address"],
              map.values.toList()[0]["profileImage"],
              map.values.toList()[0]["city"],
              map.values.toList()[0]["country"] ,
              map.values.toList()[0]["organisationName"],
              "",
              map.values.toList()[0]["city"],
              map.values.toList()[0]["dob"],
              map.values.toList()[0]["motorisedTransport"],
              map.values.toList()[0]["weight"],
              map.values.toList()[0]["isSession"],
              GetDeviceType.getDeviceType(),map.values.toList()[0]["branchName"],
              DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now()));
          print(todo.toJson());
          _database.reference().child(DataBaseConstants.users).child(_key).update(todo.toJson());

          _modalUser.userId = user.uid;
          _modalUser.firstName = firstName;
          _modalUser.lastName = lastName;
          _modalUser.address = address;
          _modalUser.address = address;
          _modalUser.isSession = isSession;
          _modalUser.city = city;
          _modalUser.organisationName = orgName;
          _modalUser.transportMode = transportMode;
          _modalUser.weight = weight;
          store.dispatch(UserDBAction(_modalUser));

          setState(() {
            isLoader = false;
          });
          store.dispatch(LoginLoaderAction(false));
          FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('signed_in'));

          Keys.navKey.currentState.pushNamedAndRemoveUntil(
              Routes.drawerScreen, (Route<dynamic> route) => false);
        });
      } else {
        setState(() {
          isLoader = false;
        });
        store.dispatch(LoginLoaderAction(false));
        FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('verify_err'));
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoader = false;
      });
      store.dispatch(LoginLoaderAction(false));
      if (e.toString().contains(',')) {
        List<String> errors = e.toString().split(',');
        FlutterToast.showToastCenter(errors[1]);
        return;
      }
      FlutterToast.showToastCenter(e.toString());
    }
  }


  Widget _signInWithGoogleButton() {
    return
      Container(
      height: 52,
      margin: EdgeInsets.only(left: 38.0, right: 38.0),
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'asset/search.svg',
              height: ScreenUtil.getInstance().setWidth(20),
              width: ScreenUtil.getInstance().setHeight(20),
              allowDrawingOutsideViewBox: true,
            ),
            Container(
              padding: EdgeInsets.only(left: 15),
              child:
              Text(
                DemoLocalizations.of(context).trans('login_sign_google'),
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setWidth(16),
                  color: AppColors.colorGrayDarkButton,
                  fontWeight: FontWeight.w600,
                ),
                  textScaleFactor: 1.0
              ),
            )
          ],
        ),
        onPressed: () async {
//          store.dispatch(LoginGmailAction(context));
                    _loginWithGmail();
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Colors.white,
            )),
      ),
    );
  }


  Future _loginWithGmail() {
    signInWithGoogle().then((value) {
      print("aaa1");
      if (value == null) {
        setState(() {
          isLoader = false;
        });
        store.dispatch(LoginLoaderAction(false));
      }else if (value.getNewUser) {
        setState(() {
          isLoader = false;
        });
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
            if (value.getIsVerified || !!value.getIsVerified) {

              Map<dynamic, dynamic> map = snapshot.value;


              var firstName = map.values.toList()[0]["firstName"] ?? "";
              var city = map.values.toList()[0]["city"]?? "";
              var lastName = map.values.toList()[0]["lastName"]?? "";
              var email = map.values.toList()[0]["email"]?? "";
              var gender = map.values.toList()[0]["gender"]?? "";
              var address = map.values.toList()[0]["address"]?? '';
              var transportMode = map.values.toList()[0]["transportMode"] ?? "";
              var isSession = map.values.toList()[0]["isSession"]??"Automatic";
              var weight = map.values.toList()[0]["weight"]??"";
              var orgName = map.values.toList()[0]["organisationName"]??"";

              UserAppModal _modalUser = new UserAppModal();

              await _prefs.setString(PreferenceNames.token, value.getUserId);
              await _prefs.setString(PreferenceNames.firstName, firstName);
              await _prefs.setString(PreferenceNames.city, city);
              await _prefs.setString(PreferenceNames.lastName, lastName);
              await _prefs.setString(PreferenceNames.email, email);
              await _prefs.setString(PreferenceNames.gender, gender);
              await _prefs.setString(PreferenceNames.address, address);
              await _prefs.setString(PreferenceNames.isSession, isSession);
              await _prefs.setString(PreferenceNames.weight, weight);
              await _prefs.setString(PreferenceNames.orgName, orgName);
              await _prefs.setString(
                  PreferenceNames.transportType, "");
              FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('signed_in'));

              if (map.values.toList()[0]["profileImage"] != null) {
                await _prefs.setString(PreferenceNames.profileImage,
                    map.values.toList()[0]["profileImage"]);
                _modalUser.profileImage =
                    map.values.toList()[0]["profileImage"];
              }

              _modalUser.userId = value.getUserId;
              _modalUser.firstName = firstName;
              _modalUser.city = city;
              _modalUser.lastName = lastName;
              _modalUser.address = address;
              _modalUser.isSession = isSession;
              _modalUser.transportMode = transportMode;
              _modalUser.organisationName = orgName;
              _modalUser.weight = weight;
              store.dispatch(UserDBAction(_modalUser));

              var _key = map.keys.toList()[0];

              AddUserModel todo = new AddUserModel(
                  map.values.toList()[0]["firstName"],
                  map.values.toList()[0]["lastName"],
                  map.values.toList()[0]["email"],
                  map.values.toList()[0]["password"],
                  map.values.toList()[0]["gender"],
                  map.values.toList()[0]["postalCode"] ,
                  _prefs.getString(PreferenceNames.token),
                  '121212121',
                  true,
                  map.values.toList()[0]["createdOn"],
                  map.values.toList()[0]["updatedOn"],
                  GetDeviceType.getDeviceType(),
                  _deviceToken,
                  map.values.toList()[0]["transportMode"],
                  map.values.toList()[0]["address"],
                  map.values.toList()[0]["profileImage"],
                  map.values.toList()[0]["city"],
                  map.values.toList()[0]["country"] ,
                  map.values.toList()[0]["organisationName"],
                  "",
                  map.values.toList()[0]["city"],
                  map.values.toList()[0]["dob"],
                  map.values.toList()[0]["motorisedTransport"],
                  map.values.toList()[0]["weight"],
                  map.values.toList()[0]["isSession"],
                  GetDeviceType.getDeviceType(),map.values.toList()[0]["branchName"],
                  DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now()));
              print(todo.toJson());
              _database.reference().child(DataBaseConstants.users).child(_key).update(todo.toJson());


              setState(() {
                isLoader = false;
              });
              store.dispatch(LoginLoaderAction(false));
//                      _database.reference().child("Users").update(todo.toJson());

              Keys.navKey.currentState.pushNamedAndRemoveUntil(
                  Routes.drawerScreen, (Route<dynamic> route) => false);
            } else {
              setState(() {
                isLoader = false;
              });
              store.dispatch(LoginLoaderAction(false));
              FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('verify_err'));
            }
          }
          else {
            print("no exists!");
            setState(() {
              isLoader = false;
            });
            store.dispatch(LoginLoaderAction(false));
            Keys.navKey.currentState
                .pushNamed(Routes.signUpScreen, arguments: value);
          }
        });
      }
    });
  }

  /*tap here to sign up field*/
  Widget _signUpText() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: InkWell(
            onTap: () {
              Keys.navKey.currentState
                  .pushNamed(Routes.signUpScreen, arguments: 'normal');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  DemoLocalizations.of(context).trans('no_acc'),
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setWidth(12),
                    color: AppColors.colorWhite,
                    fontWeight: FontWeight.w300,
                  ),
                    textScaleFactor: 1.0
                ),
                Text(
                  DemoLocalizations.of(context).trans('no_acc_signup').toUpperCase(),
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setWidth(16),
                    color: AppColors.colorWhite,
                    fontWeight: FontWeight.w500,
                  ),
                    textScaleFactor: 1.0
                )
              ],
            )));
  }
}

class _LoginModel {
  final Store<AppState> store;
  final UserAppModal userAppModal;
  final bool loader;

  _LoginModel(this.store, this.userAppModal, this.loader);

  factory _LoginModel.create(Store<AppState> store, BuildContext context) {
    return _LoginModel(store, store.state.userAppModal, store.state.loaderLogin);
  }
}
