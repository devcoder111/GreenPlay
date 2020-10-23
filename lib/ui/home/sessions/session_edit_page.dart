import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/session_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_session_modal.dart';
import 'package:greenplayapp/redux/model/data_add_session.dart';
import 'package:greenplayapp/redux/model/session_data.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/date_time_picker/datepicker.dart';
import 'package:greenplayapp/utils/date_time_picker/timepicker.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/views_common/OptionalDialogListener.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionEditPage extends StatefulWidget {
  @override
  _SessionEditPageState createState() => _SessionEditPageState();
}

class _SessionEditPageState extends State<SessionEditPage> implements OptionalDialogListener {
  bool isLoader = false;


  TextEditingController _sessionNameController = new TextEditingController();
  TextEditingController _activityTypeController = new TextEditingController();
  TextEditingController _startDateController = new TextEditingController();
//  TextEditingController _endDateController = new TextEditingController();
  TextEditingController _distanceController = new TextEditingController();
  TextEditingController _startTimeController = new TextEditingController();
  TextEditingController _endTimeController = new TextEditingController();

  DateTime selectedDateStart = DateTime.utc(2020);
  DateTime selectedDateEnd = DateTime.utc(2020);
  TimeOfDay timeOfDayStart = TimeOfDay.now();
  TimeOfDay timeOfDayEnd = TimeOfDay.now();
  DateTime date;
  String _startDateValue ;
  String _endDateValue ;
  String transportValue;
  String delete;


  final FirebaseDatabase _database = FirebaseDatabase.instance;
  SharedPreferences _prefs;
  Store<AppState> store;

  int _radioValueTransport = -1;
  int _index;
  

