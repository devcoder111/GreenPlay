import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/OrganisationAction.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/login_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/BranchOrganisationResponse.dart';
import 'package:greenplayapp/redux/model/OrganisationResponse.dart';
import 'package:greenplayapp/redux/model/add_user_model.dart';
import 'package:greenplayapp/redux/model/data_organisation.dart';
import 'package:greenplayapp/redux/model/gmail_login_model.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/utils/PostalFormatter.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/date_time_picker/datepicker.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:greenplayapp/utils/services/api_provider.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoader = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  int _radioValue1 = -1;
  int _radioValueTransport = -1;
  int _radioValueMotor = -1;
  bool checkBoxValueOrganisation = true;
  RegExp _alpha = RegExp(r'^[a-zA-Z]+$');
  int _selectedOrganId;
  int _selectedBranchOrganId;

  OrganisationResponse organisationList;
  BranchOrganisationResponse branchOrganisationList;

  SharedPreferences _prefs;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();
  TextEditingController _cityController = new TextEditingController();
  TextEditingController _countryController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();
  TextEditingController _regionController = new TextEditingController();
  TextEditingController _organisationController = new TextEditingController();
  TextEditingController _organisationBranchController = new TextEditingController();
  TextEditingController _postalCodeController = new TextEditingController();
  TextEditingController _sexController = new TextEditingController();
  TextEditingController _transportController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _defaultMotorController = new TextEditingController();
//  var _postalCodeController = new MaskedTextController(mask: '*** ***');

  bool checkBoxValue = false;
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  String _passwordEncoded;

  DateTime selectedDate = DateTime.utc(2019);
  String _dobValue ;
  String _city;
  String _country;

  GmailLoginModel valueRoute;

  String _address;
  double _lat, _lng;
  String _deviceType = "";
  List<Address> address;
  bool _isFollowSession = true;

  final kGoogleApiKey = "AIzaSyA0orPNJCYgxEOvUYW42JOvBnpvnqWSWjE";
  GoogleMapsPlaces _places =
  GoogleMapsPlaces(apiKey: "AIzaSyA0orPNJCYgxEOvUYW42JOvBnpvnqWSWjE");



  var _style = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorBlack,
    fontWeight: FontWeight.w400,
  );

  Future<Null> displayPrediction(Prediction p, String type) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      _lat = detail.result.geometry.location.lat;
      _lng = detail.result.geometry.location.lng;

      address = await Geocoder.local.findAddressesFromQuery(p.description);
      _address = address[0].addressLine;
      print(address[0].addressLine);
