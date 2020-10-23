import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/OrganisationAction.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/account_action.dart';
import 'package:greenplayapp/redux/model/BranchOrganisationResponse.dart';
import 'package:greenplayapp/redux/model/OrganisationResponse.dart';
import 'package:greenplayapp/redux/model/data_branch.dart';
import 'package:greenplayapp/redux/model/data_organisation.dart';
import 'package:greenplayapp/utils/PostalFormatter.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/date_time_picker/datepicker.dart';
import 'package:greenplayapp/utils/services/api_provider.dart';
import 'package:greenplayapp/utils/views_common/OptionalDialogListener.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/login_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_user_model.dart';
import 'package:greenplayapp/redux/model/gmail_login_model.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    implements OptionalDialogListener {
  bool isLoader = false;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  int _radioValue1 = -1;
  var _key;
  File _image;
  String _userImageUrl;
  bool _isFollowSession = false;

  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();

//  TextEditingController _cityController = new TextEditingController();
  TextEditingController _cityController = new TextEditingController();
  TextEditingController _countryController = new TextEditingController();
  TextEditingController _organisationController = new TextEditingController();
  TextEditingController _organisationBranchController = new TextEditingController();
  TextEditingController _employeeController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _postalCodeController = new TextEditingController();
  TextEditingController _sexController = new TextEditingController();
  TextEditingController _transportController = new TextEditingController();
  TextEditingController _defaultMotorController = new TextEditingController();
  TextEditingController _defaultMotor2Controller = new TextEditingController();
  TextEditingController _weightController = new TextEditingController();

  GmailLoginModel valueRoute;
  DateTime selectedDate = DateTime.utc(2019);
  String _dobValue;

  var createdOn;
  var lastConnection;
  int _radioValueTransport = -1;
  int _radioValueMotor = -1;
  double _lat, _lng;
  List<Address> address;
  bool checkBoxValueOrganisation = false;

  String _city;
  String _country;

  final kGoogleApiKey = "AIzaSyA0orPNJCYgxEOvUYW42JOvBnpvnqWSWjE";
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "AIzaSyA0orPNJCYgxEOvUYW42JOvBnpvnqWSWjE");

  OrganisationResponse organisationList;
  BranchOrganisationResponse branchOrganisationList;

  var _style = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorBlack,
    fontWeight: FontWeight.w400,
  );

  var _hintStyle = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorGrayEditField,
    fontWeight: FontWeight.w200,
  );

  @override
  void dispose() {
    // TODO: implement dispose
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _sexController.dispose();
    _transportController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _dobController.dispose();
    _defaultMotorController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();
  String _deviceToken = '';
  String _deviceModel = '';
  SharedPreferences _prefs;
  Store<AppState> store;
  var email, password, confirmPassword;
  String _sessionTypeValue;
  int _selectedOrganId;
  int _selectedBranchOrganId;

  DeviceInfoPlugin deviceInfo =
      DeviceInfoPlugin(); // instantiate device info plugin
  AndroidDeviceInfo androidDeviceInfo;

  getDeviceToken() async {
    _deviceToken = await _fcm.getToken();
    print(_deviceToken);
    return _deviceToken;
  }

  void getDeviceInfo() async {
    if(GetDeviceType.getDeviceType() ==  "ios"){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceModel = iosInfo.utsname.machine;
    }else {
      androidDeviceInfo = await deviceInfo.androidInfo;
      _deviceModel = androidDeviceInfo.model;
    }
    print(_deviceModel);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceToken();
    getDeviceInfo();
  }

  //initialize shared preference here.......
  void initPref(Store<AppState> store) async {
    _prefs = PrefsSingleton.prefs;
    await _loadProfile(store);
    await _getOrganisations(store);
  }

  Future _getOrganisations(Store<AppState> store) async{
//    await store.dispatch(BranchOrganisationResponseAction(null));
    await store.dispatch(OrganisationAction());
  }


  Future<Null> displayPrediction(Prediction p, String type) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      _lat = detail.result.geometry.location.lat;
      _lng = detail.result.geometry.location.lng;

      address = await Geocoder.local.findAddressesFromQuery(p.description);
      print(address[0].addressLine);
//      _addressController.text = address[0].addressLine;
      print(_lat);
      print(_lng);
      print(address[0].addressLine);
      print(address[0].addressLine);
      print(address[0].featureName);
      print(address[0].locality);
      if (type == 'city') {
//        _cityController.text = address[0].locality;
      }
      if (type == 'country') {
//        _countryController.text = address[0].countryName;
      }
    }
  }


  Future<void> _loadProfile(Store<AppState> store) async {
    store.dispatch(AccountLoaderAction(true));
    _database
        .reference()
        .child(DataBaseConstants.users)
        .orderByChild("userId")
        .equalTo(_prefs.getString(PreferenceNames.token))
        .once()
        .then((snapshot) async {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> map = snapshot.value;
        _key = map.keys.toList()[0];
        print(_key);
        var firstName = map.values.toList()[0]["firstName"] ?? '';
        var lastName = map.values.toList()[0]["lastName"] ?? '';
        createdOn = map.values.toList()[0]["createdOn"] ??
            DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now());
        lastConnection = map.values.toList()[0]["lastConnection"] ??
            DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now());
        email = map.values.toList()[0]["email"];
        var gender = map.values.toList()[0]["gender"] ?? '';
        var address = map.values.toList()[0]["address"] ?? '';
        var region = map.values.toList()[0]["region"] ?? '';
        var transportMode = map.values.toList()[0]["transportMode"] ?? '';

        var motorisedTransport =
            map.values.toList()[0]["motorisedTransport"] ?? '';
        print(motorisedTransport);
        var postalCode = map.values.toList()[0]["postalCode"] ?? '';
        var city = map.values.toList()[0]["city"] ?? null;
        var country = map.values.toList()[0]["country"] ?? null;
        var organisationName = map.values.toList()[0]["organisationName"] ?? '';
        var isSession = map.values.toList()[0]["isSession"] ?? 'Automatic';
        String dob = map.values.toList()[0]["dob"] ?? '';
        String weight = map.values.toList()[0]["weight"] ?? '';
        password = map.values.toList()[0]["password"];
        confirmPassword = map.values.toList()[0]["password"];
        var url = map.values.toList()[0]["profileImage"];
        var branch = map.values.toList()[0]["branchName"];
        print("auto: $isSession");
        setState(() {
          _firstNameController.text = firstName;
          _defaultMotor2Controller.text = firstName;
          _lastNameController.text = lastName;
          _sexController.text = gender;
          _weightController.text = weight;
          if(transportMode.toString().toLowerCase() == "transit bus"){
            _transportController.text = DemoLocalizations.of(context).trans('trans');
          } else if(transportMode.toString().toLowerCase() == "motorcycling"){
            _transportController.text = DemoLocalizations.of(context).trans('motor');
          }else if(transportMode.toString().toLowerCase() == "remote work"){
            _transportController.text = DemoLocalizations.of(context).trans('rad');
          }else if(transportMode.toString().toLowerCase() == "bike"){
            _transportController.text = DemoLocalizations.of(context).trans('bike');
          }else if(transportMode.toString().toLowerCase() == "carpooling"){
            _transportController.text = DemoLocalizations.of(context).trans('carpool');
          }else if(transportMode.toString().toLowerCase() == "train"){
            _transportController.text = DemoLocalizations.of(context).trans('train');
          }else if(transportMode.toString().toLowerCase() == "walking"){
            _transportController.text = DemoLocalizations.of(context).trans('walk');
          }else if(transportMode.toString().toLowerCase() == "carpooling electric car"){
            _transportController.text = DemoLocalizations.of(context).trans('electric');
          }else if(transportMode.toString().toLowerCase() == "metro"){
            _transportController.text = DemoLocalizations.of(context).trans('metro');
          }else if(transportMode.toString().toLowerCase() == "electric car"){
            _transportController.text = DemoLocalizations.of(context).trans('electric_car');
          }else if(transportMode.toString().toLowerCase() == "driving alone"){
            _transportController.text = DemoLocalizations.of(context).trans('drive');
          }else if(transportMode.toString().toLowerCase() == "running"){
            _transportController.text = DemoLocalizations.of(context).trans('run');
          }else if(transportMode.toString().toLowerCase() == "unknown"){
            _transportController.text = DemoLocalizations.of(context).trans('unknown');
          }else if(transportMode.toString().toLowerCase() == "in vehicle"){
            _transportController.text = DemoLocalizations.of(context).trans('veh');
          }


          if(motorisedTransport.toString().toLowerCase() == "transit bus"){

              _defaultMotorController.text = DemoLocalizations.of(context).trans('trans');

          } else if(motorisedTransport.toString().toLowerCase() == "motorcycling"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('motor');
          }else if(motorisedTransport.toString().toLowerCase() == "remote work"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('rad');
          }else if(motorisedTransport.toString().toLowerCase() == "bike"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('bike');
          }else if(motorisedTransport.toString().toLowerCase() == "carpooling"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('carpool');
          }else if(motorisedTransport.toString().toLowerCase() == "train"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('train');
          }else if(motorisedTransport.toString().toLowerCase() == "walking"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('walk');
          }else if(motorisedTransport.toString().toLowerCase() == "carpooling electric car"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('electric');
          }else if(motorisedTransport.toString().toLowerCase() == "metro"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('metro');
          }else if(motorisedTransport.toString().toLowerCase() == "electric car"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('electric_car');
          }else if(motorisedTransport.toString().toLowerCase() == "driving alone"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('drive');
          }else if(motorisedTransport.toString().toLowerCase() == "running"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('run');
          }else if(motorisedTransport.toString().toLowerCase() == "unknown"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('unknown');
          }else if(motorisedTransport.toString().toLowerCase() == "in vehicle"){
            _defaultMotorController.text = DemoLocalizations.of(context).trans('veh');
          }

          _addressController.text = address;
          _postalCodeController.text = postalCode;
          _cityController.text = city;
          _countryController.text = country;
          _city = city;
          _country = country;
          _organisationController.text = organisationName;
          _sessionTypeValue = isSession;

          if (isSession == 'Automatic') {
            _isFollowSession = true;
          }if (_organisationController.text.isNotEmpty) {
            checkBoxValueOrganisation = true;
          }

          if (dob != null && dob != '') {
            DateTime dobDateTime = DateTime(
              int.parse(dob.split('-')[2]),
              int.parse(dob.split('-')[1]),
              int.parse(dob.split('-')[0]),
            );
            _dobController.text = DateFormat('dd MMM yyyy').format(dobDateTime);
            _dobValue = dob;
            selectedDate = DateTime.utc(int.parse(dob.split('-')[2]),
                int.parse(dob.split('-')[1]), int.parse(dob.split('-')[0]));
          }
          print(branch);
          if(branch != null){
            _organisationBranchController.text = branch;
            branchOrganisationList = new BranchOrganisationResponse();
            DataBranch modal = new DataBranch();
            modal.branchName = branch;
            branchOrganisationList.data = new List();
            branchOrganisationList.data.add(modal);
            print("iside");

            store.dispatch(AccountBranchAction(true));
          }
          print(branch);
          if (url != null) {
            _userImageUrl = url;
          }
        });
        store.dispatch(AccountLoaderAction(false));
      } else {
        print("no exists!");
        store.dispatch(AccountLoaderAction(false));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, _AccountModel>(
        converter: (Store<AppState> store) {
      this.store = store;

      return _AccountModel.create(store, context);
    }, onInit: (store) {
      initPref(store);
    }, onDidChange: (_SessionListModel) {
      organisationList = _SessionListModel.organisationRes;
      if (this.mounted) {
        if(store.state.branchOrganisationResponse != null && store.state.branchOrganisationResponse.data != null) {
          branchOrganisationList = store.state.branchOrganisationResponse;
        }
      }
    },builder: (BuildContext context, _AccountModel data) {
      return Scaffold(
        appBar: ModalRoute.of(context).settings.arguments != null ? AppBar(
            backgroundColor: AppColors.colorBgGray,
            elevation: 0.0,centerTitle: true,
            title: Container(
              child: Text(
                DemoLocalizations.of(context).trans('my_acc'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setSp(22),
                  color: AppColors.colorBlue,
                  fontWeight: FontWeight.w600,
                ),
                  textScaleFactor: 1.0
              ),
            ),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: AppColors.colorBlue),
              onPressed: () {
                Navigator.pop(context);
              },
              color: AppColors.colorWhite,
            )) : null,
        body: data.isLoader
            ? InkWell(
                onTap: () {},
                child: Container(
                  color: Colors.transparent,
                  height: double.infinity,
                  width: double.infinity,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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
                            SizedBox(height: 30),
                            _greenPlay(data),
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

  Widget _greenPlay(_AccountModel data) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Column(
        children: <Widget>[
          _userImage(), //first name

          _firstNameField(), //first name

          _lastNameField(), //last name

          _sexField(), //sex selection

          _dobField(), //sex selection

          _weightField(), //sex selection

          _transportField(), //transport mode selection

          _motorField(),

//          _addressField(), //transport mode selection

//          _cityField(), //transport mode selection

          _cityFieldManual(), //transport mode selection

//          _countryField(), //transport mode selection

          _countryFieldManual(),

          _postalCodeField(), //postal code

          _organisationField(data), //postal code
          checkBoxOrganisation(),


          data.isBranch ? _branchOrganisationField(data) : Container(),


//          _employeeField(), //postal code
          _sessionType(),

          SizedBox(height: 20),

          _buttonSignUp(data),
        ],
      ),
    );
  }

  /*Top user image......*/
  Widget _userImage() {
    return GestureDetector(
        onTap: () async {
          bottomSheet();
          FocusScope.of(context).unfocus();
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Column(
            children: <Widget>[
              Container(
                child: ClipOval(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _image != null
                                ? FileImage(_image)
                                : _userImageUrl != null
                                    ? NetworkImage(_userImageUrl)
                                    : AssetImage('asset/placeholder.png')),
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Text(
                  DemoLocalizations.of(context).trans('add_picture'),
                  style: GoogleFonts.poppins(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(12),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                    textScaleFactor: 1.0
                ),
                width: ScreenUtil.getInstance().setWidth(150),
              ),
            ],
          ),
        ));
  }

  void bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.camera),
                    title:
                        Text(DemoLocalizations.of(context).trans('sel_camera')),
                    onTap: () async {
                      Navigator.pop(context);
                      if (GetDeviceType.getDeviceType() == 'ios') {
                        PermissionStatus permission = await PermissionHandler()
                            .checkPermissionStatus(PermissionGroup.camera);
                        if (permission.value == 0) {
                          await PermissionHandler().openAppSettings();
                        }
                        await PermissionHandler()
                            .requestPermissions(<PermissionGroup>[
                          PermissionGroup.camera,
                        ]);
                        getImage();
                      } else {
                        getImage();
                      }
                    }),
                ListTile(
                  leading: Icon(Icons.photo),
                  title:
                      Text(DemoLocalizations.of(context).trans('sel_gallery')),
                  onTap: () async {
                    Navigator.pop(context);
                    if (GetDeviceType.getDeviceType() == 'ios') {
                      PermissionStatus permission = await PermissionHandler()
                          .checkPermissionStatus(PermissionGroup.photos);
                      if (permission.value == 0) {
                        await PermissionHandler().openAppSettings();
                      }
                      await PermissionHandler()
                          .requestPermissions(<PermissionGroup>[
                        PermissionGroup.photos,
                      ]);
                      getGallery();
                    } else {
                      getGallery();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  //For capture image
  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: MediaQuery.of(context).size.height * .4,
        maxWidth: MediaQuery.of(context).size.width);

    setState(() {
      _image = image;
    });
    uploadFile();
  }

  //For select image from gallery
  Future getGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: MediaQuery.of(context).size.height * .4,
        maxWidth: MediaQuery.of(context).size.width);

    setState(() {
      _image = image;
    });
    uploadFile();
//upload image
  }

  Future uploadFile() async {
//    store.dispatch(AccountLoaderAction(true));
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('user/${TimeOfDay.now()}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    storageReference.getDownloadURL().then((fileURL) {
      print(fileURL);
//      store.dispatch(AccountLoaderAction(false));
      setState(() {
        _userImageUrl = fileURL;
      });
    });
  }