  var _style = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorBlack,
    fontWeight: FontWeight.w400,
  );

  var _hintStyle = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setWidth(13),
    color: AppColors.colorGrayEditField,
    fontWeight: FontWeight.w200,
  );


  @override
  void initState() {
    // TODO: implement initState
    initPref();
    super.initState();
  }


  //initialize shared preference here.......
  void initPref() async {
    _prefs = PrefsSingleton.prefs;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _sessionNameController.dispose();
    _activityTypeController.dispose();
    _startDateController.dispose();
    _distanceController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  var _styleTab = GoogleFonts.roboto(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorWhite,
    fontWeight: FontWeight.w500,
  );


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, _SessionListModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _SessionListModel.create(store, context);
        },
        onDidChange: (_SessionListModel) {

        },
        onInit: (store) async {
          _index = ModalRoute.of(context).settings.arguments;
          String actType = store.state.addSessionList[_index].data.sessionData.activityType;
          String actTypeLocal = actType;
          if(actType.toLowerCase() == "other"){
            actTypeLocal = DemoLocalizations.of(context).trans('dialog_other');
          }else if(actType.toLowerCase() == "transit bus" ){
            actTypeLocal = DemoLocalizations.of(context).trans('trans');
          }else if(actType.toLowerCase() == "motorcycling"){
            actTypeLocal = DemoLocalizations.of(context).trans('motor');
          }else if(actType.toLowerCase() == "remote work"){
            actTypeLocal = DemoLocalizations.of(context).trans('rad');
          }else if(actType.toLowerCase() == "bike"){
            actTypeLocal = DemoLocalizations.of(context).trans('bike');
          }else if(actType.toLowerCase() == "carpooling"){
            actTypeLocal = DemoLocalizations.of(context).trans('carpool');
          }else if(actType.toLowerCase() == "train"){
            actTypeLocal = DemoLocalizations.of(context).trans('train');
          }else if(actType.toLowerCase() == "walking"){
            actTypeLocal = DemoLocalizations.of(context).trans('walk');
          }else if(actType.toLowerCase() == "carpooling electric car"){
            actTypeLocal = DemoLocalizations.of(context).trans('electric');
          }else if(actType.toLowerCase() == "metro"){
            actTypeLocal = DemoLocalizations.of(context).trans('metro');
          }else if(actType.toLowerCase() == "electric car"){
            actTypeLocal = DemoLocalizations.of(context).trans('electric_car');
          }else if(actType.toLowerCase() == "driving alone"){
            actTypeLocal = DemoLocalizations.of(context).trans('drive');
          }else if(actType.toLowerCase() == "running"){
            actTypeLocal = DemoLocalizations.of(context).trans('run');
          }else if(actType.toLowerCase() == "unknown"){
            actTypeLocal = DemoLocalizations.of(context).trans('unknown');
          }else if(actType.toLowerCase() == "in vehicle"){
            actTypeLocal = DemoLocalizations.of(context).trans('veh ');
          }

          _activityTypeController.text = actTypeLocal;
          _sessionNameController.text = store.state.addSessionList[_index].sessionName ?? "";
          delete = store.state.addSessionList[_index].delete ?? "0";
          transportValue = store.state.addSessionList[_index].data.sessionData.activityType;
          _startDateValue = DateFormat('yyyy-MM-dd').format(DateTime(
            int.parse(store.state.addSessionList[_index].updatedOn.split(' ')[0].split(
                '-')[0]),
            int.parse(store.state.addSessionList[_index].updatedOn.split(' ')[0].split(
                '-')[1]),
            int.parse(store.state.addSessionList[_index].updatedOn.split(' ')[0].split(
                '-')[2]),
          ));
          _startDateController.text = DateFormat('dd MMM yyyy').format(DateTime(
            int.parse(store.state.addSessionList[_index].updatedOn.split(' ')[0].split(
                '-')[0]),
            int.parse(store.state.addSessionList[_index].updatedOn.split(' ')[0].split(
                '-')[1]),
            int.parse(store.state.addSessionList[_index].updatedOn.split(' ')[0].split(
                '-')[2]),
          ));
          _startTimeController.text = store.state.addSessionList[_index].createdOn.split(' ')[1].split(
              ":")[0] +
              ":" +
              store.state.addSessionList[_index].createdOn.split(' ')[1].split(
                  ":")[1];
          _endTimeController.text = store.state.addSessionList[_index].updatedOn.split(' ')[1].split(
              ":")[0] +
              ":" +
              store.state.addSessionList[_index].updatedOn.split(' ')[1].split(
                  ":")[1];
          _distanceController.text =  (double.parse(store.state.addSessionList[_index].data.sessionData.distance) /
              1000)
              .toStringAsFixed(2) ;
        },

        builder: (BuildContext context, _SessionListModel data) {
          return
      Scaffold(
      backgroundColor: AppColors.colorBgGray,
      appBar:  AppBar(
          backgroundColor: AppColors.colorBlue,
          elevation: 0.0,
          title: Container(
            child: Text(
              DemoLocalizations.of(context).trans('session_edit'),
              style: _styleTab,
              textAlign: TextAlign.center,
                textScaleFactor: 1.0
            ),
          ),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: AppColors.colorWhite),
            onPressed: () {
              Navigator.pop(context);
            },
            color: AppColors.colorWhite,
          ),
      actions: <Widget>[
       /* Container(
          child:
          new IconButton(
            icon: new Icon(Icons.delete_sweep, color: AppColors.colorWhite),
            onPressed: () {
              _dialogDelete(context);
            },
            color: AppColors.colorWhite,
          ),
        )*/
      ],),
      body: isLoader
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
          ) ) : Container(
        color: AppColors.colorBgGray,
        child:
        SingleChildScrollView(
          child:
          Container(
            child:
            Column(
              children: <Widget>[
                _sessionName(), //email

                _activityType(), //password

                _startDate(),

//                _endDate(),

                _distance(),

                _timeRow(),

                SizedBox(height: 30),

                _buttonSession(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  });
  }

  
//register_last_name
  Widget _sessionName() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil.getInstance().setWidth(38),
          ScreenUtil.getInstance().setWidth(40),
          ScreenUtil.getInstance().setWidth(38),
          0.0),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: DemoLocalizations.of(context).trans('session_name'),
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
          TextFormField(
            maxLines: 1,
            controller: _sessionNameController,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              if (_sessionNameController.text.length == 1) {
                _sessionNameController.value = TextEditingValue(
                    text: value.toUpperCase(),
                    selection: _sessionNameController.selection);

              }
            },
            autofocus: false,
            style: _style,
            cursorColor: AppColors.colorBlue,
            decoration: new InputDecoration(
                fillColor: AppColors.colorGrayEditFieldd,filled: true,
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: AppColors.colorBlue),
                    borderRadius: BorderRadius.all(new Radius.circular(10))),
                enabledBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(10))
                ),
                disabledBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(10))
                ),
                focusedBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(10))
                ),
                hintText: DemoLocalizations.of(context).trans('session_name_enter'),
                hintStyle: _hintStyle,
                prefixText: ' '),
          ),
        ],
      )

    );
  }


  Future<void> _transportAlert()async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