//      _addressController.text = address[0].addressLine;
      print(_lat);
      print(_lng);

      if(type == 'city'){
//        _cityController.text = address[0].locality;
      }if(type == 'country'){
//        _countryController.text = address[0].countryName;
      }
    }
  }


  var _hintStyle = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(13),
    color: AppColors.colorGrayEditField,
    fontWeight: FontWeight.w200,
  );

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _sexController.dispose();
    _transportController.dispose();
    _defaultMotorController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();
  String _deviceToken = '';
  String _deviceModel;

  Store<AppState> store;
  RegExp _numeric = RegExp(r'^-?[0-9]+$');


  getDeviceToken() async {
    _deviceToken = await _fcm.getToken();
    print(_deviceToken);
    return _deviceToken;
  }

  bool isAlpha(String str) {
    return _alpha.hasMatch(str);
  }

  bool isNumeric(String str) {
    return _numeric.hasMatch(str);
  }



  DeviceInfoPlugin deviceInfo =
  DeviceInfoPlugin(); // instantiate device info plugin
  AndroidDeviceInfo androidDeviceInfo;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceToken();
    getDeviceInfo();
  }

  void getDeviceInfo() async {
    androidDeviceInfo = await deviceInfo
        .androidInfo;
    _deviceModel = androidDeviceInfo.model;
    print(_deviceModel);
  }

    @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    if (this.mounted) {
      if (ModalRoute.of(context).settings.arguments != 'normal') {
        setState(() {
          valueRoute = ModalRoute.of(context).settings.arguments;
          _emailController.text = valueRoute.getEmail;
          if (valueRoute.firstName.contains(' ')) {
            _firstNameController.text = valueRoute.firstName.split(' ')[0];
            _lastNameController.text = valueRoute.firstName.split(' ')[1];
          } else {
            _firstNameController.text = valueRoute.firstName;
          }
        });
      }
    }
    return StoreConnector<AppState, _RegisterModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _RegisterModel.create(store, context);
        },
        onInit: (store) async{
          _prefs = PrefsSingleton.prefs;
          await store.dispatch(OrganisationAction());
        },
        onDidChange: (_SessionListModel) {
          organisationList = _SessionListModel.organisationRes;
          if (this.mounted) {
            if(store.state.branchOrganisationResponse != null && store.state.branchOrganisationResponse.data != null) {
              branchOrganisationList = store.state.branchOrganisationResponse;
            }
          }
        },
        builder: (BuildContext context, _RegisterModel reducerSetup) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.colorBgGray,
              elevation: 0.0,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: AppColors.colorBlue),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: AppColors.colorBgGray,
              ),
              title: Text('Sign Up',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(24),
                    color: AppColors.colorBlue,
                    fontWeight: FontWeight.w400,
                  )),
              centerTitle: true,
            ),
            body: isLoader
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
                : Container(
                    color: AppColors.colorBgGray,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _greenPlay(reducerSetup),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }

  Widget _greenPlay(_RegisterModel data) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        children: <Widget>[
          _firstNameField(),
          //first name

          _lastNameField(),
          //last name

          _emailField(),
          //email

          valueRoute != null ? Container() : _passwordField(),
          //password

          valueRoute != null ? Container() : _confirmPasswordField(),
          //confirm password

          _sexField(),
          //sex selection
          _dobField(),

          _transportField(),

          _motorField(),
          //transport mode selection

//          _addressField(),
          //transport mode selection
//          _cityField(),
//
//          _regionField(),
          //transport mode selection
//          _countryField(),

          _cityFieldManual(), //transport mode selection

          _countryFieldManual(),

          _postalCodeField(),
          //postal code

          _organisationField(data),
          checkBoxOrganisation(),


          data.isBranch ? _branchOrganisationField(data) : Container(),

          _sessionType(),
//          checkBoxOrganisation(),
          SizedBox(height: 20),

          checkBox(),

          _buttonSignUp(),
        ],
      ),
    );
  }


  Widget _firstNameField() {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(30),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                text: DemoLocalizations.of(context).trans('reg_name_first'),
                style: GoogleFonts.openSans(
                  fontSize: ScreenUtil.getInstance().setWidth(13),
                  color: AppColors.colorGrayDark,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\*',
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // can add more TextSpans here...
                ],
              ),
            ),

            TextFormField(
              maxLines: 1,
              maxLength: 15,
              controller: _firstNameController,
              onChanged: (value) {
                if (_firstNameController.text.length == 1) {
                _firstNameController.value = TextEditingValue(
                    text: value.toUpperCase(),
                    selection: _firstNameController.selection);

                }
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              autofocus: false,
              style: _style,
              cursorColor: AppColors.colorBlue,
              decoration: new InputDecoration(
                  counterText: '',
                  fillColor: AppColors.colorGrayEditFieldd,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.colorBlue)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  disabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  hintText: DemoLocalizations.of(context)
                      .trans('register_first_name'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  }

  Widget _lastNameField() {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(20),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                text: DemoLocalizations.of(context).trans('reg_name_last'),
                style: GoogleFonts.openSans(
                  fontSize: ScreenUtil.getInstance().setWidth(13),
                  color: AppColors.colorGrayDark,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\*',
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // can add more TextSpans here...
                ],
              ),
            ),

            new TextFormField(
              maxLines: 1,
              maxLength: 15,
              controller: _lastNameController,
              onChanged: (value) {
                if (_lastNameController.text.length == 1) {
                  _lastNameController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: _lastNameController.selection);
                }
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              autofocus: false,
              style: _style,
              cursorColor: AppColors.colorBlue,
              decoration: new InputDecoration(
                  counterText: '',
                  fillColor: AppColors.colorGrayEditFieldd,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue),
                    borderRadius: BorderRadius.all(new Radius.circular(0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  disabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  hintText:
                      DemoLocalizations.of(context).trans('register_last_name'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  }

  Widget _emailField() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil.getInstance().setWidth(38),
          ScreenUtil.getInstance().setWidth(20),
          ScreenUtil.getInstance().setWidth(38),
          0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: DemoLocalizations.of(context).trans('email_head'),
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(13),
                color: AppColors.colorGrayDark,
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '\*',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // can add more TextSpans here...
              ],
            ),
          ),
          new TextFormField(
            maxLines: 1,
            enabled: ModalRoute.of(context).settings.arguments == 'normal'
                ? true
                : false,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofocus: false,
            style: _style,
            cursorColor: AppColors.colorBlue,
            decoration: new InputDecoration(
                counterText: '',
                fillColor: AppColors.colorGrayEditFieldd,
                filled: true,
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: AppColors.colorBlue),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                disabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                hintText: DemoLocalizations.of(context).trans('login_email'),
                hintStyle: _hintStyle,
                prefixText: ' '),
          )
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(20),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                text: DemoLocalizations.of(context).trans('reg_pass'),
                style: GoogleFonts.openSans(
                  fontSize: ScreenUtil.getInstance().setWidth(13),
                  color: AppColors.colorGrayDark,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\*',
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // can add more TextSpans here...
                ],
              ),
            ),

            new TextFormField(
              maxLines: 1,
              controller: _passwordController,
              obscureText: _obscureTextPassword,
              autofocus: false,
              maxLength: 15,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              style: _style,
              cursorColor: AppColors.colorBlue,
              decoration: new InputDecoration(
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.colorBlue,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextPassword = !_obscureTextPassword;
                      });
                    },
                  ),
                  fillColor: AppColors.colorGrayEditFieldd,
                  filled: true,
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: AppColors.colorBlue)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  disabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  hintText:
                      DemoLocalizations.of(context).trans('login_password'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  }

  Widget _confirmPasswordField() {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(20),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                text: DemoLocalizations.of(context).trans('reg_pass_confirm'),
                style: GoogleFonts.openSans(
                  fontSize: ScreenUtil.getInstance().setWidth(13),
                  color: AppColors.colorGrayDark,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\*',
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // can add more TextSpans here...
                ],
              ),
            ),

             TextFormField(
              maxLines: 1,
              controller: _confirmPasswordController,
              obscureText: _obscureTextConfirmPassword,
              autofocus: false,
              maxLength: 15,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              style: _style,
              cursorColor: AppColors.colorBlue,
              decoration: new InputDecoration(
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.colorBlue,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextConfirmPassword =
                            !_obscureTextConfirmPassword;
                      });
                    },
                  ),
                  fillColor: AppColors.colorGrayEditFieldd,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.colorBlue),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  disabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  hintText: DemoLocalizations.of(context)
                      .trans('register_confirm_pass'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  }

  Future<void> _alertSex() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor:AppColors.colorWhite ,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ) ,
              title: Text(DemoLocalizations.of(context).trans('dialog_gender'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(18),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  )),
              content: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,color: AppColors.colorWhite,
                        borderRadius: BorderRadius.all(new Radius.circular(20))
                    ),
                    height: ScreenUtil.getInstance().setHeight(160),
                    // Change as per your requirement
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                      Theme(
                      data: ThemeData(unselectedWidgetColor: AppColors.colorBlack), // use this
                  child:new Radio(
                                value: 0,
                                groupValue: _radioValue1,
                                activeColor: AppColors.colorBlack,
                                onChanged: (int value) {
                                  setState(() {
                                    _radioValue1 = value;
                                    _sexController.text =
                                        DemoLocalizations.of(context)
                                            .trans('dialog_male');
                                  });
                                  // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                },
                              ),),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('dialog_male'),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance()
                                      .setWidth(15),
                                  color: AppColors.colorBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Theme(
                                data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                child: new Radio(
                                value: 1,
                                groupValue: _radioValue1,
                                activeColor: AppColors.colorBlack,
                                onChanged: (int value) {
                                  setState(() {
                                    _radioValue1 = value;
                                    _sexController.text =
                                        DemoLocalizations.of(context)
                                            .trans('dialog_female');
                                  });
                                  // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                },
                              ),),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('dialog_female'),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance()
                                      .setWidth(15),
                                  color: AppColors.colorBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Theme(
                                data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                child:new Radio(
                                value: 2,
                                groupValue: _radioValue1,
                                activeColor: AppColors.colorBlack,
                                onChanged: (int value) {
                                  setState(() {
                                    _radioValue1 = value;
                                    _sexController.text =
                                        DemoLocalizations.of(context)
                                            .trans('dialog_other');
                                  });
                                  // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                },
                              ),),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('dialog_other'),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance()
                                      .setWidth(15),
                                  color: AppColors.colorBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_cancel')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_ok')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  Widget _sexField() {
    return InkWell(
        onTap: () async{
          FocusScope.of(context).unfocus();
          _alertSex();
        },
        child: Container(
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.fromLTRB(
                      ScreenUtil.getInstance().setWidth(38),
                      ScreenUtil.getInstance().setWidth(20),
                      ScreenUtil.getInstance().setWidth(38),
                      0.0),
                  child:
                  Text.rich(
                TextSpan(
                  text: DemoLocalizations.of(context).trans('reg_sex'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: AppColors.colorGrayDark,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '',
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(13),
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // can add more TextSpans here...
                  ],
                ),
              )
              ),

              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                            ScreenUtil.getInstance().setWidth(38),
                            ScreenUtil.getInstance().setWidth(0),
                            ScreenUtil.getInstance().setWidth(38),
                            0.0),
                        child: new TextField(
                          maxLines: 1,
                          enabled: false,
                          controller: _sexController,
                          autofocus: false,
                          style: _style,
                          cursorColor: AppColors.colorBlue,
                          decoration: new InputDecoration(
                              suffixIcon: new Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.colorBlue,
                                size: 20,
                              ),
                              counterText: '',
                              fillColor: AppColors.colorGrayEditFieldd,
                              filled: true,
                              border: new OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.colorBlue)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.colorBlue, width: 0.0),
                                  borderRadius:
                                  BorderRadius.all(new Radius.circular(0))),
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.colorBlue, width: 0.0),
                                  borderRadius:
                                  BorderRadius.all(new Radius.circular(0))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.colorBlue, width: 0.0),
                                  borderRadius:
                                  BorderRadius.all(new Radius.circular(0))),
                              hintText: DemoLocalizations.of(context)
                                  .trans('register_gender'),
                              hintStyle: _hintStyle,
                              prefixText: ' '),
                        ),
                      )),
                ],
              ),
            ],
          )
        ));
  }

  Future<void> _transportAlert() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