//
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
            new TextFormField(
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
                  hintText: DemoLocalizations.of(context)
                      .trans('register_first_name'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  }

//
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
                  hintText:
                      DemoLocalizations.of(context).trans('register_last_name'),
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
              backgroundColor: AppColors.colorWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              title: Text(DemoLocalizations.of(context).trans('dialog_gender'),
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
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Theme(
                                data: ThemeData(
                                    unselectedWidgetColor:
                                        AppColors.colorBlack),
                                child: new Radio(
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
                                ),
                              ),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('dialog_male'),
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
                                ),
                              ),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('dialog_female'),
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
                                ),
                              ),
                              new Text(
                                DemoLocalizations.of(context)
                                    .trans('dialog_other'),
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
                      ),
                    )),
              ),
              actions: <Widget>[
//                FlatButton(
//                  child: Text(
//                      DemoLocalizations.of(context)
//                          .trans('dialog_cancel')
//                          .toUpperCase(),
//                      style: GoogleFonts.openSans(
//                        fontSize: ScreenUtil.getInstance().setWidth(15),
//                        color: AppColors.colorBlack,
//                        fontWeight: FontWeight.w400,
//                      )),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  },
//                ),
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

//
  Widget _sexField() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        _alertSex();
      },
      child: Container(
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
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    maxLines: 1,
                    enabled: false,
                    controller: _sexController,
                    autofocus: false,
                    style: _style,
                    cursorColor: AppColors.colorBlue,
                    decoration: new InputDecoration(
                        counterText: '',
                        fillColor: AppColors.colorGrayEditFieldd,
                        filled: true,
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
                            .trans('register_gender'),
                        hintStyle: _hintStyle,
                        prefixText: ' '),
                  )),
                ],
              ),
            ],
          )),
    );
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

  //
  Widget _transportField() {
    return InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          _transportAlert();
        },
        child: Container(
          child: Container(
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
                        counterText: '',
                        fillColor: AppColors.colorGrayEditFieldd,
                        filled: true,
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
                            .trans('transport_mode'),
                        hintStyle: _hintStyle,
                        prefixText: ' '),
                  ),
                ],
              )),
        ));
  }

  Future<void> _motorAlert() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