//              backgroundColor: AppColors.colorWhite,
              title: Text(DemoLocalizations.of(context).trans('dialog_session_act'),textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(18),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  )),
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 0,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('other');
                                    });
                                    transportValue = "Other";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('other'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 1,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('trans');
                                    });
                                    transportValue = "Transit bus";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('trans'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 2,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('motor');
                                    });
                                    transportValue = "Motorcycling";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('motor'),textScaleFactor: 1.0,
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance()
                                        .setWidth(15),
                                    color: AppColors.colorBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                           /* Row(
                              children: <Widget>[
                                new Radio(
                                  value: 3,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('unknown');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                ),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('unknown'),
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 4,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('rad');
                                    });
                                    transportValue = "Remote work";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('rad'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 5,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('bike');
                                    });
                                    transportValue = "Bike";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('bike'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 6,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('carpool');
                                    });
                                    transportValue = "Carpooling";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('carpool'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 8,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('train');
                                    });
                                    transportValue = "Train";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('train'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child: new Radio(
                                  value: 9,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('walk');
                                    });
                                    transportValue = "Walking";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('walk'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 10,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('electric');
                                    });
                                    transportValue = "Carpooling electric car";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('electric'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 12,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('metro');
                                    });
                                    transportValue = "Metro";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('metro'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child: new Radio(
                                  value: 15,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('electric_car');
                                    });
                                    transportValue = "Electric car";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('electric_car'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child: new Radio(
                                  value: 16,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text =
                                          DemoLocalizations.of(context)
                                              .trans('drive');
                                    });
                                    transportValue = "Driving alone";
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context)
                                      .trans('drive'),textScaleFactor: 1.0,
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
                                    data: ThemeData.light(), //set the dark theme or write your own theme
                                    child:new Radio(
                                  value: 17,
                                  groupValue: _radioValueTransport,
                                  activeColor: AppColors.colorBlack,
                                  onChanged: (int value) {
                                    setState(() {
                                      _radioValueTransport = value;
                                      _activityTypeController.text = DemoLocalizations.of(context).trans('run');
                                    });
                                    // Whenever you need, call setState on your variable
//                                      setState(() => selectedRadio = value);
                                    transportValue = "Running";
                                  },
                                )),
                                new Text(
                                  DemoLocalizations.of(context).trans('run'),textScaleFactor: 1.0,
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
                          .toUpperCase(),textScaleFactor: 1.0,
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
                          .toUpperCase(),textScaleFactor: 1.0,
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

  Widget _activityType() {
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
                  text: DemoLocalizations.of(context).trans('dialog_session_act'),
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
                controller: _activityTypeController,
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
                        borderRadius: BorderRadius.all(new Radius.circular(10))),
                    disabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))),
                    hintText:
                    DemoLocalizations.of(context).trans('sel_tran_mode'),
                    hintStyle: _hintStyle,
                    prefixText: ' '),
              ),
            ],
          )
      ),);
  }
  
  
  


  Widget _startDate() {
    return
      InkWell(
        onTap:()  async {
          FocusScope.of(context).unfocus();
          selectedDateStart = await Date().selectDate(context, selectedDateStart);
          String _month = selectedDateStart.month.toString();
          if (_month.length == 1) {
            _month = "0" + _month;
          }
          String _day = selectedDateStart.day.toString();
          if (_day.length == 1) {
            _day = "0" + _day;
          }
          _startDateValue = selectedDateStart.year.toString() +"-" + _month + "-" + _day;
          DateTime dobDateTime = DateTime(
            selectedDateStart.year,
            selectedDateStart.month,
            selectedDateStart.day,
          );
          _startDateController.text = DateFormat('dd MMM yyyy').format(dobDateTime);
        },
        child:
        Container(
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
                   text: DemoLocalizations.of(context).trans('end_date'),
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
                 controller: _startDateController,
                 keyboardType: TextInputType.text,
                 autofocus: false,
                 enabled: false,
                 style: _style,
                 cursorColor: AppColors.colorBlue,
                 decoration: new InputDecoration(
                     fillColor: AppColors.colorGrayEditFieldd,filled: true,
                     border: new OutlineInputBorder(
                         borderSide: new BorderSide(color: AppColors.colorBlue),
                         borderRadius: BorderRadius.all(new Radius.circular(10))),
                     enabledBorder:  OutlineInputBorder(
                         borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                         borderRadius: BorderRadius.all(new Radius.circular(10))
                     ),
                     disabledBorder:  OutlineInputBorder(
                         borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                         borderRadius: BorderRadius.all(new Radius.circular(10))
                     ),
                     focusedBorder:  OutlineInputBorder(
                         borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                         borderRadius: BorderRadius.all(new Radius.circular(10))
                     ),
                     hintText: DemoLocalizations.of(context).trans('sel_end_date'),
                     hintStyle: _hintStyle,
                     prefixText: ' '),
               ),
             ],
           )

        ),
      );
  }


  Widget _distance() {
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
              text: DemoLocalizations.of(context).trans('distance'),
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
            controller: _distanceController,
            keyboardType: TextInputType.number,
            autofocus: false,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(10),
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            style: _style,
            cursorColor: AppColors.colorBlue,
            decoration: new InputDecoration(
                fillColor: AppColors.colorGrayEditFieldd,filled: true,
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: AppColors.colorBlue),
                    borderRadius: BorderRadius.all(new Radius.circular(10))),
                enabledBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(10))
                ),
                disabledBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(10))
                ),
                focusedBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                    borderRadius: BorderRadius.all(new Radius.circular(10))
                ),
                hintText: DemoLocalizations.of(context).trans('disctance_enter'),
                hintStyle: _hintStyle,
                prefixText: ' '),
          ),
        ],
      )

    );
  }

//  Widget _endDate() {
//    return
//      InkWell(
//        onTap:()  async {
//          FocusScope.of(context).unfocus();
//          selectedDateEnd = await Date().selectDate(context, selectedDateEnd);
//          String _month = selectedDateEnd.month.toString();
//          if (_month.length == 1) {
//            _month = "0" + _month;
//          }
//          String _day = selectedDateEnd.day.toString();
//          if (_day.length == 1) {
//            _day = "0" + _day;
//          }
//          _endDateValue = selectedDateEnd.year.toString() +"-" + _month + "-" + _day;
//          DateTime dobDateTime = DateTime(
//            selectedDateEnd.year,
//            selectedDateEnd.month,
//            selectedDateEnd.day,
//          );
//          _endDateController.text = DateFormat('dd MMM yyyy').format(dobDateTime);
//        },
//        child:
//        Container(
//          margin: EdgeInsets.fromLTRB(
//              ScreenUtil.getInstance().setWidth(38),
//              ScreenUtil.getInstance().setWidth(20),
//              ScreenUtil.getInstance().setWidth(38),
//              0.0),
//          child:
//          Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Text.rich(
//                TextSpan(
//                  text: DemoLocalizations.of(context).trans('end_date'),
//                  style: GoogleFonts.openSans(
//                    fontSize: ScreenUtil.getInstance().setWidth(13),
//                    color: AppColors.colorGrayDark,
//                    fontWeight: FontWeight.w400,
//                  ),
//                  children: <TextSpan>[
//                    TextSpan(
//                      text: '\*',
//                      style: GoogleFonts.openSans(
//                        fontSize: ScreenUtil.getInstance().setWidth(13),
//                        color: Colors.red,
//                        fontWeight: FontWeight.w700,
//                      ),
//                    ),
//                    // can add more TextSpans here...
//                  ],
//                ),
//              ),
//              TextFormField(
//                maxLines: 1,
//                controller: _endDateController,
//                keyboardType: TextInputType.text,
//                autofocus: false,
//                enabled: false,
//                style: _style,
//                cursorColor: AppColors.colorBlue,
//                decoration: new InputDecoration(
//                    fillColor: AppColors.colorGrayEditFieldd,filled: true,
//                    border: new OutlineInputBorder(
//                        borderSide: new BorderSide(color: AppColors.colorBlue),
//                        borderRadius: BorderRadius.all(new Radius.circular(10))),
//                    enabledBorder:  OutlineInputBorder(
//                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
//                        borderRadius: BorderRadius.all(new Radius.circular(10))
//                    ),
//                    disabledBorder:  OutlineInputBorder(
//                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
//                        borderRadius: BorderRadius.all(new Radius.circular(10))
//                    ),
//                    focusedBorder:  OutlineInputBorder(
//                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
//                        borderRadius: BorderRadius.all(new Radius.circular(10))
//                    ),
//                    hintText: DemoLocalizations.of(context).trans('sel_end_date'),
//                    hintStyle: _hintStyle,
//                    prefixText: ' '),
//              ),
//            ],
//          )
//
//        ),
//      );
//  }





  Widget _timeRow() {
    return
        Container(
          margin: EdgeInsets.fromLTRB(
              ScreenUtil.getInstance().setWidth(38),
              ScreenUtil.getInstance().setWidth(10),
              ScreenUtil.getInstance().setWidth(38),
              0.0),
          child:
          Row(
            children: <Widget>[
              Expanded(child: _startTime()),
              Expanded(child: _endTime())
            ],
          ),
        );
  }


  Widget _startTime() {
    return
      InkWell(
        onTap:() async {
      FocusScope.of(context).unfocus();
      timeOfDayStart = await Time().selectTime(context, timeOfDayStart);
      String _hour = timeOfDayStart.hour.toString();
      if (_hour.length == 1) {
        _hour = "0" + _hour;
      }
      String _min = timeOfDayStart.minute.toString();
      if (_min.length == 1) {
        _min = "0" + _min;
      }
      _startTimeController.text =
      _hour + ":" + _min;
        },
        child:
        Container(
          margin: EdgeInsets.fromLTRB(
              ScreenUtil.getInstance().setWidth(0),
              ScreenUtil.getInstance().setWidth(20),
              ScreenUtil.getInstance().setWidth(10),
              0.0),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: DemoLocalizations.of(context).trans('start'),
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
                controller: _startTimeController,
                keyboardType: TextInputType.text,
                autofocus: false,
                enabled : false,
                style: _style,
                cursorColor: AppColors.colorBlue,
                decoration: new InputDecoration(
                    fillColor: AppColors.colorGrayEditFieldd,filled: true,
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: AppColors.colorBlue),
                        borderRadius: BorderRadius.all(new Radius.circular(10))),
                    enabledBorder:  OutlineInputBorder(
                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))
                    ),
                    disabledBorder:  OutlineInputBorder(
                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))
                    ),
                    focusedBorder:  OutlineInputBorder(
                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))
                    ),
                    hintText: DemoLocalizations.of(context).trans('select_start_time'),
                    hintStyle: _hintStyle,
                    prefixText: ' '),
              ),
            ],
          )

        ),
      );
  }


  Widget _endTime() {
    return
      InkWell(
        onTap:() async {
          FocusScope.of(context).unfocus();
          timeOfDayEnd = await Time().selectTime(context, timeOfDayEnd);
          String _hour = timeOfDayEnd.hour.toString();
          if (_hour.length == 1) {
            _hour = "0" + _hour;
          }
          String _min = timeOfDayEnd.minute.toString();
          if (_min.length == 1) {
            _min = "0" + _min;
          }
          _endTimeController.text =
              _hour + ":" + _min;
        },
        child:
        Container(
          margin: EdgeInsets.fromLTRB(
              ScreenUtil.getInstance().setWidth(10),
              ScreenUtil.getInstance().setWidth(20),
              ScreenUtil.getInstance().setWidth(0),
              0.0),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: DemoLocalizations.of(context).trans('end'),
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
                enabled : false,
                controller: _endTimeController,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                style: _style,
                cursorColor: AppColors.colorBlue,
                decoration: new InputDecoration(
                    fillColor: AppColors.colorGrayEditFieldd,filled: true,
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: AppColors.colorBlue),
                        borderRadius: BorderRadius.all(new Radius.circular(10))),
                    enabledBorder:  OutlineInputBorder(
                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))
                    ),
                    disabledBorder:  OutlineInputBorder(
                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))
                    ),
                    focusedBorder:  OutlineInputBorder(
                        borderSide:  BorderSide(color: AppColors.colorBlue, width: 0.0),
                        borderRadius: BorderRadius.all(new Radius.circular(10))
                    ),
                    hintText: DemoLocalizations.of(context).trans('select_end_time'),
                    hintStyle: _hintStyle,
                    prefixText: ' '),
              ),
            ],
          )

        ),
      );
  }


  Widget _buttonSession() {
    return
      Container(
        height: 52,
        margin: EdgeInsets.only(left: 30.0, right: 30.0,top: 28),
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          color: AppColors.colorBlue,
          child: Text(
            DemoLocalizations.of(context).trans('forgot_submit'),
              textScaleFactor: 1.0,
            style: GoogleFonts.openSans(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: ScreenUtil.getInstance().setWidth(15),
              color: AppColors.colorWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            _submit();
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: AppColors.colorBlue,
              )),
        ),
      );
  }

  Future<void> _submit() async {
   /* if(_sessionNameController.text.isEmpty){
      FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('session_name_enter'));
      return;
    }else*/ if(_activityTypeController.text.isEmpty){
      FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('activity_select'));
      return;
    }else if(_startDateController.text.isEmpty){
      FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('sel_end_date'));
      return;
    }/*else if(_endDateController.text.isEmpty){
      FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('sel_end_date'));
      return;
    }*/else if(_distanceController.text.isEmpty){
      FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('disctance_enter'));
      return;
    }else if(_startTimeController.text.isEmpty){
      FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('select_start_time'));
      return;
    }else if(_endTimeController.text.isEmpty){
      FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('select_end_time'));
      return;
    }/*else if(timeOfDayStart.hour > timeOfDayEnd.hour  *//*&& timeOfDayStart.minute > timeOfDayEnd.minute*//*){
      if(timeOfDayStart.minute < timeOfDayEnd.minute){
//        FlutterToast.showToastCenter('Form submitted..');
        _createSession();
        return;
      }else {
        FlutterToast.showToastCenter(
            DemoLocalizations.of(context).trans('time_error'));
        return;
      }
    }*/else {
//      FlutterToast.showToastCenter('Form submitted..');
      _createSession();
    }
  }

  Future<void> _createSession()async {
    _addDataBase();
  }


  Future<void> _addDataBase() async{
    if(_prefs.getString(PreferenceNames.timeInit) == null){
      _prefs.setString(PreferenceNames.timeInit,  DateTime.now().year.toString() + "-" + DateTime.now().month.toString()
          + "-" + DateTime.now().day.toString() + "-" + DateTime.now().hour.toString() +
          "-" + DateTime.now().minute.toString());
    }
    SessionData _sessionData = new SessionData();
    _sessionData.startTime = DateFormat('yyyy MM dd').format(DateTime(
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[0]),
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[1]),
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[2]),
    )) + " " + _startTimeController.text +":00";
    String va = _distanceController.text;
    double dd = double.parse(va)*1000;
    _sessionData.distance = dd.toString();
    _sessionData.activityType = transportValue;
    _sessionData.speed = '0';
    _sessionData.sessionType = store.state.addSessionList[_index].data.sessionData.sessionType?? "Manual";

    Data _data = new Data();
    _data.userId = _prefs.getString(PreferenceNames.token);
    _data.movementDateTime = DateTime.now().millisecondsSinceEpoch.toString();
    _data.sessionData = _sessionData;

    AddSession _session = new AddSession();
    _session.sessionId = DateTime.now().millisecondsSinceEpoch.toString()+_prefs.getString(PreferenceNames.token);
    _session.userId = _prefs.getString(PreferenceNames.token);
    _session.source = GetDeviceType.getDeviceType();
    _session.delete = delete;
    _sessionData.startTime = _startDateValue + " " + _startTimeController.text +":00";
    _session.createdOn = DateFormat('yyyy-MM-dd').format(DateTime(
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[0]),
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[1]),
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[2]),
    )) + " " + _startTimeController.text +":00";
    _session.updatedOn = _startDateValue + " " + _endTimeController.text+":00";
    _session.currentDay = DateFormat('yyyy-MM-dd').format(DateTime(
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[0]),
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[1]),
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[2]),
    ));
    _session.sessionYear = DateFormat('yyyy-MM').format(DateTime(
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[0]),
      int.parse(store.state.addSessionList[_index].createdOn.split(' ')[0].split(
          '-')[1]),
    ));
    _session.data = _data;
    _session.sessionName = _sessionNameController.text;

    print("index $_index");
    _database.reference().child(DataBaseConstants.sessionData).child(store.state.addSessionList[_index].key).update(_session.toJson());
    _session.key = store.state.addSessionList[_index].key;
    store.state.addSessionList[_index] = _session;
    await store.dispatch(SessionResponseListAction(store.state.addSessionList));
    AppDialogs().showAlertDialog(
        context, DemoLocalizations.of(context).trans('success'), DemoLocalizations.of(context).trans('session_added'),
        DemoLocalizations.of(context).trans('okay'), "", this);
  }


  void _dialogDelete(
      BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: AppColors.colorWhite,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          title:  Text(DemoLocalizations.of(context).trans('session_del')),
          content:  Text(DemoLocalizations.of(context).trans('session_del_really')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child:  Text(DemoLocalizations.of(context).trans('dialog_cancel')),
              onPressed: () {
               Navigator.pop(context);
              },
            ),
            FlatButton(
              child:  Text(DemoLocalizations.of(context).trans('dialog_ok')),
              onPressed: () {
                Navigator.pop(context);
//               _deleteSession();
              },
            ),
          ],
        );
      },
    );

    Future<void> _deleteSession() async {
      final FirebaseDatabase _database = FirebaseDatabase.instance;

      print("called1");
      print(store.state.userAppModal.userId);
//      _database.reference().child(DataBaseConstants.sessionData).remove().set(_session.toJson());
    }
  }


  @override
  void onNegativeClick() {
    // TODO: implement onNegativeClick
  }

  @override
  void onPositiveClick(BuildContext context) async{
    // TODO: implement onPositiveClick
     Navigator.pop(context);
  }
}


class _SessionListModel {
  final Store<AppState> store;
  final bool loader;
  final List<AddSession> sessionList;

  _SessionListModel(this.store, this.loader, this.sessionList);

  factory _SessionListModel.create(Store<AppState> store,
      BuildContext context) {
    return _SessionListModel(
        store, store.state.challengeLoaderAll, store.state.addSessionList);
  }
}