//              backgroundColor: AppColors.colorWhite,
              title: Text(
                  DemoLocalizations.of(context).trans('dialog_trans_header'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(18),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  )),
              backgroundColor: AppColors.colorWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              content: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: AppColors.colorWhite,
                    borderRadius: BorderRadius.all(new Radius.circular(20))),
                child: SingleChildScrollView(
                  child: Container(
                      height: ScreenUtil.getInstance().setHeight(200),
                      // Change as per your requirement
                      width: MediaQuery.of(context).size.width,
                      child:
                      Column(
                        children: <Widget>[
                          Expanded(
                            child:
                            Scrollbar(
                                child:
                                ListView(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 0,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('other');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('other'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 1,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('trans');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('trans'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 2,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('motor');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('motor'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 4,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('rad');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('rad'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 5,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('bike');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('bike'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 6,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('carpool');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context)
                                              .trans('carpool'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 8,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('train');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('train'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 9,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('walk');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('walk'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 10,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('electric');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil.getInstance().setWidth(150),
                                          child:
                                          new Text(
                                            DemoLocalizations.of(context)
                                                .trans('electric'),
                                            style: GoogleFonts.openSans(
                                              fontSize: ScreenUtil.getInstance()
                                                  .setWidth(15),
                                              color: AppColors.colorBlack,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 12,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('metro');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('metro'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 15,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('electric_car');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context)
                                              .trans('electric_car'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 16,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('drive');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('drive'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
                                            value: 17,
                                            groupValue: _radioValueTransport,
                                            activeColor: AppColors.colorBlack,
                                            onChanged: (int value) {
                                              setState(() {
                                                _radioValueTransport = value;
                                                _transportController.text =
                                                    DemoLocalizations.of(context)
                                                        .trans('run');
                                              });
                                              // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                            },
                                          ),
                                        ),
                                        new Text(
                                          DemoLocalizations.of(context).trans('run'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            ),
                          )
                        ],
                      )),
                ),
              ),

              actions: <Widget>[
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_ok')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  Widget _transportField() {
    return InkWell(
        onTap: () async{
          FocusScope.of(context).unfocus();
          _transportAlert();
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(
              ScreenUtil.getInstance().setWidth(38),
              ScreenUtil.getInstance().setWidth(20),
              ScreenUtil.getInstance().setWidth(38),
              0.0),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: DemoLocalizations.of(context).trans('reg_trans'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: AppColors.colorGrayDark,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\*',
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(13),
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // can add more TextSpans here...
                  ],
                ),
              ),

              new TextField(
                maxLines: 1,
                enabled: false,
                controller: _transportController,
                autofocus: false,
                style: _style,
                cursorColor: AppColors.colorBlue,
                decoration: new InputDecoration(
                    suffixIcon: new Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.colorBlue,
                      size: 20,
                    ),
                    counterText: '',
                    fillColor: AppColors.colorGrayEditFieldd,
                    filled: true,
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: AppColors.colorBlue)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(0))),
                    disabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(0))),
                    hintText:
                    DemoLocalizations.of(context).trans('signup_transport'),
                    hintStyle: _hintStyle,
                    prefixText: ' '),
              ),
            ],
          )
        ),);
  }

  Future<void> _motorAlert()async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(

              title: Text(DemoLocalizations.of(context).trans('reg_motor'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(18),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  )),
              backgroundColor: AppColors.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
              ) ,
              content:
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,color: AppColors.colorWhite,
                    borderRadius: BorderRadius.all(new Radius.circular(20))
                ),
                child:
                SingleChildScrollView(
                  child: Container(

                      height: ScreenUtil.getInstance().setHeight(200),
                      // Change as per your requirement
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                        Theme(
                        data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                        child:new Radio(
                                  value: 0,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('other');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ), ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('other'),
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                  child:new Radio(
                                  value: 1,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('carpool');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ), ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('carpool'),
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                  child:new Radio(
                                  value: 2,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('electric');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ),),
                                Container(
                                  width: ScreenUtil.getInstance().setWidth(150),
                                  child:
                                  new Text(
                                    DemoLocalizations.of(context)
                                        .trans('electric'),
                                    style: GoogleFonts.openSans(
                                      fontSize: ScreenUtil.getInstance()
                                          .setWidth(15),
                                      color: AppColors.colorBlack,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                  child:new Radio(
                                  value: 3,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('trans');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ), ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('trans'),
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                            /*Row(
                              children: <Widget>[
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                  child:new Radio(
                                  value: 4,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('bike');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ), ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('bike'),
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),*/
                            Row(
                              children: <Widget>[
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                  child:new Radio(
                                  value: 5,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('metro');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ), ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('metro'),
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                  child:new Radio(
                                  value: 6,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('train');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ), ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('train'),
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColors.colorBlack),
                                  child: new Radio(
                                  value: 7,
                                  groupValue: _radioValueMotor,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueMotor = value;
                                      _defaultMotorController.text =
                                          DemoLocalizations.of(context)
                                              .trans('electric_car');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ), ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('electric_car'),
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )),
                ),
              ),

              actions: <Widget>[
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_cancel')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_ok')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  Widget _motorField() {
    return InkWell(
        onTap: () async{
          FocusScope.of(context).unfocus();
          _motorAlert();
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(
              ScreenUtil.getInstance().setWidth(38),
              ScreenUtil.getInstance().setWidth(20),
              ScreenUtil.getInstance().setWidth(38),
              0.0),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: DemoLocalizations.of(context).trans('reg_motor'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: AppColors.colorGrayDark,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '',
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(13),
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // can add more TextSpans here...
                  ],
                ),
              ),

              new TextField(
                maxLines: 1,
                enabled: false,
                controller: _defaultMotorController,
                autofocus: false,
                style: _style,
                cursorColor: AppColors.colorBlue,
                decoration: new InputDecoration(
                    suffixIcon: new Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.colorBlue,
                      size: 20,
                    ),
                    counterText: '',
                    fillColor: AppColors.colorGrayEditFieldd,
                    filled: true,
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: AppColors.colorBlue)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(0))),
                    disabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(0))),
                    hintText:
                    DemoLocalizations.of(context).trans('reg_motor_sel'),
                    hintStyle: _hintStyle,
                    prefixText: ' '),
              ),
            ],
          )
        ),);
  }

  Widget _addressField() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil.getInstance().setWidth(38),
          ScreenUtil.getInstance().setWidth(20),
          ScreenUtil.getInstance().setWidth(38),
          0.0),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: DemoLocalizations.of(context).trans('reg_address'),
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(13),
                color: AppColors.colorGrayDark,
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // can add more TextSpans here...
              ],
            ),
          ),

          new TextFormField(
            maxLines: 1,
            controller: _addressController,
            autofocus: false,
            onChanged: (value) {
              if (_addressController.text.length == 1) {
                _addressController.value = TextEditingValue(
                    text: value.toUpperCase(),
                    selection: _addressController.selection);
              }
            },
            textInputAction: TextInputAction.next,
            maxLength: 20,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            style: _style,
            cursorColor: AppColors.colorBlue,
            decoration: new InputDecoration(
                counterText: '',
                fillColor: AppColors.colorGrayEditFieldd,
                filled: true,
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: AppColors.colorBlue),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                hintText: DemoLocalizations.of(context).trans('enter_address'),
                hintStyle: _hintStyle,
                prefixText: ' '),
          ),
        ],
      )
    );
  }


  Widget _dobField() {
    return
      InkWell(
          onTap: () async{
            FocusScope.of(context).unfocus();
            selectedDate = await Date().selectDate(context, selectedDate);
            String _month = selectedDate.month.toString();
            if (_month.length == 1) {
              _month = "0" + _month;
            }
            String _day = selectedDate.day.toString();
            if (_day.length == 1) {
              _day = "0" + _day;
            }

            DateTime dobDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
            );
            _dobController.text = DateFormat('dd MMM yyyy').format(dobDateTime);

            _dobValue =
                _day + "-" + _month + "-" + selectedDate.year.toString();
          },
          child:
          Container(
            child:  Container(
                margin: EdgeInsets.fromLTRB(
                    ScreenUtil.getInstance().setWidth(38),
                    ScreenUtil.getInstance().setWidth(10),
                    ScreenUtil.getInstance().setWidth(38),
                    0.0),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: DemoLocalizations.of(context).trans('reg_dob'),
                        style: GoogleFonts.openSans(
                          fontSize: ScreenUtil.getInstance().setWidth(13),
                          color: AppColors.colorGrayDark,
                          fontWeight: FontWeight.w400,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '',
                            style: GoogleFonts.openSans(
                              fontSize: ScreenUtil.getInstance().setWidth(13),
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),

                    new TextField(
                      maxLines: 1,
                      enabled: false,
                      controller: _dobController,
                      autofocus: false,
                      style: _style,
                      cursorColor: AppColors.colorBlue,
                      decoration: new InputDecoration(
                          counterText: '',
                          fillColor: AppColors.colorGrayEditFieldd,filled: true,
                          suffixIcon: new Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.colorBlue,
                            size: 20,
                          ),
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: AppColors.colorBlue),
                              borderRadius: BorderRadius.all(new Radius.circular(0))),
                          enabledBorder:  OutlineInputBorder(
                              borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                              borderRadius: BorderRadius.all(new Radius.circular(0))
                          ),
                          disabledBorder:  OutlineInputBorder(
                              borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                              borderRadius: BorderRadius.all(new Radius.circular(0))
                          ),
                          focusedBorder:  OutlineInputBorder(
                              borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                              borderRadius: BorderRadius.all(new Radius.circular(0))
                          ),
                          hintText:
                          DemoLocalizations.of(context).trans('register_dob'),
                          hintStyle: _hintStyle,
                          prefixText: ' '),
                    ),
                  ],
                )
            ),
          ));
  }

  Widget _regionField() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil.getInstance().setWidth(38),
          ScreenUtil.getInstance().setWidth(20),
          ScreenUtil.getInstance().setWidth(38),
          0.0),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: DemoLocalizations.of(context).trans('reg_region'),
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(13),
                color: AppColors.colorGrayDark,
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // can add more TextSpans here...
              ],
            ),
          ),

          new TextFormField(
            maxLines: 1,
            controller: _regionController,
            autofocus: false,
            textInputAction: TextInputAction.next,
            maxLength: 20,
            onChanged: (value) {},
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            style: _style,
            cursorColor: AppColors.colorBlue,
            decoration: new InputDecoration(
                counterText: '',
                fillColor: AppColors.colorGrayEditFieldd,
                filled: true,
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: AppColors.colorBlue),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                hintText: DemoLocalizations.of(context).trans('enter_region'),
                hintStyle: _hintStyle,
                prefixText: ' '),
          ),
        ],
      )
    );
  }



  Widget _cityFieldManual() {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(20),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                text: DemoLocalizations.of(context).trans('reg_city'),
                style: GoogleFonts.openSans(
                  fontSize: ScreenUtil.getInstance().setWidth(13),
                  color: AppColors.colorGrayDark,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '',
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // can add more TextSpans here...
                ],
              ),
            ),

            new TextFormField(
              maxLines: 1,
              controller: _cityController,
              onChanged: (value) {
                if (_cityController.text.length == 1) {
                  _cityController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: _cityController.selection);
                }
                _city = _cityController.text;
              },
              autofocus: false,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              style: _style,
              cursorColor: AppColors.colorBlue,
              decoration: new InputDecoration(
                  fillColor: AppColors.colorGrayEditFieldd,filled: true,
                  counterText: '',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: AppColors.colorBlue),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  enabledBorder:  OutlineInputBorder(
                      borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))
                  ),
                  disabledBorder:  OutlineInputBorder(
                      borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))
                  ),
                  focusedBorder:  OutlineInputBorder(
                      borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))
                  ),
                  hintText:
                  DemoLocalizations.of(context).trans('enter_city'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        )
    );
  }//a

  Widget _countryFieldManual() {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(20),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                text: DemoLocalizations.of(context).trans('reg_country'),
                style: GoogleFonts.openSans(
                  fontSize: ScreenUtil.getInstance().setWidth(13),
                  color: AppColors.colorGrayDark,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '',
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // can add more TextSpans here...
                ],
              ),
            ),

            new TextFormField(
              maxLines: 1,
              controller: _countryController,
              onChanged: (value) {
                if (_countryController.text.length == 1) {
                  _countryController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: _countryController.selection);
                }
                _country = _countryController.text;
              },
              autofocus: false,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              style: _style,
              cursorColor: AppColors.colorBlue,
              decoration: new InputDecoration(
                  fillColor: AppColors.colorGrayEditFieldd,filled: true,
                  counterText: '',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: AppColors.colorBlue),
                      borderRadius: BorderRadius.all(new Radius.circular(0))),
                  enabledBorder:  OutlineInputBorder(
                      borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))
                  ),
                  disabledBorder:  OutlineInputBorder(
                      borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))
                  ),
                  focusedBorder:  OutlineInputBorder(
                      borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                      borderRadius: BorderRadius.all(new Radius.circular(0))
                  ),
                  hintText:
                  DemoLocalizations.of(context).trans('enter_country'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        )
    );
  }

  //zip code edit text
  Widget _postalCodeField() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil.getInstance().setWidth(38),
          ScreenUtil.getInstance().setWidth(20),
          ScreenUtil.getInstance().setWidth(38),
          0.0),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: DemoLocalizations.of(context).trans('reg_postal'),
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(13),
                color: AppColors.colorGrayDark,
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '\*',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // can add more TextSpans here...
              ],
            ),
          ),

          new TextFormField(
            maxLines: 1,
            controller: _postalCodeController,
            autofocus: false,
            textInputAction: TextInputAction.next,
//            maxLength: 7,
            inputFormatters: [
              MaskedTextInputFormatter(
                mask: 'xxx xxx',
                separator: ' ',
              ),
            ],
            onChanged: (value) {

              _postalCodeController.value = TextEditingValue(
                  text: value.toUpperCase(),
                  selection: _postalCodeController.selection);

            },

            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            style: _style,
            cursorColor: AppColors.colorBlue,
            decoration: new InputDecoration(
                counterText: '',
                fillColor: AppColors.colorGrayEditFieldd,
                filled: true,
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: AppColors.colorBlue)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(0))),
                hintText: DemoLocalizations.of(context).trans('register_postal'),
                hintStyle: _hintStyle,
                prefixText: ' '),
          ),
        ],
      )
    );
  }

  Future<void> _alertOrganisation(_RegisterModel data) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.colorWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              title: Text(DemoLocalizations.of(context).trans('reg_organ'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(18),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  )),
              content:
              Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: AppColors.colorWhite,
                      borderRadius:
                      BorderRadius.all(new Radius.circular(20))),
                  height: ScreenUtil.getInstance().setHeight(260),
                  // Change as per your requirement
                  width: MediaQuery.of(context).size.width,
                  child:
                  Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.colorBlue)
                        ),
                        child:
                        ListTile(
//                            leading: new Icon(Icons.search),
                          title: new TextField(
//                            controller: controller,
                          style: _style,
                            onChanged: (value){
                              organisationList = new OrganisationResponse();
                              organisationList.data = new List<DataOrg>();
                              data.organisationRes.data.forEach((userDetail) {
                                if (userDetail.organization.toLowerCase().contains(value.toLowerCase()) )
                                  organisationList.data.add(userDetail);
                              });
                              if(this.mounted){
                                setState(() {
                                });
                              }
                            },
                            decoration: new InputDecoration(
                                hintText: 'Search',hintStyle: _hintStyle,
                                border:InputBorder.none,suffixIcon: Icon(Icons.search, color: AppColors.colorBlack,)
                            ),
                            // onChanged: onSearchTextChanged,
                          ),
                        ),
                      ),

                      Expanded(
                          child :
                          Scrollbar(
                            child:
                            organisationList != null ? ListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
//                                      physics: ClampingScrollPhysics(),
                                children:
                                organisationList != null ?
                                organisationList.data.map((v) {
                                  return InkWell(
                                    onTap: ()async{
                                      _organisationController.text = v.organization;
                                      _selectedOrganId = v.organizationNo;
                                      _selectedBranchOrganId = null;
                                      _organisationBranchController.clear();
                                      ApiProvider()
                                          .getBranchOrganisationsList(store, _selectedOrganId.toString())
                                          .then((value) {

                                      });
//                                  store.dispatch(BranchOrganisationAction(_selectedOrganId.toString()));
                                      Navigator.pop(context);
                                    },
                                    child:
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child:
                                      Container(
                                        padding: EdgeInsets.only(left: 5,right: 5,top: 10),
                                        child:
                                        new Text(
                                          v.organization??"-",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.openSans(
                                            fontSize: ScreenUtil.getInstance()
                                                .setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),

                                      ),
                                    ),
                                  );
                                }).toList() : Container()) : Container(),
                          )
                      ),
                    ],
                  )
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_cancel')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }


  Widget _organisationField(_RegisterModel data) {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(20),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child: InkWell(
            onTap: () async {
              FocusScope.of(context).unfocus();
              _alertOrganisation(data);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    text: DemoLocalizations.of(context).trans('reg_organ'),
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: AppColors.colorGrayDark,
                      fontWeight: FontWeight.w400,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '',
                        style: GoogleFonts.openSans(
                          fontSize: ScreenUtil.getInstance().setWidth(13),
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // can add more TextSpans here...
                    ],
                  ),
                ),
                new TextFormField(
                  maxLines: 1,
                  controller: _organisationController,
                  onChanged: (value) {
                    if (_organisationController.text.length == 1) {
                      _organisationController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: _organisationController.selection);
                    }
                  },
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.text,
                  style: _style,
                  enabled: false,
                  cursorColor: AppColors.colorBlue,
                  decoration: new InputDecoration(
                      fillColor: AppColors.colorGrayEditFieldd,
                      filled: true,
                      counterText: '',
                      suffixIcon: new Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.colorBlue,
                        size: 20,
                      ),
                      border: new OutlineInputBorder(
                          borderSide:
                          new BorderSide(color: AppColors.colorBlue),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.colorBlue, width: 0.0),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.colorBlue, width: 0.0),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.colorBlue, width: 0.0),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      hintText: DemoLocalizations.of(context)
                          .trans('enter_organise'),
                      hintStyle: _hintStyle,
                      prefixText: ' '),
                ),
              ],
            )));
  }

  //branch
  Future<void> _alertBranchOrganisation(_RegisterModel data) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.colorWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              title: Text(DemoLocalizations.of(context).trans('branch_header'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(18),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  )),
              content: SingleChildScrollView(
                  child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: AppColors.colorWhite,
                          borderRadius:
                          BorderRadius.all(new Radius.circular(20))),
                      height: ScreenUtil.getInstance().setHeight(160),
                      // Change as per your requirement
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                            children: branchOrganisationList != null ? branchOrganisationList.data.map((v) {
                              return InkWell(
                                onTap: ()async{
                                  _organisationBranchController.text = v.branchName;
                                  _selectedBranchOrganId = v.branchNo ?? "";
                                  Navigator.pop(context);
                                },
                                child:
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child:
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child:
                                    new Text(
                                      v.branchName??"-",
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.openSans(
                                        fontSize: ScreenUtil.getInstance()
                                            .setWidth(15),
                                        color: AppColors.colorBlack,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),

                                  ),
                                ),
                              );
                            }).toList() : Container()),
                      ))),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                      DemoLocalizations.of(context)
                          .trans('dialog_cancel')
                          .toUpperCase(),
                      style: GoogleFonts.openSans(
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlack,
                        fontWeight: FontWeight.w400,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }

  Widget _branchOrganisationField(_RegisterModel data) {
    return Container(
        margin: EdgeInsets.fromLTRB(
            ScreenUtil.getInstance().setWidth(38),
            ScreenUtil.getInstance().setWidth(20),
            ScreenUtil.getInstance().setWidth(38),
            0.0),
        child: InkWell(
            onTap: () async {
              FocusScope.of(context).unfocus();
              _alertBranchOrganisation(data);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    text: DemoLocalizations.of(context).trans('branch'),
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(13),
                      color: AppColors.colorGrayDark,
                      fontWeight: FontWeight.w400,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '',
                        style: GoogleFonts.openSans(
                          fontSize: ScreenUtil.getInstance().setWidth(13),
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // can add more TextSpans here...
                    ],
                  ),
                ),
                new TextFormField(
                  maxLines: 1,
                  controller: _organisationBranchController,
                  onChanged: (value) {

                  },
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.text,
                  style: _style,
                  enabled: false,
                  cursorColor: AppColors.colorBlue,
                  decoration: new InputDecoration(
                      fillColor: AppColors.colorGrayEditFieldd,
                      filled: true,
                      counterText: '',
                      suffixIcon: new Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.colorBlue,
                        size: 20,
                      ),
                      border: new OutlineInputBorder(
                          borderSide:
                          new BorderSide(color: AppColors.colorBlue),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.colorBlue, width: 0.0),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.colorBlue, width: 0.0),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.colorBlue, width: 0.0),
                          borderRadius:
                          BorderRadius.all(new Radius.circular(0))),
                      hintText: DemoLocalizations.of(context)
                          .trans('branch'),
                      hintStyle: _hintStyle,
                      prefixText: ' '),
                ),
              ],
            )));
  }


  Widget checkBoxOrganisation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
       /* Container(
            margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: AppColors.colorBlue,
                ),
                child: Checkbox(
                    value: checkBoxValueOrganisation,
                    activeColor: AppColors.colorBlue,
                    onChanged: (bool newValue) {
                      setState(() {
                        checkBoxValueOrganisation = newValue;
                      });
                      //  Text('Remember me');
                    }))),*/
        InkWell(
          onTap: () {
            showAlertDialogOrganisation(context);
          },
          child: Container(
              margin: EdgeInsets.fromLTRB(38, 0, 0, 0),
              width: ScreenUtil.getInstance().setWidth(280),
              child: Text.rich(
                TextSpan(
                  text: "",
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: AppColors.colorGrayDark,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: DemoLocalizations.of(context).trans('read_more'),
                      style: GoogleFonts.openSans(
                          fontSize: ScreenUtil.getInstance().setWidth(13),
                          color: AppColors.colorBlack,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                    // can add more TextSpans here...
                  ],
                ),
              )),
        )
      ],
    );
  }


  showAlertDialogOrganisation(BuildContext context) async {
    // set up the button
    Widget okButton = FlatButton(
      child: Text(DemoLocalizations.of(context).trans('dialog_ok')),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the button

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: AppColors.colorWhite,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
//      title: Text(DemoLocalizations.of(context).trans('terms_head')),
      content: Container(
        child:
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: new Text(DemoLocalizations.of(context).trans('organ_header')),
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  Widget checkBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: AppColors.colorBlue,
                ),
                child: Checkbox(
                    value: checkBoxValue,
                    activeColor: AppColors.colorBlue,
                    onChanged: (bool newValue) {
                      setState(() {
                        checkBoxValue = newValue;
                      });
                      //  Text('Remember me');
                    }))),
        InkWell(
          onTap: () {
            showAlertDialog(context);
          },
          child: Container(
              width: ScreenUtil.getInstance().setWidth(280),
              child: Text.rich(
                TextSpan(
                  text: DemoLocalizations.of(context).trans('terms'),
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(13),
                    color: AppColors.colorGrayDark,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: DemoLocalizations.of(context).trans('terms_add'),
                      style: GoogleFonts.openSans(
                          fontSize: ScreenUtil.getInstance().setWidth(13),
                          color: AppColors.colorBlack,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                    // can add more TextSpans here...
                  ],
                ),
              )),
        )
      ],
    );
  }

  showAlertDialog(BuildContext context) async {
    // set up the button
    Widget okButton = FlatButton(
      child: Text(DemoLocalizations.of(context).trans('dialog_ok')),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the button

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        backgroundColor: AppColors.colorWhite,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
      title: Text(DemoLocalizations.of(context).trans('terms_head')),
      content: Container(
        child:
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: new Text(DemoLocalizations.of(context).trans('terms_content')),
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  Widget _sessionType() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
            width: MediaQuery.of(context).size.width,
            child: Text(
              DemoLocalizations.of(context).trans('session_text'),maxLines: 7,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(13),
                color: Color(0xFF646E8D),
                fontWeight: FontWeight.w400,
              ),
            ),),

        new Padding(
          padding:  EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(30, 0, 0, 0),width: ScreenUtil.getInstance().setWidth(230),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DemoLocalizations.of(context).trans('auto_count'),
                    style: GoogleFonts.openSans(
                      fontSize: ScreenUtil.getInstance().setWidth(16),
                      color: AppColors.colorBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 30, 0),
                child: Transform.scale (
                  scale: 1.2,
                  child: Switch(
                    value: _isFollowSession,
                    onChanged: (bool isOn) async{
                      setState(() {
                        _isFollowSession = isOn;
                      });
                      if(_isFollowSession) {
                        await _prefs.setString(PreferenceNames.isSession, "Automatic");
                      }else{
                        await _prefs.setString(PreferenceNames.isSession, "Manual");
                      }
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
        )
      ],
    );
  }


  //sign up with greenplay button
  Widget _buttonSignUp() {
    return Container(
      height: 52,
      margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 28),
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: AppColors.colorBlue,
        child: Text(
          DemoLocalizations.of(context).trans('register_user'),
          style: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: ScreenUtil.getInstance().setWidth(15),
            color: AppColors.colorWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () async {
          _signUpValidate();
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: AppColors.colorBlue,
            )),
      ),
    );
  }

  /*Validate all functions*/
  Future<void> _signUpValidate() async {
    if (_firstNameController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_first_name'));
    } else if (_lastNameController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_last_name'));
    } else if (_emailController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('login_enter_email'));
    } else if (!checkBoxValue) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('use_error'));
    } else if (valueRoute == null) {
      if (!EmailValidator.validate(_emailController.text, true)) {
        FlutterToast.showToastCenter(
            DemoLocalizations.of(context).trans('login_not_email'));
      } else if (_passwordController.text.isEmpty) {
        FlutterToast.showToastCenter(
            DemoLocalizations.of(context).trans('login_enter_password'));
      } else if (_passwordController.text.length < 6) {
        FlutterToast.showToastCenter(
            DemoLocalizations.of(context).trans('login_atleast_password'));
      } else if (_confirmPasswordController.text.isEmpty) {
        FlutterToast.showToastCenter(
            DemoLocalizations.of(context).trans('register_confirm_pass'));
      } else if (_confirmPasswordController.text != _passwordController.text) {
        FlutterToast.showToastCenter(
            DemoLocalizations.of(context).trans('register_no_match'));
      } else if(_organisationController.text.isNotEmpty){
        if (!checkBoxValueOrganisation) {
          FlutterToast.showToastCenter(DemoLocalizations.of(context)
              .trans('organ_ack'));
        }else{
          Codec<String, String> stringToBase64 = utf8.fuse(base64);
          _passwordEncoded = stringToBase64.encode(_passwordController.text);
          _validateRest();
        }
      }else {
         Codec<String, String> stringToBase64 = utf8.fuse(base64);
         _passwordEncoded = stringToBase64.encode(_passwordController.text);
        _validateRest();
      }
    } else {
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      _passwordEncoded = stringToBase64.encode(_passwordController.text);
      _validateRest();
    }
  }

  void _validateRest() {
   /* if (_sexController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_gender'));
    } else*/ if (_transportController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('enter_transport_mode'));
    }
    /*else if (_addressController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('enter_address'));
    } else if (_regionController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('enter_region'));
    }*/
    else if (_postalCodeController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_postal'));
    }else if (_postalCodeController.text.length != 7) {
      FlutterToast.showToastCenter(
          DemoLocalizations
              .of(context)
              .trans('sel_camera'));
    }else if (!isAlpha(_postalCodeController.text[0].toString()) ) {
      FlutterToast.showToastCenter(
          DemoLocalizations
              .of(context)
              .trans('err_postal'));
    }else if (!isNumeric(_postalCodeController.text[1].toString())) {
      print("1");
      FlutterToast.showToastCenter(
          DemoLocalizations
              .of(context)
              .trans('err_postal'));
    }else if (!isAlpha(_postalCodeController.text[2].toString())) {
      print("2");
      FlutterToast.showToastCenter(
          DemoLocalizations
              .of(context)
              .trans('err_postal'));
    }else if (_postalCodeController.text[3] != ' ') {
      print("3");
      FlutterToast.showToastCenter(
          DemoLocalizations
              .of(context)
              .trans('err_postal'));
    }else if (!isNumeric(_postalCodeController.text[4].toString())) {
      print("4");
      FlutterToast.showToastCenter(
          DemoLocalizations
              .of(context)
              .trans('err_postal'));
    }else if (!isAlpha(_postalCodeController.text[5].toString())) {
      print("5");
      FlutterToast.showToastCenter(
          DemoLocalizations
              .of(context)
              .trans('err_postal'));
    }else if (!isNumeric(_postalCodeController.text[6].toString())) {
      print("6");
      FlutterToast.showToastCenter(

          DemoLocalizations
              .of(context)
              .trans('err_postal'));
    } else {
      _register();

    }
  }

  Future<void> _register() async {
    setState(() {
      isLoader = true;
    });
    String userID = '';
    if (ModalRoute.of(context).settings.arguments == 'normal') {
      try {
        String language = Localizations.localeOf(context).languageCode;
        _auth.setLanguageCode(language);
        final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        ))
            .user;
        await user.sendEmailVerification();
        userID = user.uid;

      } catch (e) {
        setState(() {
          isLoader = false;
        });
        if (e.toString().contains(',')) {
          List<String> errors = e.toString().split(',');
          FlutterToast.showToastCenter(errors[1]);
          return;
        }
        FlutterToast.showToastCenter(e.toString());
        return;
      }
    } else {
//        await valueRoute.getFirebaseUser.sendEmailVerification();
      userID = valueRoute.getUserId;
//                FlutterToast.showToastCenter('Verify your email and login to your account...');
    }

    AddUserModel todo = new AddUserModel(
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordEncoded,
        _sexController.text,
        _postalCodeController.text,
        userID,
        '121212121',
        false,
        DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now()),
        DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now()),
        GetDeviceType.getDeviceType(),
        _deviceToken,
        _transportController.text,
        _addressController.text,
        null,
        _city,
        _country,
        _organisationController.text,
        null,
        null,
        _dobValue, _defaultMotorController.text, null,_prefs.getString(PreferenceNames.isSession),
        _deviceModel, _organisationBranchController.text,
        DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now()));
    _database.reference().child(DataBaseConstants.users).push().set(todo.toJson());
    setState(() {
      isLoader = false;
    });

    if (ModalRoute.of(context).settings.arguments == 'normal') {
      await _saveData(userID);
      setState(() {
        isLoader = false;
      });
      Keys.navKey.currentState.pushNamedAndRemoveUntil(
          Routes.drawerScreen, (Route<dynamic> route) => false);
    } else {
      await _saveData(userID);
      setState(() {
        isLoader = false;
      });

      Keys.navKey.currentState.pushNamedAndRemoveUntil(
          Routes.drawerScreen, (Route<dynamic> route) => false);
    }
  }

  //save values