//              backgroundColor: AppColors.colorWhite,
              title: Text(DemoLocalizations.of(context).trans('reg_motor'),
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
                                          ),
                                        ),
                                        Container(
                                            width: ScreenUtil.getInstance().setWidth(150),
                                            child: new Text(
                                          DemoLocalizations.of(context)
                                              .trans('electric'),
                                          style: GoogleFonts.openSans(
                                            fontSize:
                                            ScreenUtil.getInstance().setWidth(15),
                                            color: AppColors.colorBlack,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                              AppColors.colorBlack),
                                          child: new Radio(
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
                                  ],
                                ),
                              )
                          )
                        ],
                      )),
                ),
              ),

              actions: <Widget>[
//                FlatButton(
//                  child: Text(
//                      DemoLocalizations.of(context)
//                          .trans('dialog_cancel')
//                          .toUpperCase(),
//                      style: GoogleFonts.openSans(
//                        fontSize: ScreenUtil.getInstance().setWidth(15),
//                        color: AppColors.colorBlack,
//                        fontWeight: FontWeight.w400,
//                      )),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  },
//                ),
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
      onTap: () async {
        FocusScope.of(context).unfocus();
        _motorAlert();
      },
      child: Container(
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
          )),
    );
  }


  //a
  Widget _cityFieldManual() {
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
                  fillColor: AppColors.colorGrayEditFieldd,
                  filled: true,
                  counterText: '',
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
                  hintText: DemoLocalizations.of(context).trans('enter_city'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  } //a

  Widget _countryFieldManual() {
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
                  fillColor: AppColors.colorGrayEditFieldd,
                  filled: true,
                  counterText: '',
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
                  hintText:
                      DemoLocalizations.of(context).trans('enter_country'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  }


  //zip code edit text
  //
  Widget _postalCodeField() {
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
              inputFormatters: [
                MaskedTextInputFormatter(
                  mask: 'xxx xxx',
                  separator: ' ',
                ),
              ],
              textInputAction: TextInputAction.next,
              maxLength: 7,
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
                  fillColor: AppColors.colorGrayEditFieldd,
                  filled: true,
                  counterText: '',
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
                  hintText:
                      DemoLocalizations.of(context).trans('register_postal'),
                  hintStyle: _hintStyle,
                  prefixText: ' '),
            ),
          ],
        ));
  }

  Future<void> _alertOrganisation(_AccountModel data) async {
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
                                hintText: 'Search',hintStyle: _hintStyle, border:InputBorder.none,
                                suffixIcon: Icon(Icons.search, color: AppColors.colorBlack,)
                            ),
                            // onChanged: onSearchTextChanged,
                          ),
                        ),
                      ),

                      Expanded(
                          child :
                          Scrollbar(
                            child:
                            ListView(
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
                                }).toList() : Container()),
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

  //
  Widget _organisationField(_AccountModel data) {
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
  Future<void> _alertBranchOrganisation(_AccountModel data) async {
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

  Widget _branchOrganisationField(_AccountModel data) {
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
          borderRadius: BorderRadius.all(Radius.circular(10))),
//      title: Text(DemoLocalizations.of(context).trans('terms_head')),
      content: Container(
        child: SingleChildScrollView(
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

  //zip code edit text
  Widget _dobField() {
    return InkWell(
        onTap: () async {
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

          _dobValue = _day + "-" + _month + "-" + selectedDate.year.toString();
        },
        child: Container(
          child: Container(
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
                        fillColor: AppColors.colorGrayEditFieldd,
                        filled: true,
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
                        hintText:
                            DemoLocalizations.of(context).trans('register_dob'),
                        hintStyle: _hintStyle,
                        prefixText: ' '),
                  ),
                ],
              )),
        ));
  }

  Widget _weightField() {
    return Container(
      child: Container(
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
                  text: DemoLocalizations.of(context).trans('weight'),
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
                enabled: true,
                controller: _weightController,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                autofocus: false,
                style: _style,
                keyboardType: TextInputType.phone,
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
                    hintText:
                        DemoLocalizations.of(context).trans('select_weight'),
                    hintStyle: _hintStyle,
                    prefixText: ' '),
              ),
            ],
          )),
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
            DemoLocalizations.of(context).trans('session_text'),
            maxLines: 7,
            style: GoogleFonts.openSans(
              fontSize: ScreenUtil.getInstance().setWidth(13),
              color: Color(0xFF646E8D),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        new Padding(
          padding: EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                width: ScreenUtil.getInstance().setWidth(230),
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
                child: Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: _isFollowSession,
                    onChanged: (bool isOn) async {
                      setState(() {
                        _isFollowSession = isOn;
                      });
                      if (_isFollowSession) {
                        _sessionTypeValue = "Automatic";
                      } else {
                        _sessionTypeValue = "Manual";
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

  Widget _buttonSignUp(_AccountModel data) {
    return Container(
      height: 52,
      margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 28),
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: AppColors.colorBlue,
        child: Text(
          DemoLocalizations.of(context).trans('update'),
          style: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: ScreenUtil.getInstance().setWidth(16),
            color: AppColors.colorWhite,
            fontWeight: FontWeight.w600,
          ),
            textScaleFactor: 1.0
        ),
        onPressed: () async {
          _signUpValidate(data);
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
  Future<void> _signUpValidate(_AccountModel data) async {
    if (_firstNameController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_first_name'));
    } else if (_lastNameController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_last_name'));
    }/* else if (_sexController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_gender'));
    }*/
    /*else if (_dobController.text.isEmpty) {
      FlutterToast.showToastCenter(DemoLocalizations.of(context)
          .trans('register_dob'));
    }*/
    else if (_transportController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('enter_transport_mode'));
    }
    /* else if (_addressController.text.isEmpty) {
      FlutterToast.showToastCenter(DemoLocalizations.of(context)
          .trans('enter_address'));
    }*/
    else if (_postalCodeController.text.isEmpty) {
      FlutterToast.showToastCenter(
          DemoLocalizations.of(context).trans('register_postal'));
    } /*else if (_organisationController.text.isNotEmpty) {
      if (!checkBoxValueOrganisation) {
        FlutterToast.showToastCenter(
            DemoLocalizations.of(context).trans('organ_ack'));
      } else {
        _submitValues();
      }
    }*/
    /*else if (_cityController.text.isEmpty) {
      FlutterToast.showToastCenter(DemoLocalizations.of(context)
          .trans('enter_city'));
    } else if (_regionController.text.isEmpty) {
      FlutterToast.showToastCenter(DemoLocalizations.of(context)
          .trans('enter_region'));
    } else if (_countryController.text.isEmpty) {
      FlutterToast.showToastCenter(DemoLocalizations.of(context)
          .trans('enter_country'));
    }*/ /*else if (_organisationController.text.isEmpty) {
      FlutterToast.showToastCenter(DemoLocalizations.of(context)
          .trans('enter_organise'));
    }*/ /*else if (_employeeController.text.isEmpty) {
      FlutterToast.showToastCenter(DemoLocalizations.of(context)
          .trans('employee_enter'));
    }*/
    else {
      _submitValues();
    }
  }

  Future<void> _submitValues() async {
    store.dispatch(AccountLoaderAction(true));

    if(!store.state.isBranch){
      _organisationBranchController.clear();
    }
    AddUserModel todo = new AddUserModel(
        _firstNameController.text,
        _lastNameController.text,
        email,
        password,
        _sexController.text,
        _postalCodeController.text,
        _prefs.getString(PreferenceNames.token),
        '121212121',
        true,
        createdOn,
        DateFormat('kk:mm:ss \n EEE dd MMM').format(DateTime.now()),
        GetDeviceType.getDeviceType(),
        _deviceToken,
        _transportController.text,
        _addressController.text,
        _userImageUrl,
        _city,
        _country,
        _organisationController.text,
        _employeeController.text,
        _cityController.text,
        _dobValue,
        _defaultMotorController.text,
        _weightController.text,
        _sessionTypeValue,
        _deviceModel,_organisationBranchController.text,lastConnection);
    print(todo.toJson());
    _database.reference().child(DataBaseConstants.users).child(_key).update(todo.toJson());

    UserAppModal _modalUser = new UserAppModal();
    _modalUser.userId = _prefs.getString(PreferenceNames.token);
    _modalUser.firstName = _firstNameController.text;
    _modalUser.lastName = _lastNameController.text;
    _modalUser.address = _addressController.text;
    _modalUser.profileImage = _userImageUrl;
    _modalUser.isSession = _prefs.getString(PreferenceNames.isSession);
    _modalUser.city = _city ?? "";
    _modalUser.weight = _weightController.text ?? "";
    _modalUser.organisationName = _organisationController.text ?? "";
    await _prefs.setString(PreferenceNames.orgName, _organisationController.text);
    await store.dispatch(UserDBAction(_modalUser));

    await _prefs.setString(
        PreferenceNames.firstName, _firstNameController.text);
    await _prefs.setString(PreferenceNames.lastName, _lastNameController.text);
    await _prefs.setString(PreferenceNames.gender, _sexController.text);
    await _prefs.setString(
        PreferenceNames.transportType, _transportController.text);
    await _prefs.setString(
        PreferenceNames.address, _addressController.text ?? '');
    await _prefs.setString(PreferenceNames.city, _city ?? '');
    await _prefs.setString(
        PreferenceNames.weight, _weightController.text ?? "");
    await _prefs.setString(PreferenceNames.isSession, _sessionTypeValue);

    store.dispatch(AccountLoaderAction(false));
//      FlutterToast.showToastCenter('Profile updated successfully');
    AppDialogs().showAlertDialog(
        context,
        DemoLocalizations.of(context).trans('success'),
        DemoLocalizations.of(context).trans('profile_update'),
        DemoLocalizations.of(context).trans('okay'),
        "",
        this);
  }

  @override
  void onNegativeClick() {
    // TODO: implement onNegativeClick
  }

  @override
  void onPositiveClick(BuildContext context) {
    // TODO: implement onPositiveClick
    Navigator.pop(context);
  }
}

class _AccountModel {
  final Store<AppState> store;
  final UserAppModal userAppModal;
  final bool isLoader;
  final OrganisationResponse organisationRes;
  final BranchOrganisationResponse branchOrganisationRes;
  final bool isBranch;

  _AccountModel(
      this.store, this.userAppModal, this.isLoader, this.organisationRes, this.branchOrganisationRes, this.isBranch);

  factory _AccountModel.create(Store<AppState> store, BuildContext context) {
    if(store.state.isBranch != null){
print(store.state.isBranch);
    }
    return _AccountModel(store, store.state.userAppModal,
        store.state.accountLoader, store.state.organisationResponse,store.state.branchOrganisationResponse,
    store.state.isBranch);
  }
}
