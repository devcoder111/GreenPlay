import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/session_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_session_modal.dart';
import 'package:greenplayapp/redux/model/data_add_session.dart';
import 'package:greenplayapp/redux/model/data_session_share_modal.dart';
import 'package:greenplayapp/redux/model/session_data.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:greenplayapp/utils/views_common/OptionalDialogListener.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SessionViewPage extends StatefulWidget {
  @override
  _SessionViewPageState createState() => _SessionViewPageState();
}

class _SessionViewPageState extends State<SessionViewPage>  implements OptionalDialogListener{
  String activityType;
  Store<AppState> store;
  int _index;
  double greenHouse = 0.0;
  int calories = 0;
  int _weightForCalorie = 1;
  SharedPreferences _prefs;
  String time = "00:00";
  var distanceDisplay = 0.0;
  var speedDisplay = 0.0;
  var speedDisplayString = "0.0";

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  bool loader = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  var _styleBar = GoogleFonts.roboto(
    fontSize: ScreenUtil.getInstance().setWidth(17),
    color: AppColors.colorBlue,
    fontWeight: FontWeight.w500,
  );



  Future _calculateGreenHouse(Store<AppState> store) async{
    var distance = store.state.addSessionList[_index].data.sessionData.distance;
    String createdOn = store.state.addSessionList[_index].createdOn;
    String updatedOn = store.state.addSessionList[_index].updatedOn;
    _prefs = PrefsSingleton.prefs;
    print("create: $createdOn");
    print("updated: $updatedOn");
    DateTime dateUpdatedOn = DateTime(
      int.parse(updatedOn.split(' ')[0].split('-')[0]),
      int.parse(updatedOn.split(' ')[0].split('-')[1]),
      int.parse(updatedOn.split(' ')[0].split('-')[2]),
      int.parse(updatedOn.split(' ')[1].split(':')[0]),
      int.parse(updatedOn.split(' ')[1].split(':')[1]),
    );
    DateTime dateCreatedOn = DateTime(
      int.parse(createdOn.split(' ')[0].split('-')[0]),
      int.parse(createdOn.split(' ')[0].split('-')[1]),
      int.parse(createdOn.split(' ')[0].split('-')[2]),
      int.parse(createdOn.split(' ')[1].split(':')[0]),
      int.parse(createdOn.split(' ')[1].split(':')[1]),
    );
    if (_prefs.getString(PreferenceNames.weight) != '') {
      _weightForCalorie = int.parse(_prefs.getString(PreferenceNames.weight));
    }else if (_prefs.getString(PreferenceNames.gender) == null || _prefs.getString(PreferenceNames.gender) == "") {
      _weightForCalorie = Constants.ageConstant;
    }else if (_prefs.getString(PreferenceNames.gender) == 'male') {
      _weightForCalorie = Constants.ageMan;
    } else {
      _weightForCalorie = Constants.ageWoMan;
    }

    double valueOne = double.parse(distance)/1000 * Constants.aloneGES;
    if (activityType == DemoLocalizations.of(context).trans('rad') || activityType.toLowerCase() == "Remote work".toLowerCase()
        || activityType.toLowerCase() == "Travail à distance".toLowerCase()) {
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.remoteWorkGES;
    }
    else if (activityType == DemoLocalizations.of(context).trans('trans') || activityType.toLowerCase() == "Autobus".toLowerCase() ||
    activityType.toLowerCase() == "Transit bus".toLowerCase()) {
      calories = (Constants.transitBusCalorie * _weightForCalorie *
              (dateUpdatedOn.difference(dateCreatedOn).inMinutes / 60)).toInt();
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.transitBusGES;
    }
    else if (activityType.toLowerCase() == 'bike' || activityType.toLowerCase()== 'Vélo'.toLowerCase() ||
        activityType == DemoLocalizations.of(context).trans('bike')) {
      calories = (Constants.bikeCalorie * _weightForCalorie *
              (dateUpdatedOn.difference(dateCreatedOn).inMinutes / 60)).
          toInt();
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.bikeGES;
    }
    else if (activityType == DemoLocalizations.of(context).trans('carpool') || activityType.toLowerCase() == "Carpooling".toLowerCase() ||
    activityType.toLowerCase() == "Covoiturage".toLowerCase()) {
      calories = (Constants.carPoolingCalorie * _weightForCalorie *
          (dateUpdatedOn.difference(dateCreatedOn).inMinutes / 60)).
          toInt();
      greenHouse  = valueOne - double.parse(distance)/1000 * Constants.carPoolingGES;
    }
    else if (activityType == DemoLocalizations.of(context).trans('train') ||
        activityType.toLowerCase() == "Train".toLowerCase() || activityType.toLowerCase() == "Train".toLowerCase()) {
      calories = (Constants.trainCalories * _weightForCalorie *
              (dateUpdatedOn.difference(dateCreatedOn).inMinutes / 60)).toInt();
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.trainGES;
    }
    else if (activityType == DemoLocalizations.of(context).trans('walk')  ||
        activityType.toLowerCase() == 'walk' || activityType.toLowerCase() == "Walking".toLowerCase()
        || activityType.toLowerCase() == "Marche".toLowerCase()) {
      calories = (Constants.walkCalories * _weightForCalorie *
              (dateUpdatedOn.difference(dateCreatedOn).inMinutes / 60)).toInt();
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.walkGES;
    }
    else if (activityType == DemoLocalizations.of(context).trans('electric') ||
        activityType.toLowerCase() == "Carpooling electric car".toLowerCase() ||
    activityType.toLowerCase() == "Covoiturage en voiture électrique".toLowerCase()) {
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.carPoolElectricCarGES;
    }
    else if (activityType == DemoLocalizations.of(context).trans('metro') || activityType.toLowerCase() == "Metro".toLowerCase() ||
    activityType.toLowerCase() == "Métro".toLowerCase()) {
      calories = (Constants.metroCalorie * _weightForCalorie *
              (dateUpdatedOn.difference(dateCreatedOn).inMinutes / 60)).
          toInt();
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.metroGES;
    }
    else if (activityType== DemoLocalizations.of(context).trans('electric_car') ||
        activityType.toLowerCase() == "Electric car".toLowerCase() ||
    activityType.toLowerCase() == "Voiture électrique".toLowerCase()) {
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.electricCarGES;
    }
    else if (activityType== DemoLocalizations.of(context).trans('run') ||
        activityType.toLowerCase() == "Running".toLowerCase() || activityType.toLowerCase() == "Course".toLowerCase()) {
      calories = (Constants.runningCalorie * _weightForCalorie *
          (dateUpdatedOn.difference(dateCreatedOn).inMinutes / 60))
          .toInt();
//      print(valueOne.toString());
      greenHouse = valueOne - double.parse(distance)/1000 * Constants.runningGES;
    }
    int timeLoop =   dateUpdatedOn.difference(dateCreatedOn).inMinutes;
    var difference = dateUpdatedOn.difference(dateCreatedOn);

    time = GetTime.formatDuration(difference).split(":")[0] +":" + GetTime.formatDuration(difference).split(":")[1];
    distanceDisplay = (double.parse(distance) /
        1000);
    speedDisplay = timeLoop/distanceDisplay;
    speedDisplayString = speedDisplay.toStringAsFixed(2).replaceAll(".", ":");
    print(greenHouse);

    SessionViewModal modal = new SessionViewModal();
    modal.greenhouse= greenHouse;
    modal.calories= calories;

    if(this.mounted){
      setState(() {

      });
    }
  }





  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, _SessionListModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _SessionListModel.create(store, context);
        },
        onInit: (store) async {
          _index = ModalRoute.of(context).settings.arguments;
          activityType = store.state.addSessionList[_index].data.sessionData.activityType;
          _calculateGreenHouse(store);
        },

        builder: (BuildContext context, _SessionListModel data) {
          return Scaffold(
      backgroundColor: AppColors.colorWhite,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Keys.navKey.currentState
                      .pushNamed(Routes.editSessionScreen, arguments: _index);
                },
                child: Icon(Icons.edit, color: AppColors.colorWhite,),
                backgroundColor: AppColors.colorBlue,
              ),
      appBar:  AppBar(
          backgroundColor: AppColors.colorBgGray,
          elevation: 0.0,
          title: Container(
            child: Text(
              DemoLocalizations.of(context).trans('session'),
              style: _styleBar,textScaleFactor: 1.0,
              textAlign: TextAlign.center,
            ),
          ),
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: AppColors.colorBlue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        actions: <Widget>[
          InkWell(
            onTap: () async{
              AppDialogs().showAlertDialog(
                  context, DemoLocalizations.of(context).trans('delete_header'),
                  DemoLocalizations.of(context).trans('delete_content'),
                  DemoLocalizations.of(context).trans('okay'),  DemoLocalizations.of(context).trans('delete_cancel'), this);

             /* print("jj");
              var response = await FlutterShareMe()
                  .shareToFacebook(
                  url: "test", msg: "EM Radio");
              if (response == 'success') {
                print('navigate success');
              }*/
            },
            child:
            Container(
              padding: EdgeInsets.all(10),
              child:
              Icon(Icons.delete,color: AppColors.colorBlue,),
            )
          )
        ],
      ),
      body:
          loader ?
          Container(
            color: Colors.transparent,
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ):
     SingleChildScrollView(
       child:
      Stack(
        children: <Widget>[
          Container(
            color: AppColors.colorWhite,
            child:
            Column(
              children: <Widget>[
                Container(
                  color: AppColors.colorBgGray,
                  height: ScreenUtil.getInstance().setHeight(300),
                  child:
                  Column(
                    children: <Widget>[
                      _sessionImage(data),
                      _sessionType(data),
                      _sessionDistance(data),
                      _sessionSpeed(data),
                    ],
                  ),
                ),

                Container(
                  height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.only(top: 20,left: 10),
                  child:
                  Column(
                    children: <Widget>[
                      _sessionStart(data),
                      SizedBox(
                          height: ScreenUtil.getInstance().setHeight(20)
                      ),
                      _sessionTotTime(data),
                      SizedBox(
                          height: ScreenUtil.getInstance().setHeight(20)
                      ),
                      _greenHouse(data),
                      SizedBox(
                          height: ScreenUtil.getInstance().setHeight(20)
                      ),
                      _calories(data)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      )
     )
    );
  });
  }


  /*Top session image......*/
  Widget _sessionImage(_SessionListModel data) {
    return
      GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
          },
          child:
          Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child:
            Center(
              child:
              Stack(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
//                  child: Icon(CustomIcons.option, size: 20,),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.colorBlue),
                  ),
                  data.sessionList[_index].data.sessionData.activityType == "Course" ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Running".toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Run".toLowerCase()  ?
                  Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child:
                        SvgPicture.asset(
                          'asset/runningruler.svg',
                          height: 20,
                          width: 20,
                          allowDrawingOutsideViewBox: true,
                          color: AppColors.colorWhite,
                        ),
                      )) :

                  data.sessionList[_index].data.sessionData.activityType.toLowerCase().contains(
                      "bicycle".toLowerCase()) ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase().contains(
                          "bike".toLowerCase())||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase().contains(
                          "Vélo".toLowerCase()) ?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/bikeruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType.toString().toLowerCase() == "Walking".toLowerCase() ||
              data.sessionList[_index].data.sessionData.activityType.toString().toLowerCase() == "Marche".toLowerCase()
                      ?
                  Positioned.fill(
                      child:
                      Align(
                        alignment: Alignment.center,
                        child:
                        SvgPicture.asset(
                          'asset/walkruler.svg',
                          height: 20,
                          width: 20,
                          allowDrawingOutsideViewBox: true,
                          color: AppColors.colorWhite,
                        ),
                      )
                  )
                      :

                  data.sessionList[_index].data.sessionData.activityType.toString().toLowerCase() == "Electric car".toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toString().toLowerCase() == "Voiture électrique".toLowerCase()?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child:
                          SvgPicture.asset(
                            'asset/electriccarruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Driving alone".toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Conduire seul".toLowerCase()
                      ?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/drivingaloneruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Carpooling".toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Covoiturage".toLowerCase() ?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/carpoolingruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType .toLowerCase()== "Motorcycling".toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Moto".toLowerCase() ?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/motorcyclingruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType.toLowerCase() ==
                      'Transit bus'.toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase()
                           == 'Autobus'.toLowerCase() ?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/transitbusruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "In vehicle".toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "En véhicule".toLowerCase()
                      ?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/vehicleruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType.toLowerCase() ==
                      'Remote work'.toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Travail à distance".toLowerCase()?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/remoteworkruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Running".toLowerCase() ||
                      data.sessionList[_index].data.sessionData.activityType.toLowerCase() == "Course".toLowerCase()?
                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/runningruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))) :

                  Positioned.fill(
                      child:
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/unknownruler.svg',
                            height: 20,
                            width: 20,
                            allowDrawingOutsideViewBox: true,
                            color: AppColors.colorWhite,
                          ))),
                ],
              ),
            )
          ));
  }


  Widget _sessionType(_SessionListModel data){
    return
      Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
        child:
       Center(
         child:
         Text(
           data.sessionList[_index].data.sessionData.sessionType.toLowerCase() == "automatic" ?
           DemoLocalizations.of(context).trans('auto') :
           DemoLocalizations.of(context).trans('manual') ,
           textAlign: TextAlign.center,
           overflow: TextOverflow.ellipsis,
           softWrap: false,textScaleFactor: 1.0,
           style: GoogleFonts.openSans(
             fontSize: ScreenUtil.getInstance().setWidth(17),
             color: AppColors.colorBlack,
             fontWeight: FontWeight.w600,
           ),
         ),
       )
      );
  }


  Widget _sessionDistance(_SessionListModel data){
    return
      Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: Text(
              (double.parse(data.sessionList[_index].data.sessionData.distance) /
                  1000)
                  .toStringAsFixed(2) +
                  " km" ??
                  '0' + " km",
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(22),
                color: AppColors.colorBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
            child: Text(
              DemoLocalizations.of(context).trans('dist_edit'),
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(17),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      );
  }


  Widget _sessionSpeed(_SessionListModel data){
    return
      Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: Text(speedDisplayString +
                    " /km" ??
                  '0' + " /km",
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(22),
                color: AppColors.colorBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
            child: Text(
              DemoLocalizations.of(context).trans('speed'),
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(17),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      );
  }


  Widget _sessionStart(_SessionListModel data){
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child:
            Icon(Icons.watch_later, color: AppColors.colorBgEditField,
                size: ScreenUtil.getInstance().setHeight(20)),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(
                  DemoLocalizations.of(context).trans('session_start'),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(14),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(
                  DateFormat('dd MMM yyyy').format(DateTime(
                    int.parse(data.sessionList[_index].createdOn.split(' ')[0].split(
                        '-')[0]),
                    int.parse(data.sessionList[_index].createdOn.split(' ')[0].split(
                        '-')[1]),
                    int.parse(data.sessionList[_index].createdOn.split(' ')[0].split(
                        '-')[2]),
                  )) +" " + DemoLocalizations.of(context).trans('at')  + " " +
                      data.sessionList[_index].createdOn.split(' ')[1].split(
                          ":")[0] +
                      ":" +
                      data.sessionList[_index].createdOn.split(' ')[1].split(":")[1] ,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(16),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        ],
      );
  }


  Widget _sessionTotTime(_SessionListModel data){
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child:
            Icon(Icons.watch_later, color: AppColors.colorBgEditField,
                size: ScreenUtil.getInstance().setHeight(20)),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(
                  DemoLocalizations.of(context).trans('tot_time'),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(14),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(time + " (hh:mm)",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(16),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        ],
      );
  }



  //greenhouse savings
  Widget _greenHouse(_SessionListModel data){
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 3),
            child:
            SvgPicture.asset(
              'asset/barchart.svg',
              height: ScreenUtil.getInstance().setHeight(16),
              width: ScreenUtil.getInstance().setWidth(16),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(7, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(
                  DemoLocalizations.of(context).trans('gaze'),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(14),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(7, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(
                 greenHouse.toStringAsFixed(2) + " Kg",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(16),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        ],
      );
  }


  //calories calculations
  Widget _calories(_SessionListModel data){
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 3),
            child:
            SvgPicture.asset(
              'asset/barchart.svg',
              height: ScreenUtil.getInstance().setHeight(16),
              width: ScreenUtil.getInstance().setWidth(16),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(7, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(
                  DemoLocalizations.of(context).trans('calories'),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(14),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(7, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
                child: Text(
                 calories.toString(),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(16),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        ],
      );
  }

  @override
  void onNegativeClick() {
    // TODO: implement onNegativeClick
  }

  @override
  void onPositiveClick(BuildContext context) async {
    // TODO: implement onPositiveClick
    Navigator.pop(context);
    setState(() {
      loader = true;
    });
    await _deleteSession();

  }

  Future<void> _deleteSession() async{
    SessionData _sessionData = new SessionData();
    _sessionData.startTime = store.state.addSessionList[_index].data.sessionData.sessionType;
    _sessionData.distance = store.state.addSessionList[_index].data.sessionData.distance;
    _sessionData.activityType = store.state.addSessionList[_index].data.sessionData.activityType;
    _sessionData.speed = store.state.addSessionList[_index].data.sessionData.speed;
    _sessionData.sessionType = store.state.addSessionList[_index].data.sessionData.sessionType?? "Manual";

    Data _data = new Data();
    _data.userId = _prefs.getString(PreferenceNames.token);
    _data.movementDateTime = store.state.addSessionList[_index].data.movementDateTime;
    _data.sessionData = _sessionData;

    AddSession _session = new AddSession();
    _session.sessionId = store.state.addSessionList[_index].sessionId;
    _session.userId = _prefs.getString(PreferenceNames.token);
    _session.source = GetDeviceType.getDeviceType();
    _session.delete = "1";
    _sessionData.startTime = store.state.addSessionList[_index].data.sessionData.startTime;
    _session.createdOn = store.state.addSessionList[_index].createdOn;
    _session.updatedOn = store.state.addSessionList[_index].updatedOn;
    _session.currentDay = store.state.addSessionList[_index].currentDay;
    _session.sessionYear = store.state.addSessionList[_index].sessionYear;
    _session.data = _data;
    _session.sessionName = store.state.addSessionList[_index].sessionName;

    print("index $_index");
    await _database.reference().child(DataBaseConstants.sessionData).child(store.state.addSessionList[_index].key).update(_session.toJson());
    _session.key = store.state.addSessionList[_index].key;
    store.state.addSessionList.removeAt(_index);
    await store.dispatch(SessionResponseListAction(store.state.addSessionList));
    setState(() {
      loader = false;
    });
    Navigator.pop(context);
  }
}


class _SessionListModel {
  final Store<AppState> store;
  final bool loader;
  final List<AddSession> sessionList;
  final SessionViewModal sessionViewModal;

  _SessionListModel(this.store, this.loader, this.sessionList, this.sessionViewModal);

  factory _SessionListModel.create(Store<AppState> store,
      BuildContext context) {
    return _SessionListModel(
        store, store.state.challengeLoaderAll, store.state.addSessionList, store.state.sessionDataView);
  }
}