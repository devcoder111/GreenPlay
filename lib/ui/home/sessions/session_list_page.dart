import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/session_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_challenge_data_modal.dart';
import 'package:greenplayapp/redux/model/add_session_modal.dart';
import 'package:greenplayapp/redux/model/dashboard_activity_modal.dart';
import 'package:greenplayapp/redux/model/session_data.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:greenplayapp/redux/model/data_add_session.dart' as prefix1;
import 'package:greenplayapp/redux/model/challenge_data.dart' as prefixchallenge;
import 'package:shared_preferences/shared_preferences.dart';

class SessionListScreen extends StatefulWidget {
  @override
  _SessionListScreenState createState() => new _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  int tabSelected = 0;
  int _indexChallenge = 0;
  String challengeName = "No Challenge";
  DateFormat dateFormat = DateFormat("yyyy-MM-dd kk:mm:a");
  List<ChallengeData> challengeData = new List();
  Map<dynamic, dynamic> map;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  var _styleTab = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setSp(12),
    color: AppColors.colorBlack,
    fontWeight: FontWeight.w500,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  var refreshkey = GlobalKey<RefreshIndicatorState>();

  Store<AppState> store;
  bool loader = true;
  String _sessionType;
  SharedPreferences _prefs;

  //initialize shared preference here.......
  Future initPref(Store<AppState> store) async {
    _prefs = PrefsSingleton.prefs;
    print(_prefs.getString(PreferenceNames.timeInit));

    if (_prefs.getString(PreferenceNames.isSession) == null ||  _prefs.getString(PreferenceNames.isSession) == "") {
      _sessionType = "Automatic";
    }else{
      _sessionType = "Automatic";
    }
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)
      ..init(context);
    return StoreConnector<AppState, _SessionListModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _SessionListModel.create(store, context);
        },
        onDidChange: (_SessionListModel) {
          if (this.mounted) {
            setState(() {
              loader = false;
            });
          }
        },
        onInit: (store) async {
          print("called");
          await store.dispatch(SessionAction());
          await initPref(store);
          _loadMyChallenges(store);
        },

        builder: (BuildContext context, _SessionListModel data) {
          return Scaffold(
              backgroundColor: AppColors.colorBgGray,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Keys.navKey.currentState
                      .pushNamed(Routes.addSessionScreen);
                },
                child: Icon(Icons.add, color: AppColors.colorWhite,),
                backgroundColor: AppColors.colorBlue,
              ),
              body: loader
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
                  :
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _tabTotalStats(), _tabChallenge()],
                  ),
                  tabSelected == 1 ? _challengeNameHeader() : Container(),

                  SizedBox(height: 10),
                  data.sessionList.length < 1 ?
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child :
                      Align(
                        child:
                        Text(
                            DemoLocalizations.of(context).trans('no_session'),
                            style: GoogleFonts.poppins(
                              textStyle: Theme.of(context).textTheme.display1,
                              fontSize: ScreenUtil.getInstance().setWidth(15),
                              color: AppColors.colorBlueLanding,
                              fontWeight: FontWeight.w400,
                            ),
                            textScaleFactor: 1.0
                        ),
                        alignment: Alignment.center,
                      ))
                      :Expanded(
                    child :
                    RefreshIndicator(
                      key: refreshkey,
                      child: ListView.builder(
                        itemCount: data.sessionList?.length,
                        itemBuilder: (context, i) => _card(data, i),
                      ),
                      onRefresh: _getData, //refreshlist function is called when user pull down to refresh
                    ),
                  )
                ],
              )
          );
        });
  }


  Future<void> _getData() async {
    refreshkey.currentState?.show(
        atTop:
        true);
    await store.dispatch(SessionAction());
  }


  Widget _tabTotalStats() {
    return Expanded(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(10)),
              height: ScreenUtil.getInstance().setHeight(60),
              alignment: Alignment.center,
//            color: Colors.transparent,
              child: ButtonTheme(
                  minWidth: 200.0,
                  height: ScreenUtil.getInstance().setHeight(60),
                  child:
                  RaisedButton(
                    elevation: 0,splashColor: AppColors.colorBgGray,
                    focusColor: AppColors.colorBgGray,hoverColor: AppColors.colorBgGray,
                    highlightColor: AppColors.colorBgGray,disabledColor: AppColors.colorBgGray,
                    color: AppColors.colorBgGray,
                    child: Text(
                      DemoLocalizations.of(context).trans('stats'),
                      style: _styleTab, textAlign: TextAlign.center,maxLines: 4,),
                    onPressed: () async{
                      setState(() {
                        tabSelected = 0;
                      });
                      await store.dispatch(SessionAction());
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                        side: BorderSide(
                            color: tabSelected == 0
                                ? AppColors.colorBgGray
                                : AppColors.colorBgGray,
                            width: 5.0)),
                  )),
            ),
            Container(
              height: 5,
              margin: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width,
              color: tabSelected == 0 ? AppColors.colorBlue : AppColors.colorBgGray,
            )
          ],
        ));
  }


  Widget _tabChallenge() {
    return Expanded(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(10)),
              height: ScreenUtil.getInstance().setHeight(60),
              alignment: Alignment.center,
//            color: Colors.transparent,
              child: ButtonTheme(
                  minWidth: 200.0,
                  height: ScreenUtil.getInstance().setHeight(60),
                  child:
                  RaisedButton(
                    elevation: 0,splashColor: AppColors.colorBgGray,
                    focusColor: AppColors.colorBgGray,hoverColor: AppColors.colorBgGray,
                    highlightColor: AppColors.colorBgGray,disabledColor: AppColors.colorBgGray,
                    color: AppColors.colorBgGray,
                    child: Text(
                      DemoLocalizations.of(context).trans('all_challenge'),
                      style: _styleTab, textAlign: TextAlign.center,maxLines: 4,),
                    onPressed: () async{
                      setState(() {
                        tabSelected = 1;
                      });
                      await getData(store);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                        side: BorderSide(
                            color: tabSelected == 1
                                ? AppColors.colorBgGray
                                : AppColors.colorBgGray,
                            width: 5.0)),
                  )),
            ),
            Container(
              height: 5,
              margin: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width,
              color: tabSelected == 1 ? AppColors.colorBlue : AppColors.colorBgGray,
            )
          ],
        ));
  }


  /*
  * tab with all name of challenges with next/previous*/
  Widget _challengeNameHeader() {
    return Container(
      color: AppColors.colorWhite,
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      height: 50,
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () async {
              if (challengeData.length > 0) {
                if (_indexChallenge == 0) {
                  setState(() {
                    _indexChallenge = challengeData.length - 1;
                    challengeName =
                        challengeData[_indexChallenge].challengeName;
                  });
                } else {
                  setState(() {
                    _indexChallenge = _indexChallenge - 1;
                    challengeName =
                        challengeData[_indexChallenge].challengeName;
                  });
                }
                await _challengeData().then(( status) async{

                });
              } else {
                FlutterToast.showToastCenter(
                    DemoLocalizations.of(context).trans('err_no_challenge'));
              }
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.colorGray,
            ),
          ),

          Spacer(),

          Container(
            width: ScreenUtil.getInstance().setWidth(120),
            child: Text(
                challengeName,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setSp(17),
                  color: AppColors.colorBlack,
                  fontWeight: FontWeight.w700,
                ),textScaleFactor: 1.0
            ),
          ),

          Spacer(),

          InkWell(
            onTap: () async {
              if (challengeData.length > 0) {
                if (_indexChallenge == challengeData.length - 1) {
                  setState(() {
                    _indexChallenge = 0;
                    challengeName =
                        challengeData[_indexChallenge].challengeName;
                  });
                } else {
                  setState(() {
                    _indexChallenge = _indexChallenge + 1;
                    challengeName =
                        challengeData[_indexChallenge].challengeName;
                  });
                }
                await _challengeData().then(( status) async{

                });
              } else {
                FlutterToast.showToastCenter(
                    DemoLocalizations.of(context).trans('err_no_challenge'));
              }
            },
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.colorGray,
            ),
          )
        ],
      ),
    );
  }


  Widget _card(_SessionListModel data, int index) {
    return
      InkWell(
        onTap: (){
          Keys.navKey.currentState
              .pushNamed(Routes.viewSessionScreen, arguments: index);
        },
        child:
        Container(
            margin: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(5),
                right: ScreenUtil.getInstance().setHeight(5)),
            child:
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child:
                  Align(
                      alignment: Alignment.bottomLeft,
                      child :
                      Text(
                        headerDate(data.sessionList[index].createdOn),
                        style: GoogleFonts.openSans(
                          fontSize: ScreenUtil.getInstance().setWidth(14),
                          color: AppColors.colorBlack,
                          fontWeight: FontWeight.w600,
                        ), textAlign: TextAlign.center,maxLines: 1,)
                  ),
                ),

                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: AppColors.colorWhite),
                    ),
                    elevation: 0.0,
                    color: AppColors.colorWhite,
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        _sessionImage(data, index),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10),
                            _sessionName(data, index),
                            Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 10),
                                    _startDateSession(data, index),
                                    _sessionTypeWidget(data, index),
                                    SizedBox(
                                      height: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.01,
                                    ),
                                    data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('run') ||
                                        data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Course".toLowerCase() ||
                                        data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Running".toLowerCase() ?
                                    _paceEmptySession(data, index) :
                                    data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Vélo".toLowerCase() ||
                                        data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Bike".toLowerCase()
                                        || data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('bike') ?
                                    _paceEmptySession(data, index) :
                                    data.sessionList[index].data.sessionData.activityType.toString()== DemoLocalizations.of(context).trans('walk')||
                                        data.sessionList[index].data.sessionData.activityType.toString().toLowerCase()== "Marche".toLowerCase()||
                                        data.sessionList[index].data.sessionData.activityType.toString().toLowerCase()== "Walking".toLowerCase() ?
                                    _paceEmptySession(data, index) : Container(),
                                    SizedBox(height: 10)
                                  ],
                                ),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 10),
                                    _distanceWidget(data, index),
                                    _timeTotal(data, index),
                                    SizedBox(
                                      height: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.01,
                                    ),
                                    data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('run') ||
                                        data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Course".toLowerCase() ||
                                        data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Running".toLowerCase() ?
                                    _paceSession(data, index) :
                                    data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Vélo".toLowerCase() ||
                                        data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Bike".toLowerCase()
                                        || data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('bike') ?
                                    _paceSession(data, index) :
                                    data.sessionList[index].data.sessionData.activityType.toString()== DemoLocalizations.of(context).trans('walk')||
                                        data.sessionList[index].data.sessionData.activityType.toString().toLowerCase()== "Marche".toLowerCase()||
                                        data.sessionList[index].data.sessionData.activityType.toString().toLowerCase()== "Walking".toLowerCase() ?
                                    _paceSession(data, index) : Container(),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ],
                            )
                          ],
                        )


                      ],
                    )
                ),
              ],
            )
        ),
      );
  }


  Widget _sessionImage(_SessionListModel data, int index) {
    return
      Stack(
        children: <Widget>[
          new Container(
            margin: EdgeInsets.only(top: 5,bottom: 5),
            height: ScreenUtil.getInstance().setWidth(70),
            width: ScreenUtil.getInstance().setWidth(70),
            color: Colors.transparent,
            child: new Container(
              decoration: new BoxDecoration(
                  color: AppColors.colorWhiteLight,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(0.0),
                    topRight: const Radius.circular(0.0),
                    bottomLeft: const Radius.circular(0.0),
                    bottomRight: const Radius.circular(0.0),
                  )
              ),
            ),
          ),

          data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('run') ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Course".toLowerCase() ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Running".toLowerCase() ?
          Positioned.fill(
              child: Align(
                  alignment: Alignment.center,
                  child:
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child:
                    SvgPicture.asset(
                      'asset/runningruler.svg',
                      height: 20,
                      width: 20,
                      allowDrawingOutsideViewBox: true,
                      color: AppColors.colorBlue,
                    ),
                  )
              )) :

          data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Vélo".toLowerCase() ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Bike".toLowerCase()
              || data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('bike') ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: SvgPicture.asset(
                        'asset/bikeruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      )))) :

          data.sessionList[index].data.sessionData.activityType.toString()== DemoLocalizations.of(context).trans('walk')||
              data.sessionList[index].data.sessionData.activityType.toString().toLowerCase()== "Marche".toLowerCase()||
              data.sessionList[index].data.sessionData.activityType.toString().toLowerCase()== "Walking".toLowerCase()
              ?
          Positioned.fill(
              child:
              Align(
                alignment: Alignment.center,
                child:
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child:SvgPicture.asset(
                      'asset/walkruler.svg',
                      height: 20,
                      width: 20,
                      allowDrawingOutsideViewBox: true,
                      color: AppColors.colorBlue,
                    )),
              )
          ) :

          data.sessionList[index].data.sessionData.activityType.toString() == DemoLocalizations.of(context).trans('electric_car')||
              data.sessionList[index].data.sessionData.activityType.toString().toLowerCase() == "Voiture électrique".toLowerCase()||
              data.sessionList[index].data.sessionData.activityType.toString().toLowerCase() == "Electric car".toLowerCase() ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child:SvgPicture.asset(
                        'asset/electriccarruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      )))) :

          data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('drive')||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Conduire seul".toLowerCase()||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Driving alone".toLowerCase() ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:  Container(
                      margin: EdgeInsets.only(top: 10),
                      child:SvgPicture.asset(
                        'asset/drivingaloneruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      )))) :

          data.sessionList[index].data.sessionData.activityType.toString() == DemoLocalizations.of(context).trans('carpool') ||
              data.sessionList[index].data.sessionData.activityType.toString().toLowerCase() == "Carpooling".toLowerCase()||
              data.sessionList[index].data.sessionData.activityType.toString().toLowerCase() == "Covoiturage".toLowerCase() ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: SvgPicture.asset(
                        'asset/carpoolingruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      )))) :

          data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('motor') ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Motorcycling".toLowerCase() ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Moto".toLowerCase() ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:  Container(
                      margin: EdgeInsets.only(top: 10),
                      child:SvgPicture.asset(
                        'asset/motorcyclingruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      )))) :

          data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('trans')||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Transit bus".toLowerCase()||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Autobus".toLowerCase() ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:  Container(
                      margin: EdgeInsets.only(top: 10),
                      child:SvgPicture.asset(
                        'asset/transitbusruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      )))) :

          data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('veh') ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "En véhicule".toLowerCase() ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "In vehicle".toLowerCase()  ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:  Container(
                      margin: EdgeInsets.only(top: 10),
                      child:SvgPicture.asset(
                        'asset/vehicleruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      ))) ):

          data.sessionList[index].data.sessionData.activityType == DemoLocalizations.of(context).trans('rad') ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Travail à distance".toLowerCase() ||
              data.sessionList[index].data.sessionData.activityType.toLowerCase() == "Remote work".toLowerCase()  ?
          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:  Container(
                      margin: EdgeInsets.only(top: 10),
                      child:SvgPicture.asset(
                        'asset/remoteworkruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      ))) ) :

          Positioned.fill(
              child:
              Align(
                  alignment: Alignment.center,
                  child:  Container(
                      margin: EdgeInsets.only(top: 10),
                      child:SvgPicture.asset(
                        'asset/unknownruler.svg',
                        height: 20,
                        width: 20,
                        allowDrawingOutsideViewBox: true,
                        color: AppColors.colorBlue,
                      )))),
        ],
      );
  }

  Widget _sessionTypeWidget(_SessionListModel data, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[

        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 20, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
            child: Text(
              data.sessionList[index].data.sessionData.sessionType.toLowerCase() == "automatic" ?
              DemoLocalizations.of(context).trans('auto') :
              DemoLocalizations.of(context).trans('manual') ,
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(14),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _sessionName(_SessionListModel data, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(100),
            child: Text(
              data.sessionList[index].sessionName == "" ?
              SessionName.getSessionName(data.sessionList[index].updatedOn,
                  data.sessionList[index].data.sessionData.activityType, context)
                  : data.sessionList[index].sessionName,
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(14),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _distanceWidget(_SessionListModel data, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child:
          Container(
              margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
              width: ScreenUtil.getInstance().setWidth(90),
              child: Expanded(
                child:
                Text(
                  (double.parse(data.sessionList[index].data.sessionData.distance) /
                      1000)
                      .toStringAsFixed(2) +
                      " km" ??
                      '0' + " km",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(14),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
          ),
        ),

      ],
    );
  }

  Widget _startDateSession(_SessionListModel data, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child:
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
            child: Text(
              todayDate(data.sessionList[index].createdOn),
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(14),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

      ],
    );
  }

  String headerDate(String time) {
    DateTime date = new DateTime(int.parse(time.split(' ')[0].split(
        '-')[0]), int.parse(time.split(' ')[0].split(
        '-')[1]), int.parse(time.split(' ')[0].split(
        '-')[2]), int.parse(time.split(' ')[1].split(
        ':')[0]),int.parse(time.split(' ')[1].split(
        ':')[1]));
    String formattedTime = DateFormat('MMMM d').format(date);
    return formattedTime;
  }

  String todayDate(String time) {
    DateTime date = new DateTime(int.parse(time.split(' ')[0].split(
        '-')[0]), int.parse(time.split(' ')[0].split(
        '-')[1]), int.parse(time.split(' ')[0].split(
        '-')[2]), int.parse(time.split(' ')[1].split(
        ':')[0]),int.parse(time.split(' ')[1].split(
        ':')[1]));
    String formattedTime = DateFormat('kk:mm a').format(date);
    return formattedTime;
  }

  Widget _timeTotal(_SessionListModel data, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
            width: ScreenUtil.getInstance().setWidth(100),
            child:
            Expanded(
                child:
                Text(
                  GetTime.formatDuration(DateTime(
                    int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[0]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[1]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[2]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[1].split(':')[0]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[1].split(':')[1]),
                  ).difference(DateTime(
                    int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[0]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[1]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[2]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[1].split(':')[0]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[1].split(':')[1]),
                  ))).split(":")[0] +":"
                      + GetTime.formatDuration(DateTime(
                    int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[0]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[1]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[2]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[1].split(':')[0]),
                    int.parse(data.sessionList[index].updatedOn.split(' ')[1].split(':')[1]),
                  ).difference(DateTime(
                    int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[0]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[1]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[2]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[1].split(':')[0]),
                    int.parse(data.sessionList[index].createdOn.split(' ')[1].split(':')[1]),
                  ))).split(":")[1]  + " (hh:mm)",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,textScaleFactor: 1.0,
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil.getInstance().setWidth(14),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w400,
                  ),
                )
            ),
          ),
        ),

      ],
    );
  }

  Widget _paceSession(_SessionListModel data, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[


        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
            child: Text(
              ( DateTime(
                int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[0]),
                int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[1]),
                int.parse(data.sessionList[index].updatedOn.split(' ')[0].split('-')[2]),
                int.parse(data.sessionList[index].updatedOn.split(' ')[1].split(':')[0]),
                int.parse(data.sessionList[index].updatedOn.split(' ')[1].split(':')[1]),
              ).difference(DateTime(
                int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[0]),
                int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[1]),
                int.parse(data.sessionList[index].createdOn.split(' ')[0].split('-')[2]),
                int.parse(data.sessionList[index].createdOn.split(' ')[1].split(':')[0]),
                int.parse(data.sessionList[index].createdOn.split(' ')[1].split(':')[1]),
              )).inMinutes/(double.parse(data.sessionList[index].data.sessionData.distance) /
                  1000)).toStringAsFixed(2).replaceAll(".", ":") +
                  " /km" ??
                  '0' + " /km",
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(14),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _paceEmptySession(_SessionListModel data, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
            child: Text(
              "",
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(14),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//            width: ScreenUtil.getInstance().setWidth(220),
            child: Text(
              "",
              overflow: TextOverflow.ellipsis,
              softWrap: false,textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(14),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }


  /*
  * on challenge selected*/
  Future _loadMyChallenges(Store<AppState> store) async {
    challengeData.clear();
    _indexChallenge = 0;

    _database
        .reference()
        .child(DataBaseConstants.userChallenges)
        .orderByChild("userId")
        .equalTo(store.state.userAppModal.userId)
        .once()
        .then((snapshot) async {

      if (snapshot.value != null) {
        Map<dynamic, dynamic> map = snapshot.value;
        List<dynamic> userData = map.values.toList()[0]["challenges"];

        DateTime _currentDateTime = new DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);

        for (int i = 0; i < userData.length; i++) {
          var challengeStartDate = userData[i]['StartDate'];
          var challengeEndDate = userData[i]['EndDate'];

          DateTime _startDateTime = new DateTime(
              int.parse(challengeStartDate.split('-')[0]),
              int.parse(challengeStartDate.split('-')[1]),
              int.parse(challengeStartDate.split('-')[2]));
          DateTime _endDateTime = new DateTime(
              int.parse(challengeEndDate.split('-')[0]),
              int.parse(challengeEndDate.split('-')[1]),
              int.parse(challengeEndDate.split('-')[2]));

          ChallengeData _modalChallenge = new ChallengeData();
          _modalChallenge.challengeName = userData[i]['challengeName'];
          _modalChallenge.challengeId = userData[i]['challengeId'].toString();
          _modalChallenge.challengeDescription =
              userData[i]['Description'].toString() ?? '-';
          _modalChallenge.challengeCreatedBy =
              userData[i]['createdBy'].toString();
          _modalChallenge.challengeDistance =
              userData[i]['ChallengeDistance'].toString();
          _modalChallenge.challengeStartDate =
              userData[i]['StartDate'].toString() ?? '-';
          _modalChallenge.challengeEndDate =
              userData[i]['EndDate'].toString() ?? '-';
          _modalChallenge.withdraw =
              userData[i]['withdraw'].toString() ?? '0';

          if(_modalChallenge.withdraw == "2")
            challengeData.add(_modalChallenge);
        }
        if (challengeData.length > 0) {
          setState(() {
            challengeName = challengeData[_indexChallenge].challengeName;
          });
          if (tabSelected == 1) {
//            await getData(store);
          }else{

          }
        }
      }else{
        return null;
      }
    });
  }



  Future<void> getData(Store<AppState> store) async {
    store.dispatch(SessionResponseListAction(new List()));
    _database
        .reference()
        .child(DataBaseConstants.sessionData)
        .orderByChild("userId")
        .equalTo(store.state.userAppModal.userId)
        .once()
        .then((snapshot) async {
      if (snapshot.value != null) {
        _database
            .reference()
            .child(DataBaseConstants.sessionData)
            .orderByChild("userId")
            .equalTo(store.state.userAppModal.userId)
            .once()
            .then((snapshot) async {
          if (snapshot.value != null) {
            map = snapshot.value;
            setState(() {
              _indexChallenge = 0;
            });
            await _challengeData();
          }
        });
      } else {
        await _challengeData();
      }
    });
  }


  /*
  * get sessions list
  * based on challenge*/
  Future<void> _challengeData() async {
    List<AddSession> addSessionData = new List();
    store.dispatch(SessionResponseListAction(new List()));

    DateTime startDateMonth = DateTime(int.parse(challengeData[_indexChallenge].challengeStartDate.split('-')[0]),
      int.parse(challengeData[_indexChallenge].challengeStartDate.split('-')[1]),
      int.parse(challengeData[_indexChallenge].challengeStartDate.split('-')[2]),
    );
    DateTime startDateAfterEight = DateTime(int.parse(challengeData[_indexChallenge].challengeStartDate.split('-')[0]),
        int.parse(challengeData[_indexChallenge].challengeStartDate.split('-')[1]),
        int.parse(challengeData[_indexChallenge].challengeStartDate.split('-')[2]),8
    );
    DateTime endDateMonth = DateTime(int.parse(challengeData[_indexChallenge].challengeEndDate.split('-')[0]),
      int.parse(challengeData[_indexChallenge].challengeEndDate.split('-')[1]),
      int.parse(challengeData[_indexChallenge].challengeEndDate.split('-')[2]),
    );
    try{
      var newMap = Map.fromEntries(map.entries.toList()..sort((e1, e2) =>
          DateTime.parse(e1.value["createdOn"].toString()).
          compareTo(DateTime.parse(e2.value["createdOn"].toString()))));
      print(newMap);

      for (int i = 0; i < newMap.length; i++) {
        var _key = newMap.keys.toList()[i];
        String createdOn = newMap.values.toList()[i]["createdOn"];
        String updatedOn = newMap.values.toList()[i]["updatedOn"];
        DateTime dateFirebase = DateTime(
          int.parse(createdOn.split(' ')[0].split('-')[0]),
          int.parse(createdOn.split(' ')[0].split('-')[1]),
          int.parse(createdOn.split(' ')[0].split('-')[2]),
        );
        DateTime dateCreatedOn = DateTime(
          int.parse(createdOn.split(' ')[0].split('-')[0]),
          int.parse(createdOn.split(' ')[0].split('-')[1]),
          int.parse(createdOn.split(' ')[0].split('-')[2]),
          int.parse(createdOn.split(' ')[1].split(':')[0]),
          int.parse(createdOn.split(' ')[1].split(':')[1]),
        );
        DateTime dateUpdatedOn = DateTime(
          int.parse(updatedOn.split(' ')[0].split('-')[0]),
          int.parse(updatedOn.split(' ')[0].split('-')[1]),
          int.parse(updatedOn.split(' ')[0].split('-')[2]),
          int.parse(updatedOn.split(' ')[1].split(':')[0]),
          int.parse(updatedOn.split(' ')[1].split(':')[1]),
        );
        //if scheduletype == 2 for challenge, then add rule
        if (challengeData[_indexChallenge].scheduleType == '2'){
          if (dateCreatedOn.day == 6 || dateCreatedOn.day == 7){
            //session is in weekend///////do nothing here......
          }else{
            //here session is in weekday...... rule 1
            String isDelete = newMap.values.toList()[i]["delete"] ?? "0";
            if(_sessionType == "Automatic" ||
                _sessionType == "Manual" && newMap.values
                    .toList()[i]["data"]
                    .values
                    .toList()[1]["isSession"] == "Manual" && isDelete == "0") {
              if (dateFirebase.isAtSameMomentAs(endDateMonth) &&
                  dateFirebase.isAtSameMomentAs(startDateMonth) ||
                  dateFirebase.isBefore(endDateMonth) &&
                      dateFirebase.isAfter(startDateAfterEight) ||
                  dateFirebase.isBefore(endDateMonth) &&
                      dateFirebase.isAtSameMomentAs(startDateMonth) ||
                  dateFirebase.isAtSameMomentAs(endDateMonth) &&
                      dateFirebase.isAfter(startDateMonth)) {

                //session has started after 8 and before end time ---------rule 2


//                for(int value=0;  value < newMap.length; value ++){
                  Map<dynamic, dynamic>  userData = newMap.values.toList()[i]["data"];

                  String isDelete = newMap.values.toList()[i]["delete"] ?? "0";

                  //{movementDateTime: 1590601642313, SessionData: {Speed: -1.0,
                  // distance: 1, StartTime: 2020-5-27 13:47, sessionType: Automatic, activityType: Vehicle},
                  // userId: 0g3d6BX0ntTbmCdtYRkWoksdacj2}
//          Map<dynamic, dynamic> map = snapshot.value;
                  var _key = newMap.keys.toList()[i];
                  print(_key+" key");
                  print(isDelete+" del");

                  AddSession _sessionModal = new AddSession();
                  _sessionModal.createdOn = newMap.values.toList()[i]["createdOn"];
                  _sessionModal.delete = newMap.values.toList()[i]["delete"] ?? "0";
                  _sessionModal.sessionId = newMap.values.toList()[i]["sessionId"];
                  _sessionModal.updatedOn = newMap.values.toList()[i]["updatedOn"];
                  _sessionModal.userId = newMap.values.toList()[i]["userId"];
                  _sessionModal.sessionName = newMap.values.toList()[i]["sessionName"]??"";
                  _sessionModal.currentDay = newMap.values.toList()[i]["currentDay"]??"";
                  _sessionModal.sessionYear = newMap.values.toList()[i]["sessionYear"]??"";
                  _sessionModal.key = _key;

                  prefix1.Data _dataSession = new prefix1.Data();
                  _dataSession.movementDateTime = userData["movementDateTime"];
                  _dataSession.userId = userData["userId"];

                  SessionData _sessionInsideData = new SessionData();

                  Map<dynamic, dynamic>  sessionInMap = userData["SessionData"];
                  _sessionInsideData.speed = sessionInMap["Speed"];
                  _sessionInsideData.startTime = sessionInMap["StartTime"];
                  _sessionInsideData.activityType = sessionInMap["activityType"];
                  _sessionInsideData.distance = sessionInMap["distance"];
                  _sessionInsideData.sessionType = sessionInMap["sessionType"];
                  _dataSession.sessionData = _sessionInsideData;
                  _sessionModal.data = _dataSession;

                  print(double.parse(sessionInMap["distance"]));
                  if(double.parse(sessionInMap["distance"]) > 500.0 && isDelete == "0") {
                    addSessionData.add(_sessionModal);
                  }
//                }
                List<AddSession> reversedSessions = addSessionData.reversed.toList();
                store.dispatch(SessionResponseListAction(reversedSessions));

              }
            }

          }
        }else{
          //
          String isDelete = newMap.values.toList()[i]["delete"] ?? "0";
          if(_sessionType == "Automatic" ||
              _sessionType == "Manual" && newMap.values
                  .toList()[i]["data"]
                  .values
                  .toList()[1]["isSession"] == "Manual" && isDelete == "0") {
            if (dateFirebase.isAtSameMomentAs(endDateMonth) &&
                dateFirebase.isAtSameMomentAs(startDateMonth) ||
                dateFirebase.isBefore(endDateMonth) &&
                    dateFirebase.isAfter(startDateAfterEight) ||
                dateFirebase.isBefore(endDateMonth) &&
                    dateFirebase.isAtSameMomentAs(startDateMonth) ||
                dateFirebase.isAtSameMomentAs(endDateMonth) &&
                    dateFirebase.isAfter(startDateMonth)) {

              //session has started after 8 and before end time ---------rule 2




//              for(int value=0;  value < newMap.length; value ++){
                Map<dynamic, dynamic>  userData = newMap.values.toList()[i]["data"];

                String isDelete = newMap.values.toList()[i]["delete"] ?? "0";

                //{movementDateTime: 1590601642313, SessionData: {Speed: -1.0,
                // distance: 1, StartTime: 2020-5-27 13:47, sessionType: Automatic, activityType: Vehicle},
                // userId: 0g3d6BX0ntTbmCdtYRkWoksdacj2}
//          Map<dynamic, dynamic> map = snapshot.value;
                var _key = newMap.keys.toList()[i];
                print(_key+" key");
                print(isDelete+" del");

                AddSession _sessionModal = new AddSession();
                _sessionModal.createdOn = newMap.values.toList()[i]["createdOn"];
                _sessionModal.delete = newMap.values.toList()[i]["delete"] ?? "0";
                _sessionModal.sessionId = newMap.values.toList()[i]["sessionId"];
                _sessionModal.updatedOn = newMap.values.toList()[i]["updatedOn"];
                _sessionModal.userId = newMap.values.toList()[i]["userId"];
                _sessionModal.sessionName = newMap.values.toList()[i]["sessionName"]??"";
                _sessionModal.currentDay = newMap.values.toList()[i]["currentDay"]??"";
                _sessionModal.sessionYear = newMap.values.toList()[i]["sessionYear"]??"";
                _sessionModal.key = _key;

                prefix1.Data _dataSession = new prefix1.Data();
                _dataSession.movementDateTime = userData["movementDateTime"];
                _dataSession.userId = userData["userId"];

                SessionData _sessionInsideData = new SessionData();

                Map<dynamic, dynamic>  sessionInMap = userData["SessionData"];
                _sessionInsideData.speed = sessionInMap["Speed"];
                _sessionInsideData.startTime = sessionInMap["StartTime"];
                _sessionInsideData.activityType = sessionInMap["activityType"];
                _sessionInsideData.distance = sessionInMap["distance"];
                _sessionInsideData.sessionType = sessionInMap["sessionType"];
                _dataSession.sessionData = _sessionInsideData;
                _sessionModal.data = _dataSession;

                print(double.parse(sessionInMap["distance"]));
                if(double.parse(sessionInMap["distance"]) > 500.0 && isDelete == "0") {
                  addSessionData.add(_sessionModal);
                }
//              }
              List<AddSession> reversedSessions = addSessionData.reversed.toList();
              store.dispatch(SessionResponseListAction(reversedSessions));
            }
          }
        }
      }
    }catch(Exc){}
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