Future _saveData(String userID) async{
  await _prefs.setString(PreferenceNames.token, userID);
  await _prefs.setString(
      PreferenceNames.firstName, _firstNameController.text);
  await _prefs.setString(
      PreferenceNames.city, _city ?? "");
  await _prefs.setString(
      PreferenceNames.lastName, _lastNameController.text);
  await _prefs.setString(PreferenceNames.email, _emailController.text);
  await _prefs.setString(PreferenceNames.gender, _sexController.text??"");
  await _prefs.setString(
      PreferenceNames.transportType, "");
  await _prefs.setString(PreferenceNames.address, _addressController.text??'');
  await _prefs.setString(PreferenceNames.weight, '');
  await _prefs.setString(PreferenceNames.orgName, _organisationController.text);
  FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('signed_in'));

  UserAppModal _modalUser = new UserAppModal();
  _modalUser.userId = userID;
  _modalUser.firstName = _firstNameController.text;
  _modalUser.city = _city ?? "";
  _modalUser.organisationName = _organisationController.text ?? "";
  _modalUser.lastName = _lastNameController.text;
  _modalUser.address = _addressController.text??'';
  _modalUser.transportMode = _transportController.text;
  _modalUser.isSession = _prefs.getString(PreferenceNames.isSession);
  _modalUser.weight = "";
  store.dispatch(UserDBAction(_modalUser));
  setState(() {
    isLoader = false;
  });
}
}

class _RegisterModel {
  final Store<AppState> store;
  final UserAppModal userAppModal;
  final OrganisationResponse organisationRes;
  final BranchOrganisationResponse branchOrganisationRes;
  final bool isBranch;

  _RegisterModel(this.store, this.userAppModal, this.organisationRes, this.branchOrganisationRes, this.isBranch);

  factory _RegisterModel.create(Store<AppState> store, BuildContext context) {
    return _RegisterModel(store, store.state.userAppModal, store.state.organisationResponse,
        store.state.branchOrganisationResponse, store.state.isBranch);
  }
}
