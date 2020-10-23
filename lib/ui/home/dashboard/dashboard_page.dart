import 'dart:async';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/challenge_action.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/dashboard_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_challenge_data_modal.dart';
import 'package:greenplayapp/redux/model/challenge_user_modal.dart';
import 'package:greenplayapp/redux/model/dashboard_activity_modal.dart';
import 'package:greenplayapp/redux/model/user_model.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/formatter/month_formatter.dart';
import 'package:greenplayapp/utils/formatter/week_formatter.dart';
import 'package:greenplayapp/utils/formatter/year_formatter.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:intl/intl.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/chart/pie_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/controller/pie_chart_controller.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data/pie_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/pie_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/entry/pie_entry.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/enums/value_position.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/render/pie_chart_renderer.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/value_formatter/my_value_formatter.dart';
import 'package:mp_chart/mp/core/value_formatter/percent_formatter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>  with SingleTickerProviderStateMixin, RouteAware{
  int _index = 0;
  int _indexDuration = 0;
  Store<AppState> store;
  SharedPreferences _prefs;
  int pieChart = 0;
  int barChart = 1;

  var monday = 1;
  var tuesday = 2;
  var wednesday = 3;
  var thursday = 4;
  var friday = 5;
  var saturday = 6;
  var sunday = 7;


  var now = new DateTime.now();

  String runDistance = '0 km';
  String time = '00:00';
  String challengeName = 'No Challenge';
  String greenHouse = '0.00 kg';
  String _sessionType;

  Map<dynamic, dynamic> map;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  List<DashboardActivityModal> _activityDataList = new List();

  List<ChallengeData> challengeData = new List();
  int _indexChallenge = 0;
  int dashboardTime = 0;
  double dashboardPercent = 0.0;
  int _weightForCalorie = 1;

  PieChartController controllerPie;
  PercentFormatter _formatter = PercentFormatter();
  BarChartController  _controllersBar ;
  var random = Random(1);

  var refreshKeyAll = GlobalKey<RefreshIndicatorState>();

  var _styleTab = GoogleFonts.openSans(
    fontSize: ScreenUtil.getInstance().setSp(12),
    color: AppColors.colorBlack,
    fontWeight: FontWeight.w500,
  );

//initialize shared preference here.......
  void initPref(Store<AppState> store) async {
    _prefs = PrefsSingleton.prefs;
    print(_prefs.getString(PreferenceNames.timeInit));

    if (_prefs.getString(PreferenceNames.isSession) == null ||  _prefs.getString(PreferenceNames.isSession) == "") {
      _sessionType = "Automatic";
    }else{
//      _sessionType = _prefs.getString(PreferenceNames.isSession);
      _sessionType = "Automatic";
    }
    if (_prefs.getString(PreferenceNames.weight) != '' && _prefs.getString(PreferenceNames.gender) != null ) {
      _weightForCalorie = int.parse(_prefs.getString(PreferenceNames.weight));
    }else if (_prefs.getString(PreferenceNames.gender) == null || _prefs.getString(PreferenceNames.gender) != '') {
      _weightForCalorie = Constants.ageConstant;
    }else if (_prefs.getString(PreferenceNames.gender) == 'male') {
      _weightForCalorie = Constants.ageMan;
    } else {
      _weightForCalorie = Constants.ageWoMan;
    }
  }


  /*init controller for circular chart*/
  void _initController() {
    var desc = Description()..enabled = false;
    controllerPie = PieChartController(
        legendSettingFunction: (legend, controller) {
          _formatter.setPieChartPainter(controller);
          legend
            ..verticalAlignment = (LegendVerticalAlignment.TOP)
            ..horizontalAlignment = (LegendHorizontalAlignment.RIGHT)
            ..orientation = (LegendOrientation.VERTICAL)
            ..drawInside = (false)
            ..enabled = (false);
        },
        rendererSettingFunction: (renderer) {
          (renderer as PieChartRenderer)
            ..setHoleColor(ColorUtils.WHITE)
            ..setHoleColor(ColorUtils.WHITE)
            ..setTransparentCircleColor(ColorUtils.WHITE)
            ..setTransparentCircleAlpha(110);
        },
        rotateEnabled: false,
        drawHole: true,
        drawCenterText: false,
        extraLeftOffset: 20,
        extraTopOffset: 0,
        extraRightOffset: 20,
        extraBottomOffset: 0,
        usePercentValues: true,
        centerText: "",
        holeRadiusPercent: 58,
        transparentCircleRadiusPercent: 61,
        highLightPerTapEnabled: false,
//        selectionListener: this,
        description: desc);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    observer.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    observer.unsubscribe(this);
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, _DashModel>(
        converter: (Store<AppState> store) {
      this.store = store;

      return _DashModel.create(store, context);
    }, onInit: (store) async {
      challengeName = DemoLocalizations.of(context).trans('no_challenge_dash');

      initPref(store);
      await getData(store).whenComplete(() {});
//      store.dispatch(DashboardUsersAction());//start splash timer
      _allUserInOrganisation(store, "week");

      _initController();
      _distanceData(store,"week");
    }, builder: (BuildContext context, data) {
      return Scaffold(
        backgroundColor: AppColors.colorBgGray,
        body: Container(
          child: SingleChildScrollView(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _caloriesForm(data),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _tabTotalStat(), _tabCurrentChallenge()],
                ),

                _card(data)
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _caloriesForm(_DashModel data) {
    return
      Container(
        margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(10), right: ScreenUtil.getInstance().setWidth(10)),
        child:
        Row(
          children: <Widget>[
            Expanded(
              child: _calorieCircular(data)
            ),
            Container(
              color: AppColors.colorWhiteLight,
              height: ScreenUtil.getInstance().setWidth(100),
              width: 1,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    DemoLocalizations.of(context).trans('calories'),
                    style: GoogleFonts.openSans(
                      textStyle: Theme.of(context).textTheme.display1,
                      fontSize: ScreenUtil.getInstance().setSp(17),
                      color: Color(0xFF646E8D),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                  Text(
                    data.dashCalorie,
                    style: GoogleFonts.openSans(
                      textStyle: Theme.of(context).textTheme.display1,
                      fontSize: ScreenUtil.getInstance().setSp(18),
                      color: Color(0xFF646E8D),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                      textScaleFactor: 1.0
                  ),
                ],
              ),
            )
          ],),
      );
  }

  Widget _calorieCircular(_DashModel data) {
    return
      Container(
        width: ScreenUtil.getInstance().setWidth(120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 5.0,
              percent: data.dashPercent,
              animation: true,
              center: Text(
                _index == 0 ? greenHouse :
                data.dashPercent == 0.0 ? '0': data.dashPercent.toStringAsFixed(2) + '%',
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setSp(17),
                  color: Color(0xFF646E8D),
                  fontWeight: FontWeight.w400,
                ),
                  textScaleFactor: 1.0
              ),
              backgroundColor: Color(0xFFE6E6E6),
              progressColor: Color(0xFFB3C2D8),
            ),
           Container(
             width: ScreenUtil.getInstance().setWidth(100),
               height: ScreenUtil.getInstance().setHeight(55),
             child:
             Text(
               _index == 0 ? DemoLocalizations.of(context).trans('gaze_dash') :
               DemoLocalizations.of(context).trans('current'),
               textAlign: TextAlign.center,maxLines: 4,
               style: GoogleFonts.openSans(
                 textStyle: Theme.of(context).textTheme.display1,
                 fontSize: ScreenUtil.getInstance().setSp(12),
                 color: Color(0xFF646E8D),
                 fontWeight: FontWeight.w400,
               ),
                 textScaleFactor: 1.0
             ),
           )
          ],
        ),
      );
  }

  Widget _tabTotalStat() {
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
            elevation: 0,splashColor: AppColors.colorBgGray,focusColor: AppColors.colorBgGray,hoverColor: AppColors.colorBgGray,
            highlightColor: AppColors.colorBgGray,disabledColor: AppColors.colorBgGray,
            color: _index == 0 ? AppColors.colorBgGray : AppColors.colorBgGray,
            child: Text(
              DemoLocalizations.of(context).trans('stats'),
                style: _styleTab, textAlign: TextAlign.center,maxLines: 4,),
            onPressed: () async{
              setState(() {
                _index = 0;
              });
              await getData(store);
//              store.dispatch(DashboardUsersAction());
              _allUserInOrganisation(store, "week");
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(
                    color: _index == 0
                        ? AppColors.colorBgGray
                        : AppColors.colorBgGray,
                    width: 5.0)),
          )),
        ),
        Container(
          height: 5,
          margin: EdgeInsets.only(left: 10),
          width: MediaQuery.of(context).size.width,
          color: _index == 0 ? AppColors.colorBlue : AppColors.colorBgGray,
        )
      ],
    ));
  }

  Widget _tabCurrentChallenge() {
    return Expanded(
        child: Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(10)),
          height: ScreenUtil.getInstance().setHeight(50),
          alignment: Alignment.center,
//            color: Colors.transparent,
          child: RaisedButton(
            elevation: 0,splashColor: AppColors.colorBgGray,focusColor: AppColors.colorBgGray,hoverColor: AppColors.colorBgGray,
            highlightColor: AppColors.colorBgGray,disabledColor: AppColors.colorBgGray,
            color: _index == 1 ? AppColors.colorBgGray : AppColors.colorBgGray,
            child: Text(DemoLocalizations.of(context).trans('current_chall'),
                style: _styleTab,textAlign: TextAlign.center),
            onPressed: () async{
              setState(() {
                _index = 1;
                time = '00:00';
                runDistance = '0 km';
                greenHouse = '0.00 kg';
              });
               await _loadMyChallenges(store);
              _allUserInChallenge(store);
              _distanceDataChallenge(store, "week");
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(
                    color: _index == 1
                        ? AppColors.colorBgGray
                        : AppColors.colorBgGray,
                    width: 5.0)),
          ),
        ),
        Container(
          height: 5,
          margin: EdgeInsets.only(right: 10),
          width: MediaQuery.of(context).size.width,
          color: _index == 1 ? AppColors.colorBlue : AppColors.colorBgGray,
        )
      ],
    ));
  }

  Widget _card(_DashModel data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
          height: ScreenUtil.getInstance().setHeight(300),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: AppColors.colorWhite),
              ),
              elevation: 0.0,
              color: AppColors.colorWhite,
              child: data.loader
                  ?
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  ),
                ),
              )
                  : _listNextChallenge(data)),
        ),
      ],
    );
  }

  Widget _listNextChallenge(_DashModel data) {
    return
      RefreshIndicator(
          key: refreshKeyAll,
          onRefresh: _getData,
          child:
          Stack(
            children: <Widget>[
              new ListView.builder(
                  itemCount: 5,
                  physics: AlwaysScrollableScrollPhysics(),

                  ///
                  shrinkWrap: true,

                  ///
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return _listItems(index, data);
                  })
            ],
          ));
  }


  Future<void> _getData() async {
    refreshKeyAll.currentState?.show(
        atTop:
        true);
    await getData(store).whenComplete(() {});
//    store.dispatch(DashboardUsersAction());
    if(_indexDuration == 0) {
      await _allUserInOrganisation(store, "week");
      _distanceData(store, "week");
    }else if(_indexDuration == 1){
      _allUserInOrganisation(store, "month");
      _distanceData(store, "month");
    }else{
      _allUserInOrganisation(store, "year");
      _distanceData(store, "year");
    }
  }


  Widget _listItems(int index, _DashModel data) {
    return Container(
      child: index == 0
          ? _index == 0 ? _tabTimePeriod(data) : _challengeNameHeader()
      : index == 1 ?
          _index == 0 ? _setDateTab() : _setDateTabChallenge()
          : index == 2
              ? _listActivity(data)
//              ? _index == 0 ? _listActivity(data) : _listActivity(data)
              :  _index == 0 ? index == 3 ? _viewPersonalStatsTab(data) : Container() :
      index == 2 ? _viewChallengeCurrentTab(data) : Container(),
    );
  }


  Widget _setDateTab(){
    return
        Container(
          child:
          Align(
            child:
            Text( _index == 0 ? _indexDuration == 0 ? GetDate.getDate("week",context):
                _indexDuration == 1 ? GetDate.getDate("month",context): GetDate.getDate("year",context) : "",
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setSp(15),
                  color: Color(0xFF646E8D),
                  fontWeight: FontWeight.w500,
                ),
                textScaleFactor: 1.0),
          ),
        );
  }

  Widget _setDateTabChallenge(){
    return
        Container(
          child:
          Align(
            child:
            Text(challengeData.length > 0 ?challengeData[_indexChallenge] != null ? GetMonth.getMonth
              (challengeData[_indexChallenge].challengeStartDate.toString()??"",context )
                + "-"+GetMonth.getMonth
              (challengeData[_indexChallenge].challengeEndDate.toString()??"",context ) : " " : "",
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setSp(15),
                  color: Color(0xFF646E8D),
                  fontWeight: FontWeight.w500,
                ),
                textScaleFactor: 1.0),
          ),
        );
  }

  /*
  * when personal stats is selected
  * first...show activity list
  * second...time total of user
  * third...all colleagues with same business*/
  Widget _viewPersonalStatsTab(_DashModel data){
    return
      Column(
        children: <Widget>[
          _timeDetail(),
          _greenDetail(),

          data.listUser == null || data.listUser.length == 0? Container() : Align(
           alignment: Alignment.center,
           child:
           Container(
             margin: EdgeInsets.all(10
             ),
             child:
             Text(
               DemoLocalizations.of(context).trans('my_coll'),
               style: GoogleFonts.openSans(
                 textStyle: Theme.of(context).textTheme.display1,
                 fontSize: ScreenUtil.getInstance().setSp(16),
                 color: AppColors.colorBlack,
                 fontWeight: FontWeight.w700,
               ),
                 textScaleFactor: 1.0
             ),
           ),
         ),
          _listUserBusiness(data),

          _controllersBar != null ?Text(
              DemoLocalizations.of(context).trans('sustain'),
              textAlign: TextAlign.left,
              style: GoogleFonts.openSans(
                textStyle: Theme.of(context).textTheme.display1,
                fontSize: ScreenUtil.getInstance().setSp(16),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w700,
              ),
              textScaleFactor: 1.0
          ) : Container(),
          _controllersBar != null ? SizedBox(height: 300, child: _renderItem(0)) : Container(),

          pieChart != 0 && controllerPie != null ? Text(
              DemoLocalizations.of(context).trans('pie_header'),
              textAlign: TextAlign.left,
              style: GoogleFonts.openSans(
                textStyle: Theme.of(context).textTheme.display1,
                fontSize: ScreenUtil.getInstance().setSp(16),
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w700,
              ),
              textScaleFactor: 1.0
          ) : Container(),
          pieChart != 0 && controllerPie != null ? SizedBox(height: 300, child: _initPieChart()) : Container()
        ],
      );
  }



 /*
 * when tab current challenge is selected
 * first...show activity, distance, time
 * second...show chart
 * third...my colleagues*/
  Widget _viewChallengeCurrentTab(_DashModel data){
    return
        Column(
          children: <Widget>[
            _timeDetail(),
            _greenDetail(),

            Align(
              alignment: Alignment.center,
              child:
              data.listParticipant == null || data.listParticipant.length == 0 ? Container() : Container(
                margin: EdgeInsets.all(10
                ),
                child:
                Text(
                  DemoLocalizations.of(context).trans('my_coll'),
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(16),
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.w700,
                  ),
                    textScaleFactor: 1.0
                ),
              ),
            ),
            _listParticipants(data),

            _controllersBar != null ?Text(
                DemoLocalizations.of(context).trans('sustain'),
                textAlign: TextAlign.left,
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setSp(16),
                  color: AppColors.colorBlack,
                  fontWeight: FontWeight.w700,
                ),
                textScaleFactor: 1.0
            ) : Container(),
            _controllersBar != null ? SizedBox(height: 300, child: _renderItem(0)) : Container(),

            pieChart != 0 && controllerPie != null ? Text(
                DemoLocalizations.of(context).trans('pie_header'),
                textAlign: TextAlign.left,
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.display1,
                  fontSize: ScreenUtil.getInstance().setSp(16),
                  color: AppColors.colorBlack,
                  fontWeight: FontWeight.w700,
                ),
                textScaleFactor: 1.0
            ) : Container(),
            pieChart != 0 && controllerPie != null ? SizedBox(height: 300, child: _initPieChart()) : Container(),
          ],
        );
  }


  Widget _renderItem(int index) {
    if(_controllersBar != null) {
      var barChart = BarChart(_controllersBar);
      _controllersBar.animator
        ..reset()
        ..animateY1(800);
      return Container(height: 200, child: barChart);
    }else {
      return Container();
    }
  }


  Widget _initPieChart() {
    var pieChart = PieChart(controllerPie);
    controllerPie.animator
      ..reset()
      ..animateY2(800, Easing.EaseInOutQuad);
    return pieChart;
  }


  /*
  * this view is common for both total stats and current challenge
  * shows activity list
  * time
  * distance*/
  Widget _listActivity(_DashModel data) {
    return SingleChildScrollView(
      child: Container(
        child: new ListView.builder(
            itemCount: _activityDataList.length,
            physics: NeverScrollableScrollPhysics(),

            ///
            shrinkWrap: true,

            ///
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return _runningDetail(index);
            }),
      ),
    );
  }


  /*
  * this is list of all participants who are added in challenge
  * with name, distance*/
  Widget _listParticipants(_DashModel data) {
    return SingleChildScrollView(
      child: Container(
        child: new ListView.builder(
            itemCount: data.listParticipant == null ? 0 : data.listParticipant.length,
            physics: NeverScrollableScrollPhysics(),

            ///
            shrinkWrap: true,

            ///
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return _challengePartItemList(index,data);
            }),
      ),
    );
  }


  /*list of all users having same business
  * */
  Widget _listUserBusiness(_DashModel data) {
    return SingleChildScrollView(
      child: Container(
        child: new ListView.builder(
            itemCount: data.listUser == null ? 0 : data.listUser.length,
            physics: NeverScrollableScrollPhysics(),

            ///
            shrinkWrap: true,

            ///
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return _userItemList(index,data);
            }),
      ),
    );
  }


  /*item consisting of each participant detail*/
  Widget _challengePartItemList(int index, _DashModel data) {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(data.listParticipant[index].userName,
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w400,
                  ),
                  textScaleFactor: 1.0),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Text((double.parse(data.listParticipant[index].distance??"0")/1000 ).toStringAsFixed(2)+ " km",
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: 1.0),
            )
          ],
        ));
  }


  /*item consisting of each participant detail*/
  Widget _userItemList(int index, _DashModel data) {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(data.listUser[index].firstName,
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w400,
                  ),
                  textScaleFactor: 1.0),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text((double.parse(data.listUser[index].getDistance??"0")/1000).toStringAsFixed(2) + " km",
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: 1.0),
            )
          ],
        ));
  }

  //item detail of tab 1(for personal stats)......activity list item is shown here.........
  Widget _runningDetail(int index) {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Row(
          children: <Widget>[
            _activityDataList[index].getActivityType == DemoLocalizations.of(context).trans('run') ||
            _activityDataList[index].getActivityType.toLowerCase() == "Course".toLowerCase() ||
            _activityDataList[index].getActivityType.toLowerCase() == "Running".toLowerCase() ?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/runningruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setHeight(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )) :

            _activityDataList[index].getActivityType.toLowerCase() == "Vélo".toLowerCase() ||
                _activityDataList[index].getActivityType.toLowerCase() == "Bike".toLowerCase()
                || _activityDataList[index].getActivityType.toLowerCase() == DemoLocalizations.of(context).trans('bike').toLowerCase()?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/bikeruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setHeight(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )) :

            _activityDataList[index].getActivityType.toString().toLowerCase() == DemoLocalizations.of(context).trans('walk') ||
            _activityDataList[index].getActivityType.toString().toLowerCase() == "Marche".toLowerCase() ||
            _activityDataList[index].getActivityType.toString().toLowerCase() == "Walking".toLowerCase()||
            _activityDataList[index].getActivityType.toString().toLowerCase() == "walk" ||
            _activityDataList[index].getActivityType.toString().toLowerCase() == "walking"  ?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
              child:
              SvgPicture.asset(
                'asset/walkruler.svg',
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                allowDrawingOutsideViewBox: true,
                color: AppColors.colorWhiteLight,
              )
            ) :

            _activityDataList[index].getActivityType.toString() == DemoLocalizations.of(context).trans('electric_car') ||
            _activityDataList[index].getActivityType.toString().toLowerCase() == "Voiture électrique".toLowerCase() ||
            _activityDataList[index].getActivityType.toString().toLowerCase() == "Electric car".toLowerCase() ?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/electriccarruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )) :

            _activityDataList[index].getActivityType.toLowerCase() == "Conduire seul".toLowerCase()||
            _activityDataList[index].getActivityType.toLowerCase() == "Driving alone".toLowerCase()||
            _activityDataList[index].getActivityType == DemoLocalizations.of(context).trans('drive')?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/drivingaloneruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            ) ):

            _activityDataList[index].getActivityType.toString().toLowerCase() == "Covoiturage".toLowerCase()||
            _activityDataList[index].getActivityType.toString().toLowerCase() == "Carpooling".toLowerCase() ||
            _activityDataList[index].getActivityType.toString() == DemoLocalizations.of(context).trans('carpool') ?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/carpoolingruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )):

            _activityDataList[index].getActivityType.toLowerCase() == "Moto".toLowerCase() ||
            _activityDataList[index].getActivityType.toLowerCase() == "Motorcycling".toLowerCase() ||
            _activityDataList[index].getActivityType == DemoLocalizations.of(context).trans('motor')?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child: SvgPicture.asset(
              'asset/motorcyclingruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )):

            _activityDataList[index].getActivityType.toLowerCase()== "Autobus".toLowerCase()||
            _activityDataList[index].getActivityType.toLowerCase()== "Transit bus".toLowerCase() ||
            _activityDataList[index].getActivityType.toLowerCase()== DemoLocalizations.of(context).trans('trans')?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/transitbusruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )) :

            _activityDataList[index].getActivityType.toLowerCase() == "In vehicle".toLowerCase() ||
            _activityDataList[index].getActivityType.toLowerCase() == "En véhicule".toLowerCase()||
            _activityDataList[index].getActivityType == DemoLocalizations.of(context).trans('veh') ?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/vehicleruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            ) ):

            _activityDataList[index].getActivityType.toLowerCase() == DemoLocalizations.of(context).trans('rad').toLowerCase() ||
            _activityDataList[index].getActivityType.toLowerCase() == "Remote work".toLowerCase() ||
            _activityDataList[index].getActivityType.toLowerCase() == "Travail à distance".toLowerCase()?
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child: SvgPicture.asset(
              'asset/remoteworkruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )) :
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/unknownruler.svg',
              height: ScreenUtil.getInstance().setHeight(20),
              width: ScreenUtil.getInstance().setWidth(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(_activityDataList[index].getActivityType.toLowerCase() == "other" ?
              DemoLocalizations.of(context).trans('dialog_other') :
              _activityDataList[index].getActivityType.toLowerCase() == "transit bus" ? DemoLocalizations.of(context).trans('trans') :
              _activityDataList[index].getActivityType.toLowerCase() == "motorcycling" ? DemoLocalizations.of(context).trans('motor') :
              _activityDataList[index].getActivityType.toLowerCase() == "remote work" ? DemoLocalizations.of(context).trans('rad') :
              _activityDataList[index].getActivityType.toLowerCase() == "bike" ? DemoLocalizations.of(context).trans('bike') :
              _activityDataList[index].getActivityType.toLowerCase() == "carpooling" ? DemoLocalizations.of(context).trans('carpool') :
              _activityDataList[index].getActivityType.toLowerCase() == "train" ? DemoLocalizations.of(context).trans('train') :
              _activityDataList[index].getActivityType.toLowerCase() == "walking" ? DemoLocalizations.of(context).trans('walk') :
              _activityDataList[index].getActivityType.toLowerCase() == "carpooling electric car" ? DemoLocalizations.of(context).trans('electric') :
              _activityDataList[index].getActivityType.toLowerCase() == "metro" ? DemoLocalizations.of(context).trans('metro') :
              _activityDataList[index].getActivityType.toLowerCase() == "electric car" ? DemoLocalizations.of(context).trans('electric_car') :
              _activityDataList[index].getActivityType.toLowerCase() == "driving alone" ? DemoLocalizations.of(context).trans('drive') :
              _activityDataList[index].getActivityType.toLowerCase() == "running" ? DemoLocalizations.of(context).trans('run') :
              _activityDataList[index].getActivityType.toLowerCase() == "unknown" ? DemoLocalizations.of(context).trans('unknown') :
              _activityDataList[index].getActivityType.toLowerCase() == "in vehicle" ? DemoLocalizations.of(context).trans('veh') :
              _activityDataList[index].getActivityType
                  ,style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w400,
                  ),
                  textScaleFactor: 1.0),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Text((double.parse(_activityDataList[index].getDistance)/1000).toStringAsFixed(2) + " km",
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: 1.0),
            )
          ],
        ));
  }

  /*
  * shows total sum of time by user*/
  Widget _tabTimePeriod(_DashModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _tabWeek(data),
        _tabMonth(data),
        _tabYear(data),
      ],
    );
  }

  /*
  * when week is selected*/
  Widget _tabWeek(_DashModel data) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(10)),
          height: ScreenUtil.getInstance().setHeight(45),
//            color: Colors.transparent,
          child: RaisedButton(
            elevation: 0,splashColor: AppColors.colorWhite,focusColor: AppColors.colorWhite,hoverColor: AppColors.colorWhite,
            highlightColor: AppColors.colorWhite,disabledColor: AppColors.colorWhite,
            color: _indexDuration == 0
                ? AppColors.colorWhite
                : AppColors.colorWhite,
            child: Text(
                DemoLocalizations.of(context).trans('this_week').toUpperCase(),
                style: _styleTab,textAlign: TextAlign.center,),
            onPressed: () async{
              setState(() {
                _indexDuration = 0;
              });
              await getData(store);
//              store.dispatch(DashboardUsersAction());
              _allUserInOrganisation(store, "week");
              _distanceData(store, "week");
            },
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: _indexDuration == 0
                        ? AppColors.colorWhite
                        : AppColors.colorWhite,
                    width: 5.0)),
          ),
        ),
        Container(
          height: 2,
          margin: EdgeInsets.only(left: 20, right: 10),
          width: MediaQuery.of(context).size.width,
          color:
              _indexDuration == 0 ? AppColors.colorBlue : AppColors.colorWhite,
        )
      ],
    ));
  }

  /*
  * when month is selected*/
  Widget _tabMonth(_DashModel data) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(10)),
          height: ScreenUtil.getInstance().setHeight(45),
//            color: Colors.transparent,
          child: RaisedButton(
            elevation: 0,splashColor: AppColors.colorWhite,focusColor: AppColors.colorWhite,hoverColor: AppColors.colorWhite,
            highlightColor: AppColors.colorWhite,disabledColor: AppColors.colorWhite,
            color: _indexDuration == 1
                ? AppColors.colorWhite
                : AppColors.colorWhite,
            child: Text(
                DemoLocalizations.of(context).trans('this_month').toUpperCase(),
                style: _styleTab,textAlign: TextAlign.center),
            onPressed: ()async {
              setState(() {
                _indexDuration = 1;
              });
              await getData(store);
//              store.dispatch(DashboardUsersAction());
              _allUserInOrganisation(store, "month");
              _distanceData(store, "month");
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(
                    color: _indexDuration == 1
                        ? AppColors.colorWhite
                        : AppColors.colorWhite,
                    width: 5.0)),
          ),
        ),
        Container(
          height: 2,
          margin: EdgeInsets.only(left: 20, right: 10),
          width: MediaQuery.of(context).size.width,
          color:
              _indexDuration == 1 ? AppColors.colorBlue : AppColors.colorWhite,
        )
      ],
    ));
  }


  /*
  * when year is selected*/
  Widget _tabYear(_DashModel data) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(10)),
          height: ScreenUtil.getInstance().setHeight(45),
//            color: Colors.transparent,
          child: RaisedButton(
            elevation: 0,splashColor: AppColors.colorWhite,focusColor: AppColors.colorWhite,hoverColor: AppColors.colorWhite,
            highlightColor: AppColors.colorWhite,disabledColor: AppColors.colorWhite,
            color: _indexDuration == 2
                ? AppColors.colorWhite
                : AppColors.colorWhite,
            child: Text(
                DemoLocalizations.of(context).trans('this_year').toUpperCase(),
                style: _styleTab,textAlign: TextAlign.center),
            onPressed: () async{
              setState(() {
                _indexDuration = 2;
              });
              await getData(store);
//              store.dispatch(DashboardUsersAction());
              _allUserInOrganisation(store, "year");
              _distanceData(store, "year");
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(
                    color: _indexDuration == 2
                        ? AppColors.colorWhite
                        : AppColors.colorWhite,
                    width: 5.0)),
          ),
        ),
        Container(
          height: 2,
          margin: EdgeInsets.only(left: 20, right: 10),
          width: MediaQuery.of(context).size.width,
          color:
              _indexDuration == 2 ? AppColors.colorBlue : AppColors.colorWhite,
        )
      ],
    ));
  }


  /*
  * tab with all name of challenges with next/previous*/
  Widget _challengeNameHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 15, 20, 10),
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
                color: Color(0xFF646E8D),
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


  Widget _timeDetail() {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          children: <Widget>[
            Container(
                height: ScreenUtil.getInstance().setWidth(20),
                width: ScreenUtil.getInstance().setWidth(20),
              child :
              SvgPicture.asset(
                'asset/clock.svg',
                height: ScreenUtil.getInstance().setWidth(20),
                width: ScreenUtil.getInstance().setWidth(20),
                allowDrawingOutsideViewBox: true,
                color: AppColors.colorWhiteLight,
              )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(DemoLocalizations.of(context).trans('time'),
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w400,
                  ),
                  textScaleFactor: 1.0),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Text(time,
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: 1.0
              ),
            )
          ],
        ));
  }

  Widget _greenDetail() {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          children: <Widget>[
            Container(
                height: ScreenUtil.getInstance().setHeight(20),
                width: ScreenUtil.getInstance().setWidth(20),
                child:SvgPicture.asset(
              'asset/barchart.svg',
              height: ScreenUtil.getInstance().setWidth(20),
              width: ScreenUtil.getInstance().setHeight(20),
              allowDrawingOutsideViewBox: true,
              color: AppColors.colorWhiteLight,
            )),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(DemoLocalizations.of(context).trans('gaze'),
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w400,
                  ),
                  textScaleFactor: 1.0),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Text(greenHouse,
                  style: GoogleFonts.openSans(
                    textStyle: Theme.of(context).textTheme.display1,
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    color: Color(0xFF646E8D),
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: 1.0),
            )
          ],
        ));
  }

  Future<void> getData(Store<AppState> store) async {
    time = '00:00';
    runDistance = '0 km';
    greenHouse = '0.00 kg';
    _activityDataList.clear();
    store.dispatch(DashboardLoaderAction(true));
    store.dispatch(DashboardCaloriesAction('0'));
    store.dispatch(DashboardPercentAction(0.0));
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
            if (_index == 0) {
              if (_indexDuration == 0) {
                _weekData();
              } else if (_indexDuration == 1) {
                _monthData();
              } else {
                _yearData();
              }
            }else{
              setState(() {
                _indexChallenge = 0;
              });
              await _challengeData();
            }
          }
        });
      } else {
        if(_index == 1) {
          await _challengeData();
        }
        store.dispatch(DashboardLoaderAction(false));
      }
    });
  }

  Future<void> _weekData() async {
    var totDistMetre = 0.0;
    var totGreenSaved = 0.0;
    var totGreenDist = 0.0;
    var timeLoop = 0;
    var calorieLoop = 0;
    DateTime startDateWeek = now;
    DateTime endDateWeek = now;
    _activityDataList.clear();
    if (now.weekday == tuesday) {
      startDateWeek = now.subtract(new Duration(days: 2));
      endDateWeek = now.add(new Duration(days: 5));
    } else if (now.weekday == wednesday) {
      startDateWeek = now.subtract(new Duration(days: 3));
      endDateWeek = now.add(new Duration(days: 4));
    } else if (now.weekday == thursday) {
      startDateWeek = now.subtract(new Duration(days: 4));
      endDateWeek = now.add(new Duration(days: 3));
    } else if (now.weekday == friday) {
      startDateWeek = now.subtract(new Duration(days: 5));
      endDateWeek = now.add(new Duration(days: 2));
    } else if (now.weekday == saturday) {
      startDateWeek = now.subtract(new Duration(days: 6));
    } else if (now.weekday == monday) {
      startDateWeek = now.subtract(new Duration(days: 1));
      endDateWeek = now.add(new Duration(days: 6));
    } else if (now.weekday == sunday) {
      endDateWeek = now.add(new Duration(days: 6));
    }
    startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
    endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);
    print(startDateWeek);
    print(endDateWeek);


    for (int i = 0; i < map.length; i++) {
      String isDelete = map.values.toList()[i]["delete"] ?? "0";
      if(isDelete == "0") {
        var _key = map.keys.toList()[i];
        String createdOn = map.values.toList()[i]["createdOn"];
        String updatedOn = map.values.toList()[i]["updatedOn"];
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


        if (dateFirebase.isAtSameMomentAs(endDateWeek) ||
            dateFirebase.isAtSameMomentAs(startDateWeek) ||
            dateFirebase.isBefore(endDateWeek) &&
                dateFirebase.isAfter(startDateWeek) ||
            dateFirebase.isBefore(endDateWeek) &&
                dateFirebase.isAtSameMomentAs(startDateWeek) ||
            dateFirebase.isAtSameMomentAs(endDateWeek) &&
                dateFirebase.isAfter(startDateWeek)) {
          if (_sessionType == "Automatic" ||
              _sessionType == "Manual" && map.values
                  .toList()[i]["data"]
                  .values
                  .toList()[1]["isSession"] == "Manual") {
            String activityType;
            try{
               activityType = map.values
                  .toList()[i]["data"]["SessionData"]["activityType"]
                  ?? "";
            }catch(Ex){}

            if (map.values.toList()[i]["data"] != null && activityType !=null )  {
              print("iside...1");


              if (double.parse(map.values
                  .toList()[i]["data"]["SessionData"]["distance"]) > 500) {
                totDistMetre = double.parse(map.values
                    .toList()[i]["data"]["SessionData"]["distance"]) +
                    totDistMetre;



                DashboardActivityModal modal = new DashboardActivityModal();
                modal.activityType = activityType;
                modal.distance = map.values
                    .toList()[i]["data"]["SessionData"]["distance"];

                int index = -1;
                var elementValue =
                _activityDataList.firstWhere((element) =>
                element.getActivityType.toLowerCase() ==
                    modal.getActivityType.toLowerCase()
                    , orElse: () => null);
                if (elementValue != null) {
                  index = _activityDataList.indexOf(elementValue);
                  double totDist = double.parse(elementValue.getDistance) +
                      double.parse(modal.getDistance);
                  modal.distance = totDist.toStringAsFixed(4).toString();

                  _activityDataList.removeAt(index);
                  _activityDataList.add(modal);
                } else {
                  double totDist = double.parse(modal.getDistance);
                  modal.distance = totDist.toStringAsFixed(4);
                  _activityDataList.add(modal);
                }


                if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('rad').toLowerCase() ||
                    activityType.toLowerCase() == "Remote work".toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Travail à distance".toLowerCase()) {
                  //remote work -- ges only
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.remoteWorkGES;


                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                } else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('trans').toLowerCase() ||
                    activityType.toLowerCase() == "Autobus".toLowerCase() ||
                    activityType.toLowerCase() == "Transit bus".toLowerCase()) {
                  //transit bus --> ges , time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.transitBusCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.transitBusGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() == 'Vélo'.toLowerCase() ||
                    activityType.toLowerCase() == 'Bike'.toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('bike').toLowerCase()) {
                  //bicycle --> time, ges, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop + (Constants.bikeCalorie * _weightForCalorie *
                          (dateUpdatedOn
                              .difference(dateCreatedOn)
                              .inMinutes / 60)).
                      toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.bikeGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('carpool').toLowerCase() ||
                    activityType.toLowerCase() == "Covoiturage".toLowerCase() ||
                    activityType.toLowerCase() == "Carpooling".toLowerCase()) {
                  //carpooling -- > ges, time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.carPoolingGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('train').toLowerCase() ||
                    activityType.toLowerCase() == "Train".toLowerCase()
                    || activityType.toLowerCase() == "Train".toLowerCase()) {
                  //train --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.trainCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.trainGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('walk').toLowerCase() ||
                    activityType.toLowerCase() == "Walking".toLowerCase() ||
                    activityType.toLowerCase() == "Marche".toLowerCase() ||
                    activityType.toLowerCase() == "walk" ||
                    activityType.toLowerCase() == "Walk".toLowerCase()) {
                  //walking --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.walkCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.walkGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('electric').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Covoiturage en voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Carpooling electric car".toLowerCase()) {
                  //carpooling electric car --> ges , time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.carPoolElectricCarGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('metro').toLowerCase() ||
                    activityType.toLowerCase() == "Métro".toLowerCase() ||
                    activityType.toLowerCase() == "Metro".toLowerCase()) {
                  //metro --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.metroCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.metroGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('electric_car').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Electric car".toLowerCase()) {
                  //electric car --> ges, time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.electricCarGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('run') .toLowerCase()||
                    activityType.toLowerCase() == "Course".toLowerCase() ||
                    activityType.toLowerCase() == "Running".toLowerCase()) {
                  //running --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop = calorieLoop +
                      (Constants.runningCalorie * _weightForCalorie *
                          (dateUpdatedOn
                              .difference(dateCreatedOn)
                              .inMinutes / 60))
                          .toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.runningGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
              }
            }

          }
        }
      }
    }
    totDistMetre = totDistMetre / 1000;
    double val = totGreenDist - totGreenSaved;
    store.dispatch(DashboardCaloriesAction(calorieLoop.toString()));
    if(this.mounted) {
      setState(() {
//      runDistance = totDistMetre.toStringAsFixed(2).toString() + ' km';
        greenHouse = val.toStringAsFixed(2).toString() + ' kg';
        double hours = timeLoop / 60; //since both are ints, you get an int
        String hoursString = hours.toStringAsFixed(
            0); //since both are ints, you get an int
        if (hoursString.length < 2) {
          hoursString = '0' + hoursString;
        }
        int minutes = timeLoop % 60;
        if (minutes
            .toString()
            .length < 2) {
          time = hoursString + ' : 0' + minutes.toString();
        } else {
          time = hoursString + ' : ' + minutes.toString();
        }
      });
    }
    store.dispatch(DashboardLoaderAction(false));
  }


  //month calculations
  Future<void> _monthData() async {
    var totDistMetre = 0.0;
    var timeLoop = 0;
    var calorieLoop = 0;
    double totGreenSaved = 0;
    double totGreenDist = 0;
    _activityDataList.clear();
    DateTime startDateMonth = DateTime(now.year, now.month, 1);
    DateTime endDateMonth = DateTime(now.year, now.month, 31);
    if (now.month == 4 ||
        now.month == 6 ||
        now.month == 9 ||
        now.month == 11) {
      endDateMonth = DateTime(now.year, now.month, 30);
    }
    print(startDateMonth);
    print(endDateMonth);


    for (int i = 0; i < map.length; i++) {
      String isDelete = map.values.toList()[i]["delete"] ?? "0";
      if(isDelete == "0") {
        String createdOn = map.values.toList()[i]["createdOn"];
        String updatedOn = map.values.toList()[i]["updatedOn"];
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


        if (_sessionType == "Automatic" ||
            _sessionType == "Manual" && map.values
                .toList()[i]["data"]
                .values
                .toList()[1]["isSession"] == "Manual") {
          if (dateFirebase.isAtSameMomentAs(endDateMonth) ||
              dateFirebase.isAtSameMomentAs(startDateMonth) ||
              dateFirebase.isBefore(endDateMonth) &&
                  dateFirebase.isAfter(startDateMonth) ||
              dateFirebase.isBefore(endDateMonth) &&
                  dateFirebase.isAtSameMomentAs(startDateMonth) ||
              dateFirebase.isAtSameMomentAs(endDateMonth) &&
                  dateFirebase.isAfter(startDateMonth)) {
            String activityType;
            try{
              activityType = map.values
                  .toList()[i]["data"]["SessionData"]["activityType"] ?? "";
            }catch(Ex){}

            if (map.values.toList()[i]["data"] != null && activityType != null) {
              String activityType = map.values
                  .toList()[i]["data"]["SessionData"]["activityType"];
              if (double.parse(map.values
                  .toList()[i]["data"]["SessionData"]["distance"]) > 500) {
                totDistMetre = double.parse(map.values
                    .toList()[i]["data"]["SessionData"]["distance"]) +
                    totDistMetre;


                DashboardActivityModal modal = new DashboardActivityModal();
                modal.activityType = activityType;
                modal.distance = map.values
                    .toList()[i]["data"]["SessionData"]["distance"];

                int index = -1;
                var elementValue =
                _activityDataList.firstWhere((element) =>
                element.getActivityType.toLowerCase() ==
                    modal.getActivityType.toLowerCase()
                    , orElse: () => null);
                if (elementValue != null) {
                  index = _activityDataList.indexOf(elementValue);
                  double totDist = double.parse(elementValue.getDistance) +
                      double.parse(modal.getDistance);
                  modal.distance = totDist.toStringAsFixed(4).toString();

                  _activityDataList.removeAt(index);
                  _activityDataList.add(modal);
                } else {
                  double totDist = double.parse(modal.getDistance);
                  modal.distance = totDist.toStringAsFixed(4);
                  _activityDataList.add(modal);
                }


                if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('rad').toLowerCase() ||
                    activityType.toLowerCase() == "Remote work".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Travail à distance".toLowerCase()) {
                  //remote work -- ges only
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.remoteWorkGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                } else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('trans').toLowerCase() ||
                    activityType.toLowerCase() == "Autobus".toLowerCase() ||
                    activityType.toLowerCase() == "Transit bus".toLowerCase()) {
                  //transit bus --> ges , time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.transitBusCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.transitBusGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() == 'Vélo'.toLowerCase() ||
                    activityType.toLowerCase() == 'Bike'.toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('bike').toLowerCase()) {
                  //bicycle --> time, ges, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop + (Constants.bikeCalorie * _weightForCalorie *
                          (dateUpdatedOn
                              .difference(dateCreatedOn)
                              .inMinutes / 60)).
                      toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.bikeGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('carpool').toLowerCase() ||
                    activityType.toLowerCase() == "Covoiturage".toLowerCase() ||
                    activityType.toLowerCase() == "Carpooling".toLowerCase()) {
                  //carpooling -- > ges, time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.carPoolingGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('train').toLowerCase() ||
                    activityType.toLowerCase() == "Train".toLowerCase()
                    || activityType.toLowerCase() == "Train".toLowerCase()) {
                  //train --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.trainCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.trainGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('walk').toLowerCase() ||
                    activityType.toLowerCase() == "Walking".toLowerCase() ||
                    activityType.toLowerCase() == "Marche".toLowerCase() || activityType.toLowerCase() == "walk".toLowerCase() ||
                    activityType.toLowerCase() == "walking") {
                  //walking --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.walkCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.walkGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('electric').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Covoiturage en voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Carpooling electric car".toLowerCase()) {
                  //carpooling electric car --> ges , time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.carPoolElectricCarGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('metro').toLowerCase() ||
                    activityType.toLowerCase() == "Métro".toLowerCase() ||
                    activityType.toLowerCase() == "Metro".toLowerCase()) {
                  //metro --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.metroCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.metroGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('electric_car').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Electric car".toLowerCase()) {
                  //electric car --> ges, time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.electricCarGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('run').toLowerCase() ||
                    activityType.toLowerCase() == "Course".toLowerCase() ||
                    activityType.toLowerCase() == "Running".toLowerCase()) {
                  //running --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop = calorieLoop +
                      (Constants.runningCalorie * _weightForCalorie *
                          (dateUpdatedOn
                              .difference(dateCreatedOn)
                              .inMinutes / 60))
                          .toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.runningGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
              }
            }
          }
        }
      }
    }
    totDistMetre = totDistMetre / 1000;
    double val = totGreenDist - totGreenSaved;
    store.dispatch(DashboardCaloriesAction(calorieLoop.toString()));
    setState(() {
//      runDistance = totDistMetre.toStringAsFixed(2).toString() + ' km';
      greenHouse = val.toStringAsFixed(2).toString() + ' kg';
      print("tottime: $timeLoop");
      double hours = timeLoop / 60; //since both are ints, you get an int
      String hoursString = hours.toStringAsFixed(0); //since both are ints, you get an int
      if (hoursString.length < 2) {
        hoursString = '0' + hoursString;
      }
      int minutes = timeLoop % 60;
      if (minutes.toString().length < 2) {
        time = hoursString + ' : 0' + minutes.toString() ;
      }else {
        time = hoursString + ' : ' + minutes.toString();
      }
    });
    store.dispatch(DashboardLoaderAction(false));
  }


  Future<void> _yearData() async {
    var totDistMetre = 0.0;
    var timeLoop = 0;
    var calorieLoop = 0;
    double totGreenSaved = 0.0;
    double totGreenDist = 0.0;
    _activityDataList.clear();
    DateTime startDateMonth = DateTime(now.year, 1, 1);
    DateTime endDateMonth = DateTime(now.year, 12, 31);


    for (int i = 0; i < map.length; i++) {
      String isDelete = map.values.toList()[i]["delete"] ?? "0";
      if(isDelete == "0") {
        var _key = map.keys.toList()[i];
        String createdOn = map.values.toList()[i]["createdOn"];
        String updatedOn = map.values.toList()[i]["updatedOn"];
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


        if (_sessionType == "Automatic" ||
            _sessionType == "Manual" && map.values
                .toList()[i]["data"]
                .values
                .toList()[1]["isSession"] == "Manual") {
          if (dateFirebase.isAtSameMomentAs(endDateMonth) ||
              dateFirebase.isAtSameMomentAs(startDateMonth) ||
              dateFirebase.isBefore(endDateMonth) &&
                  dateFirebase.isAfter(startDateMonth) ||
              dateFirebase.isBefore(endDateMonth) &&
                  dateFirebase.isAtSameMomentAs(startDateMonth) ||
              dateFirebase.isAtSameMomentAs(endDateMonth) &&
                  dateFirebase.isAfter(startDateMonth)) {
            String activityType;
            try{
              activityType = map.values
                  .toList()[i]["data"]["SessionData"]["activityType"] ?? "";
            }catch(Ex){}

            if (map.values.toList()[i]["data"] != null && activityType != null) {
              String activityType = map.values
                  .toList()[i]["data"]["SessionData"]["activityType"];
              if (double.parse(map.values
                  .toList()[i]["data"]["SessionData"]["distance"]) > 500) {
                totDistMetre = double.parse(map.values
                    .toList()[i]["data"]["SessionData"]["distance"]) +
                    totDistMetre;


                DashboardActivityModal modal = new DashboardActivityModal();
                modal.activityType = activityType;
                modal.distance = map.values
                    .toList()[i]["data"]["SessionData"]["distance"];

                int index = -1;
                var elementValue =
                _activityDataList.firstWhere((element) =>
                element.getActivityType.toLowerCase() ==
                    modal.getActivityType.toLowerCase()
                    , orElse: () => null);
                if (elementValue != null) {
                  index = _activityDataList.indexOf(elementValue);
                  double totDist = double.parse(elementValue.getDistance) +
                      double.parse(modal.getDistance);
                  modal.distance = totDist.toStringAsFixed(4).toString();

                  _activityDataList.removeAt(index);
                  _activityDataList.add(modal);
                } else {
                  double totDist = double.parse(modal.getDistance);
                  modal.distance = totDist.toStringAsFixed(4);
                  _activityDataList.add(modal);
                }


                if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('rad').toLowerCase() ||
                    activityType.toLowerCase() == "Remote work".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Travail à distance".toLowerCase()) {
                  //remote work -- ges only
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.remoteWorkGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                } else
                if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('trans').toLowerCase()
                    || activityType.toLowerCase() == "Autobus".toLowerCase() ||
                    activityType.toLowerCase() == "Transit bus".toLowerCase()) {
                  //transit bus --> ges , time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.transitBusCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.transitBusGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() == 'Vélo'.toLowerCase() ||
                    activityType.toLowerCase() == 'Bike'.toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('bike').toLowerCase()) {
                  //bicycle --> time, ges, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop + (Constants.bikeCalorie * _weightForCalorie *
                          (dateUpdatedOn
                              .difference(dateCreatedOn)
                              .inMinutes / 60)).
                      toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.bikeGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('carpool').toLowerCase() ||
                    activityType.toLowerCase() == "Covoiturage".toLowerCase() ||
                    activityType.toLowerCase() == "Carpooling".toLowerCase()) {
                  //carpooling -- > ges, time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.carPoolingGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('train').toLowerCase() ||
                    activityType.toLowerCase() == "Train".toLowerCase()
                    || activityType.toLowerCase() == "Train".toLowerCase()) {
                  //train --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.trainCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.trainGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('walk').toLowerCase() ||
                    activityType.toLowerCase() == "Walking".toLowerCase() ||
                    activityType.toLowerCase() == "Marche".toLowerCase() ||
                    activityType.toLowerCase() == "walking") {
                  //walking --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.walkCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.walkGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('electric').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Covoiturage en voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Carpooling electric car".toLowerCase()) {
                  //carpooling electric car --> ges , time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.carPoolElectricCarGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('metro').toLowerCase() ||
                    activityType.toLowerCase() == "Métro".toLowerCase() ||
                    activityType.toLowerCase() == "Metro".toLowerCase()) {
                  //metro --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop =
                      calorieLoop +
                          (Constants.metroCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.metroGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('electric_car').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Electric car".toLowerCase()) {
                  //electric car --> ges, time
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 *
                      Constants.electricCarGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
                else if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('run').toLowerCase() ||
                    activityType.toLowerCase() == "Course".toLowerCase() ||
                    activityType.toLowerCase() == "Running".toLowerCase()) {
                  //running --> ges, time, calorie
                  timeLoop = timeLoop + dateUpdatedOn
                      .difference(dateCreatedOn)
                      .inMinutes;
                  calorieLoop = calorieLoop +
                      (Constants.runningCalorie * _weightForCalorie *
                          (dateUpdatedOn
                              .difference(dateCreatedOn)
                              .inMinutes / 60))
                          .toInt();
                  totGreenSaved = totGreenSaved + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.runningGES;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                }
              }
            }
          }
        }
      }
    }
    totDistMetre = totDistMetre / 1000;
    double val =  totGreenDist - totGreenSaved;
    store.dispatch(DashboardCaloriesAction(calorieLoop.toString()));
    setState(() {
      runDistance = totDistMetre.toStringAsFixed(2).toString() + ' km';
      greenHouse = val.toStringAsFixed(2).toString() + ' kg';
      double hours = timeLoop / 60; //since both are ints, you get an int
      String hoursString = hours.toStringAsFixed(0); //since both are ints, you get an int
      if (hoursString.length < 2) {
        hoursString = '0' + hoursString;
      }
      int minutes = timeLoop % 60;
      if (minutes.toString().length < 2) {
        time = hoursString + ' : 0' + minutes.toString();
      }else {
        time = hoursString + ' : ' + minutes.toString();
      }
    });
    store.dispatch(DashboardLoaderAction(false));
  }



  Future<void> _challengeData() async {
    var totDistMetre = 0.0;
    var timeLoop = 0;
    var calorieLoop = 0;
    double totGreenSaved = 0.0;
    double totGreenDist = 0.0;
    _activityDataList.clear();
    store.dispatch(DashboardCaloriesAction('0'));
    store.dispatch(DashboardPercentAction(0.0));
//    challengeData[_indexChallenge].challengeStartDate = '2020-05-15';
//    challengeData[_indexChallenge].challengeEndDate = '2020-05-16';
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
      for (int i = 0; i < map.length; i++) {
        var _key = map.keys.toList()[i];
        String createdOn = map.values.toList()[i]["createdOn"];
        String updatedOn = map.values.toList()[i]["updatedOn"];
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
            String isDelete = map.values.toList()[i]["delete"] ?? "0";
            if(_sessionType == "Automatic" ||
                _sessionType == "Manual" && map.values
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

                if (map.values.toList()[i]["data"] != null) {
                  String activityType = map.values
                      .toList()[i]["data"]["SessionData"]["activityType"];
                  if (double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) > 500) {
                    totDistMetre = double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) +
                        totDistMetre;



                    DashboardActivityModal modal = new DashboardActivityModal();
                    modal.activityType = activityType;
                    modal.distance = map.values
                        .toList()[i]["data"]["SessionData"]["distance"];

                    int index = -1;
                    var elementValue =
                    _activityDataList.firstWhere((element) =>
                    element.getActivityType.toLowerCase() == modal.getActivityType.toLowerCase()
                        , orElse: () => null);
                    if (elementValue != null) {
                      index = _activityDataList.indexOf(elementValue);
                      double totDist = double.parse(elementValue.getDistance) +
                          double.parse(modal.getDistance);
                      modal.distance = totDist.toStringAsFixed(4).toString();

                      _activityDataList.removeAt(index);
                      _activityDataList.add(modal);
                    } else {
                      double totDist = double.parse(modal.getDistance);
                      modal.distance = totDist.toStringAsFixed(4);
                      _activityDataList.add(modal);
                    }


                    if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('rad').toLowerCase() ||
                        activityType.toLowerCase() == "Remote work".toLowerCase()
                        || activityType.toLowerCase() == "Travail à distance".toLowerCase()) {
                      //remote work -- ges only
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.remoteWorkGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    } else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('trans').toLowerCase() ||
                        activityType.toLowerCase() == "Autobus".toLowerCase() ||
                        activityType.toLowerCase() == "Transit bus".toLowerCase()) {
                      //transit bus --> ges , time, calorie
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      calorieLoop =
                          calorieLoop +
                              (Constants.transitBusCalorie * _weightForCalorie *
                                  (dateUpdatedOn
                                      .difference(dateCreatedOn)
                                      .inMinutes / 60)).toInt();
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.transitBusGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                    else if (activityType.toLowerCase() == 'Vélo'.toLowerCase() ||
                        activityType.toLowerCase() == 'Bike'.toLowerCase() ||activityType .toLowerCase()
                        == DemoLocalizations.of(context).trans('bike').toLowerCase()) {
                      //bicycle --> time, ges, calorie
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      calorieLoop =
                          calorieLoop + (Constants.bikeCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.bikeGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                    else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('carpool').toLowerCase() ||
                        activityType.toLowerCase() == "Covoiturage".toLowerCase() ||
                        activityType.toLowerCase() == "Carpooling".toLowerCase()) {
                      //carpooling -- > ges, time
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.carPoolingGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                    else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('train').toLowerCase() ||
                        activityType.toLowerCase() == "Train".toLowerCase()
                        || activityType.toLowerCase() == "Train".toLowerCase()) {
                      //train --> ges, time, calorie
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      calorieLoop =
                          calorieLoop + (Constants.trainCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).toInt();
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.trainGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                    else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('walk').toLowerCase() ||
                        activityType.toLowerCase() == "Walking".toLowerCase() ||
                        activityType.toLowerCase() == "Marche".toLowerCase()) {
                      //walking --> ges, time, calorie
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      calorieLoop =
                          calorieLoop + (Constants.walkCalories * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.walkGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                    else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('electric') ||
                        activityType.toLowerCase() == "Covoiturage en voiture électrique".toLowerCase()
                        || activityType.toLowerCase() == "Carpooling electric car".toLowerCase()) {
                      //carpooling electric car --> ges , time
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.carPoolElectricCarGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;
                    }
                    else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('metro').toLowerCase() ||
                        activityType.toLowerCase() == "Métro".toLowerCase() ||
                        activityType.toLowerCase() == "Metro".toLowerCase()) {
                      //metro --> ges, time, calorie
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      calorieLoop =
                          calorieLoop + (Constants.metroCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60)).
                          toInt();
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.metroGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                    else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('electric_car').toLowerCase() ||
                        activityType.toLowerCase() == "Voiture électrique".toLowerCase()
                        || activityType.toLowerCase() == "Electric car".toLowerCase()) {
                      //electric car --> ges, time
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.electricCarGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                    else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('run').toLowerCase() ||
                        activityType.toLowerCase() == "Course".toLowerCase() ||
                        activityType.toLowerCase() == "Running".toLowerCase()) {
                      //running --> ges, time, calorie
                      timeLoop = timeLoop + dateUpdatedOn
                          .difference(dateCreatedOn)
                          .inMinutes;
                      calorieLoop = calorieLoop +
                          (Constants.runningCalorie * _weightForCalorie *
                              (dateUpdatedOn
                                  .difference(dateCreatedOn)
                                  .inMinutes / 60))
                              .toInt();
                      totGreenSaved = totGreenSaved + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.runningGES;

                      totGreenDist = totGreenDist + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                    }
                  }
                }

              }
            }

          }
        }else{
          //
          String isDelete = map.values.toList()[i]["delete"] ?? "0";
          if(_sessionType == "Automatic" ||
              _sessionType == "Manual" && map.values
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
              String activityType = map.values
                  .toList()[i]["data"]["SessionData"]["activityType"];

              if (map.values.toList()[i]["data"] != null) {
                String activityType = map.values
                    .toList()[i]["data"]["SessionData"]["activityType"];
                if (double.parse(map.values
                    .toList()[i]["data"]["SessionData"]["distance"]) > 500) {
                  totDistMetre = double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) +
                      totDistMetre;

                  totGreenDist = totGreenDist + double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"])/1000;

                  DashboardActivityModal modal = new DashboardActivityModal();
                  modal.activityType = activityType;
                  modal.distance = map.values
                      .toList()[i]["data"]["SessionData"]["distance"];

                  int index = -1;
                  var elementValue =
                  _activityDataList.firstWhere((element) =>
                  element.getActivityType.toLowerCase() == modal.getActivityType.toLowerCase()
                      , orElse: () => null);
                  if (elementValue != null) {
                    index = _activityDataList.indexOf(elementValue);
                    double totDist = double.parse(elementValue.getDistance) +
                        double.parse(modal.getDistance);
                    modal.distance = totDist.toStringAsFixed(4).toString();

                    _activityDataList.removeAt(index);
                    _activityDataList.add(modal);
                  } else {
                    double totDist = double.parse(modal.getDistance);
                    modal.distance = totDist.toStringAsFixed(4);
                    _activityDataList.add(modal);
                  }


                  if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('rad').toLowerCase() ||
                      activityType.toLowerCase() == "Remote work".toLowerCase() ||
                      activityType.toLowerCase() == "Travail à distance".toLowerCase()) {
                    //remote work -- ges only
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.remoteWorkGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  } else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('trans').toLowerCase() ||
                      activityType.toLowerCase() == "Autobus".toLowerCase() ||
                      activityType.toLowerCase() == "Transit bus".toLowerCase()) {
                    //transit bus --> ges , time, calorie
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    calorieLoop =
                        calorieLoop +
                            (Constants.transitBusCalorie * _weightForCalorie *
                                (dateUpdatedOn
                                    .difference(dateCreatedOn)
                                    .inMinutes / 60)).toInt();
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.transitBusGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == 'Vélo'.toLowerCase() ||
                      activityType.toLowerCase() == 'Bike'.toLowerCase() ||activityType.toLowerCase()
                      == DemoLocalizations.of(context).trans('bike').toLowerCase()) {
                    //bicycle --> time, ges, calorie
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    calorieLoop =
                        calorieLoop + (Constants.bikeCalorie * _weightForCalorie *
                            (dateUpdatedOn
                                .difference(dateCreatedOn)
                                .inMinutes / 60)).
                        toInt();
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.bikeGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('carpool').toLowerCase() ||
                      activityType.toLowerCase() == "Covoiturage".toLowerCase() ||
                      activityType.toLowerCase() == "Carpooling".toLowerCase()) {
                    //carpooling -- > ges, time
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.carPoolingGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('train').toLowerCase() ||
                      activityType.toLowerCase() == "Train".toLowerCase()
                      || activityType.toLowerCase() == "Train".toLowerCase()) {
                    //train --> ges, time, calorie
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    calorieLoop =
                        calorieLoop + (Constants.trainCalories * _weightForCalorie *
                            (dateUpdatedOn
                                .difference(dateCreatedOn)
                                .inMinutes / 60)).toInt();
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.trainGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('walk').toLowerCase() ||
                      activityType.toLowerCase() == "Walking".toLowerCase() ||
                      activityType.toLowerCase() == "Marche".toLowerCase()) {
                    //walking --> ges, time, calorie
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    calorieLoop =
                        calorieLoop + (Constants.walkCalories * _weightForCalorie *
                            (dateUpdatedOn
                                .difference(dateCreatedOn)
                                .inMinutes / 60)).
                        toInt();
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.walkGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('electric').toLowerCase() ||
                      activityType.toLowerCase() == "Covoiturage en voiture électrique".toLowerCase()
                      || activityType.toLowerCase() == "Carpooling electric car".toLowerCase()) {
                    //carpooling electric car --> ges , time
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.carPoolElectricCarGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('metro').toLowerCase() ||
                      activityType.toLowerCase() == "Métro".toLowerCase() ||
                      activityType.toLowerCase() == "Metro".toLowerCase()) {
                    //metro --> ges, time, calorie
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    calorieLoop =
                        calorieLoop + (Constants.metroCalorie * _weightForCalorie *
                            (dateUpdatedOn
                                .difference(dateCreatedOn)
                                .inMinutes / 60)).
                        toInt();
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.metroGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('electric_car').toLowerCase() ||
                      activityType.toLowerCase() == "Voiture électrique".toLowerCase()
                      || activityType.toLowerCase() == "Electric car".toLowerCase()) {
                    //electric car --> ges, time
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.electricCarGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                  else if (activityType.toLowerCase() == DemoLocalizations.of(context).trans('run').toLowerCase() ||
                      activityType.toLowerCase() == "Course".toLowerCase() ||
                      activityType.toLowerCase() == "Running".toLowerCase()) {
                    //running --> ges, time, calorie
                    timeLoop = timeLoop + dateUpdatedOn
                        .difference(dateCreatedOn)
                        .inMinutes;
                    calorieLoop = calorieLoop +
                        (Constants.runningCalorie * _weightForCalorie *
                            (dateUpdatedOn
                                .difference(dateCreatedOn)
                                .inMinutes / 60))
                            .toInt();
                    totGreenSaved = totGreenSaved + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"])/1000 * Constants.runningGES;

                    totGreenDist = totGreenDist + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000 * Constants.aloneGES;

                  }
                }
              }
            }
          }
        }
      }
    }catch(Exc){}
    totDistMetre = totDistMetre / 1000;
    double val = totGreenDist - totGreenSaved;
    store.dispatch(DashboardCaloriesAction(calorieLoop.toString()));
    setState(() {
      runDistance = totDistMetre.toStringAsFixed(2).toString() + ' km';
      greenHouse = val.toStringAsFixed(2).toString() + ' kg';
      double hours = timeLoop / 60; //since both are ints, you get an int
      String hoursString = hours.toStringAsFixed(0); //since both are ints, you get an int
      if (hoursString.length < 2) {
        hoursString = '0' + hoursString;
      }
      int minutes = timeLoop % 60;
      if (minutes.toString().length < 2) {
        time = hoursString + ' : 0' + minutes.toString();
      }else {
        time = hoursString + ' : ' + minutes.toString();
      }
    });

    _allUserInChallenge(store);
    store.dispatch(DashboardLoaderAction(false));

  }


  Future _loadMyChallenges(Store<AppState> store) async {
    challengeData.clear();
    _activityDataList.clear();
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
          if (_index == 1) {
          await getData(store);
          }else{

          }

        }
//        _allUserInChallenge(store);
      }else{
        return null;
      }

    });
//    return 1;
  }




  /*
  * get list of all users who are in same challenge
  * get all sessions of those users
  * then make pie chart
  **/
  Future<void> _allUserInChallenge(Store<AppState> store) async {
    double run = 0;
    double bike = 0;
    double walk = 0;
    double electricCar = 0;
    double drivingAlone = 0;
    double transitBus = 0;
    double vehicle = 0;
    double remoteWork = 0;
    double carPool = 0;
    double carPoolElectric = 0;
    double train = 0;
    double metro = 0;


    List<double> _graphActs = new List();
    List<String> _graphActsName = new List();
//    controllerPie = null;


    _database
        .reference()
        .child(DataBaseConstants.challengeParticipant)
        .orderByChild("idChallenge")
        .equalTo(challengeData[_indexChallenge].challengeId)
        .once()
        .then((snapshot) async {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> map = snapshot.value;
        List<dynamic> userData = map.values.toList()[0]["userData"];

        DateTime startDateWeek = now;
        DateTime endDateWeek = now;
        startDateWeek = now.subtract(new Duration(days: 7));
        startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
        endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);
        print(startDateWeek);
        print(endDateWeek);

        List<User> _us = new List();
        double distanceUser = 0.0;

        for (int i = 0; i < userData.length; i++) {
          var userId = userData[i]['userId'];
          distanceUser = 0.0;
          if(userId.toString() != store.state.userAppModal.userId) {
            var userName = userData[i]['userName'];
            var userIdList = userData[i]['userId'];
            User _userModalDetail = new User();
            _userModalDetail.userId = userIdList;
            _userModalDetail.userName = userName;

            await _database
                .reference()
                .child(DataBaseConstants.sessionData)
                .orderByChild("userId")
                .equalTo(userId)
                .once()
                .then((snapshot) async {
              if (snapshot.value != null) {
                Map<dynamic, dynamic> map = snapshot.value;

                for (int i = 0; i < map.length; i++) {
                  String isDelete = map.values.toList()[i]["delete"] ?? "0";
                  String createdOn = map.values.toList()[i]["createdOn"];
                  DateTime dateFirebase = DateTime(
                    int.parse(createdOn.split(' ')[0].split('-')[0]),
                    int.parse(createdOn.split(' ')[0].split('-')[1]),
                    int.parse(createdOn.split(' ')[0].split('-')[2]),
                  );

                  double dist = double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]);

                  if(dist > 500 && isDelete == "0") {
                    if (dateFirebase.isAtSameMomentAs(endDateWeek) &&
                        dateFirebase.isAtSameMomentAs(startDateWeek) ||
                        dateFirebase.isBefore(endDateWeek) &&
                            dateFirebase.isAfter(startDateWeek) ||
                        dateFirebase.isBefore(endDateWeek) &&
                            dateFirebase.isAtSameMomentAs(startDateWeek) ||
                        dateFirebase.isAtSameMomentAs(endDateWeek) &&
                            dateFirebase.isAfter(startDateWeek)) {
                      distanceUser = distanceUser + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]);

                      String activity = map.values
                          .toList()[i]["data"]["SessionData"]["activityType"];
                      print("act: $activity");

                      if (activity == DemoLocalizations.of(context).trans(
                          'bike') || activity.toLowerCase() == "vélo" ||
                          activity.toLowerCase() == "bike") {
                        //bike
                        bike = bike + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity == DemoLocalizations.of(context)
                          .trans('trans') ||
                          activity.toLowerCase() == "autobus" ||
                          activity.toLowerCase() == "transit bus") {
                        //transit bus
                        transitBus = transitBus + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity == DemoLocalizations.of(context)
                          .trans('carpool') || activity.toLowerCase() ==
                          "covoiturage" ||
                          activity.toLowerCase() == "carpooling") {
                        //car pooling
                        carPool = carPool + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('electric') ||
                          activity.toLowerCase() ==
                              "covoiturage en voiture électrique" ||
                          activity.toLowerCase() == "carpooling electric car") {
                        //carpooling electric car
                        carPoolElectric =
                            carPoolElectric + double.parse(map.values
                                .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('walk') ||
                          activity.toLowerCase() == "marche" || activity
                          .toLowerCase() == "walking") {
                        //walk
                        walk = walk + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('electric_car') ||
                          activity.toLowerCase() == "voiture électrique" ||
                          activity.toLowerCase() == "electric car") {
                        //electric car
                        electricCar = electricCar + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('run') ||
                          activity.toLowerCase() == "course"
                          || activity.toLowerCase() == "running") {
                        //running
                        run = run + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('rad') ||
                          activity.toLowerCase() == "travail à distance" ||
                          activity.toLowerCase() == "remote work") {
                        remoteWork = remoteWork + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else
                      if (activity == DemoLocalizations.of(context).trans('veh')
                          ||
                          activity.toLowerCase() == "in vehicle" ||
                          activity.toLowerCase() == "en véhicule") {
                        //in vehicle and unknown
                        vehicle = vehicle + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('drive') ||
                          activity.toLowerCase() == "conduire seul"
                          || activity.toLowerCase() == "driving alone") {
                        //driving alone
                       /* drivingAlone = drivingAlone + double.parse(map.values
                            .toList()[i]["data"]
                            .values
                            .toList()[1]["distance"]);*/
                      }else if (activity == DemoLocalizations.of(context).trans('train') || activity.toLowerCase() == "Train".toLowerCase()
                          || activity.toLowerCase() == "Train".toLowerCase() ) {
                        //train
                        train = train + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      }else if (activity.toLowerCase() == DemoLocalizations.of(context).trans('metro') ||
                          activity.toLowerCase() == "Métro".toLowerCase() || activity.toLowerCase() == "Metro".toLowerCase()) {
                        //metro
                        metro = metro + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      }
                      _userModalDetail.distance = distanceUser.toString();
                    }
                  }

                }
              }
            });
            _us.add(_userModalDetail);
            store.dispatch(ChallengeParticipantListAction(_us));
          }
        }
        if(bike != 0){
          _graphActs.add(bike);
          _graphActsName.add(DemoLocalizations.of(context).trans("bike"));
        }if(transitBus != 0){
          _graphActs.add(transitBus);
          _graphActsName.add(DemoLocalizations.of(context).trans("trans"));
        }if(carPool != 0){
          _graphActs.add(carPool);
          _graphActsName.add(DemoLocalizations.of(context).trans("carpool"));
        }if(carPoolElectric != 0){
          _graphActs.add(carPoolElectric);
          _graphActsName.add(DemoLocalizations.of(context).trans("electric"));
        }if(walk != 0){
          _graphActs.add(walk);
          _graphActsName.add(DemoLocalizations.of(context).trans("walk"));
        }if(electricCar != 0){
          _graphActs.add(electricCar);
          _graphActsName.add(DemoLocalizations.of(context).trans("electric_car"));
        }if(run != 0){
          _graphActs.add(run);
          _graphActsName.add(DemoLocalizations.of(context).trans("run"));
        }if(remoteWork != 0){
          _graphActs.add(remoteWork);
          _graphActsName.add(DemoLocalizations.of(context).trans("rad"));
        }if(vehicle != 0){
          _graphActs.add(vehicle);
          _graphActsName.add(DemoLocalizations.of(context).trans("veh"));
        }if(drivingAlone != 0){
          _graphActs.add(drivingAlone);
          _graphActsName.add(DemoLocalizations.of(context).trans("drive"));
        }if(train != 0){
          _graphActs.add(train);
          _graphActsName.add(DemoLocalizations.of(context).trans("train"));
        }if(metro != 0){
          _graphActs.add(metro);
          _graphActsName.add(DemoLocalizations.of(context).trans("metro"));
        }
        var total = bike+ transitBus+carPool+carPoolElectric+walk+electricCar+run+remoteWork+vehicle+
            drivingAlone+train+metro;

        if(total == 0.0 ){
          pieChart = 0;
        }else{
          pieChart = 1;
        }
        setState(() {

        });
        _initPieData(2, bike, transitBus,carPool,carPoolElectric,walk,electricCar,run,remoteWork,vehicle,
            drivingAlone,train,metro,total,_graphActs,_graphActsName);


      }
    });
  }


  void _initPieData(int count, double bike, double transitBus, double carPool,  double carPoolElectric,
      double walk, double electricCar, double run, double remoteWork, double vehicle,
      double drivingAlone,double train, double metro, double total, List<double> _graphActs, List<String> _graphActsName) async {
    List<PieEntry> entries = List();

    // NOTE: The order of the entries when being added to the entries array determines their position around the center of
    // the chart.
    double valueRecorded = 0.0;
    for (int i = 0; i < _graphActs.length; i++) {
      valueRecorded = _graphActs[i];
     /* i==0? valueRecorded = bike != 0.0 ? (bike * total) + total / count : 0.0 :
      i==1? valueRecorded = metro != 0.0 ? (metro * total) + total / count : 0.0 :
      i==2? valueRecorded = carPool != 0.0 ? (carPool * total) + total / count : 0.0 :
      i==3? valueRecorded = train != 0.0 ? (train * total) + total / count : 0.0 :
      i==4? valueRecorded = carPoolElectric != 0.0 ? (carPoolElectric * total) + total / count : 0.0 :
      i==5? valueRecorded = walk != 0.0 ? (walk * total) + total / count : 0.0 :
      i==6? valueRecorded = metro != 0.0 ? (metro * total) + total / count : 0.0 :
      i==7? valueRecorded = electricCar != 0.0 ? (electricCar * total) + total / count : 0.0  :
      i==8? valueRecorded = run != 0.0 ? (run * total) + total / count : 0.0  :
      i==9? valueRecorded = remoteWork != 0.0 ? (remoteWork * total) + total / count : 0.0  :
      i==10? valueRecorded = vehicle != 0.0 ? (vehicle * total) + total / count : 0.0 :
      *//*i==11? *//*valueRecorded = drivingAlone != 0.0 ? (drivingAlone * total) + total / count : 0.0 ;*/
      entries.add(PieEntry(
          icon: null,
          value: valueRecorded,
          label: _graphActsName[i]));
    }

    PieDataSet dataSet = new PieDataSet(entries, "Election Results");
//    dataSet.setSliceSpace(3);
//    dataSet.setSelectionShift(5);

    // add a lot of colors
    List<Color> colors = List();
    for (Color c in ColorUtils.VORDIPLOM_COLORS) colors.add(ColorUtils.BLACK);
    for (Color c in ColorUtils.JOYFUL_COLORS) colors.add(ColorUtils.BLUE);
//    for (Color c in ColorUtils.COLORFUL_COLORS) colors.add(c);
//    for (Color c in ColorUtils.LIBERTY_COLORS) colors.add(c);
//    for (Color c in ColorUtils.PASTEL_COLORS) colors.add(c);
//    colors.add(ColorUtils.HOLO_BLUE);
    dataSet.addColor(ColorUtils.HOLO_ORANGE_DARK);
    dataSet.addColor(ColorUtils.RED);
//    dataSet.setColors1(colors);
    dataSet.setSelectionShift(0);

    dataSet.setValueLinePart1OffsetPercentage(80.0);
    dataSet.setValueLinePart1Length(0.2);
    dataSet.setValueLinePart2Length(0.4);

    dataSet.setYValuePosition(ValuePosition.OUTSIDE_SLICE);

    controllerPie.data = PieData(dataSet)
      ..setValueFormatter(_formatter)
      ..setValueTextSize(11)
      ..setValueTextColor(ColorUtils.BLACK);
//      ..setValueTypeface(Util.REGULAR);

    setState(() {});
  }


  /*
  * calculate list of users who have same organisation
  * when tab total personal stats
  * is selected*/
  Future<void> _allUserInOrganisation(Store<AppState> store, String _type) async {
    double bike = 0;
    double transitBus = 0;
    double carPool = 0;
    double carPoolElectric = 0;
    double walk = 0;
    double electricCar = 0;
    double run = 0;
    double remoteWork = 0;
    double vehicle = 0;
    double drivingAlone = 0;
    double train = 0;
    double metro = 0;
    List<double> _graphActs = new List();
    List<String> _graphActsName = new List();

//    controllerPie = null;


    _database
        .reference()
        .child(DataBaseConstants.users)
        .orderByChild("organisationName")
        .equalTo(_prefs.getString(PreferenceNames.orgName))
        .once()
        .then((snapshot) async {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> map = snapshot.value;
        print('iside....');
        //all users with same organisation name
        //add loop below

        //for week is selected at top, get data for last 7 days
        DateTime startDateWeek = now;
        DateTime endDateWeek = now;
        if(_type == "week") {
          if (now.weekday == tuesday) {
            startDateWeek = now.subtract(new Duration(days: 2));
            endDateWeek = now.add(new Duration(days: 5));
          } else if (now.weekday == wednesday) {
            startDateWeek = now.subtract(new Duration(days: 3));
            endDateWeek = now.add(new Duration(days: 4));
          } else if (now.weekday == thursday) {
            startDateWeek = now.subtract(new Duration(days: 4));
            endDateWeek = now.add(new Duration(days: 3));
          } else if (now.weekday == friday) {
            startDateWeek = now.subtract(new Duration(days: 5));
            endDateWeek = now.add(new Duration(days: 2));
          } else if (now.weekday == saturday) {
            startDateWeek = now.subtract(new Duration(days: 6));
          } else if (now.weekday == monday) {
            startDateWeek = now.subtract(new Duration(days: 1));
            endDateWeek = now.add(new Duration(days: 6));
          } else if (now.weekday == sunday) {
            endDateWeek = now.add(new Duration(days: 6));
          }
        }else if(_type == "month"){
          startDateWeek = DateTime(now.year, now.month, 1);
          endDateWeek = DateTime(now.year, now.month, 31);
          if (now.month == 4 ||
              now.month == 6 ||
              now.month == 9 ||
              now.month == 11) {
            endDateWeek = DateTime(now.year, now.month, 30);
          }
        }else if(_type == "year"){
          startDateWeek = DateTime(now.year, 1, 1);
          endDateWeek = DateTime(now.year, 12, 31);
        }
        startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
        endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);
//        List<User> _us = new List();
        List<UserAppModal> list = new List();
        double distanceUser = 0.0;

        for(int i = 0; i < map.length; i++ ){
          distanceUser = 0.0;
//          if(map.values.toList()[i]["userId"]  != store.state.userAppModal.userId) {
            UserAppModal modal = new UserAppModal();
            var firstName = map.values.toList()[i]["firstName"] ?? '';
            var lastName = map.values.toList()[i]["lastName"] ?? '';
            var userId = map.values.toList()[i]["userId"] ?? '';

            modal.firstName = firstName;
            modal.lastName = lastName;
            modal.userId = userId;

            //get all sessions for last 7 days
            //add distance and activity

            await _database
                .reference()
                .child(DataBaseConstants.sessionData)
                .orderByChild("userId")
                .equalTo(userId)
                .once()
                .then((snapshot) async {
              if (snapshot.value != null) {
                Map<dynamic, dynamic> map = snapshot.value;

                for (int i = 0; i < map.length; i++) {
                  String isDelete = map.values.toList()[i]["delete"] ?? "0";
                  String createdOn = map.values.toList()[i]["createdOn"];
                  DateTime dateFirebase = DateTime(
                    int.parse(createdOn.split(' ')[0].split('-')[0]),
                    int.parse(createdOn.split(' ')[0].split('-')[1]),
                    int.parse(createdOn.split(' ')[0].split('-')[2]),
                  );

                  double dist  = 0.0;
                  try{
                    dist = double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]);
                  }
                  catch(Ex){}


                  if(dist > 500 && isDelete == "0") {
                    if (dateFirebase.isAtSameMomentAs(endDateWeek) &&
                        dateFirebase.isAtSameMomentAs(startDateWeek) ||
                        dateFirebase.isBefore(endDateWeek) &&
                            dateFirebase.isAfter(startDateWeek) ||
                        dateFirebase.isBefore(endDateWeek) &&
                            dateFirebase.isAtSameMomentAs(startDateWeek) ||
                        dateFirebase.isAtSameMomentAs(endDateWeek) &&
                            dateFirebase.isAfter(startDateWeek)) {
                      distanceUser = distanceUser + double.parse(map.values
                          .toList()[i]["data"]["SessionData"]["distance"]);

                      String activity = map.values
                          .toList()[i]["data"]["SessionData"]["activityType"];
                      print("act: $activity");

                      if (activity.toLowerCase() ==
                          DemoLocalizations.of(context).trans('bike').toLowerCase() ||
                          activity.toLowerCase() == "vélo" ||
                          activity.toLowerCase() == "bike") {
                        //bike
                        bike = bike + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      } else if (activity.toLowerCase() ==
                          DemoLocalizations.of(context).trans('trans').toLowerCase() ||
                          activity.toLowerCase() == "autobus" ||
                          activity.toLowerCase() == "transit bus") {
                        //transit bus
                        transitBus = transitBus + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      } else if (activity.toLowerCase() == DemoLocalizations.of(context)
                          .trans('carpool').toLowerCase() ||
                          activity.toLowerCase() == "covoiturage" ||
                          activity.toLowerCase() == "carpooling") {
                        //car pooling
                        carPool = carPool + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      } else if (activity.toLowerCase() == DemoLocalizations.of(context)
                          .trans('electric').toLowerCase() ||
                          activity.toLowerCase() ==
                              "covoiturage en voiture électrique" ||
                          activity.toLowerCase() == "carpooling electric car") {
                        //carpooling electric car
                        carPoolElectric = carPoolElectric + double.parse(
                            map.values
                                .toList()[i]["data"]["SessionData"]["distance"]);
                      } else if (activity.toLowerCase() == DemoLocalizations.of(context)
                          .trans('walk').toLowerCase() ||
                          activity.toLowerCase() == "marche" ||
                          activity.toLowerCase() == "walking") {
                        //walk
                        walk = walk + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      }else if (activity ==
                          DemoLocalizations.of(context).trans('electric_car') ||
                          activity.toLowerCase() == "voiture électrique" ||
                          activity.toLowerCase() == "electric car") {
                        //electric car
                        electricCar = electricCar + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('run') ||
                          activity.toLowerCase() == "course"
                          || activity.toLowerCase() == "running") {
                        //running
                        run = run + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('rad') ||
                          activity.toLowerCase() == "travail à distance" ||
                          activity.toLowerCase() == "remote work") {
                        remoteWork = remoteWork + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('veh')
                          ||
                          activity.toLowerCase() == "in vehicle" ||
                          activity.toLowerCase() == "en véhicule") {
                        //in vehicle and unknown
                        vehicle = vehicle + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                      } else if (activity ==
                          DemoLocalizations.of(context).trans('drive') ||
                          activity.toLowerCase() == "conduire seul"
                          || activity.toLowerCase() == "driving alone") {
                        //driving alone
                       /* drivingAlone = drivingAlone + double.parse(map.values
                            .toList()[i]["data"]
                            .values
                            .toList()[1]["distance"]) / 1000;*/
                      }else if (activity == DemoLocalizations.of(context).trans('train') || activity.toLowerCase() == "Train".toLowerCase()
                          || activity.toLowerCase() == "Train".toLowerCase() ) {
                        //train
                        train = train + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      }else if (activity.toLowerCase() == DemoLocalizations.of(context).trans('metro') ||
                          activity.toLowerCase() == "Métro".toLowerCase() || activity.toLowerCase() == "Metro".toLowerCase()) {
                        //metro
                        metro = metro + double.parse(map.values
                            .toList()[i]["data"]["SessionData"]["distance"]);
                      }
                      modal.distance = distanceUser.toString();
                    }
                  }

                }
              }
            });
            list.add(modal);

          }
        store.dispatch(DashboardUsersResponseAction(list));
        if(bike != 0){
          _graphActs.add(bike);
          _graphActsName.add(DemoLocalizations.of(context).trans("bike"));
        }if(transitBus != 0){
          _graphActs.add(transitBus);
          _graphActsName.add(DemoLocalizations.of(context).trans("trans"));
        }if(carPool != 0){
          _graphActs.add(carPool);
          _graphActsName.add(DemoLocalizations.of(context).trans("carpool"));
        }if(carPoolElectric != 0){
          _graphActs.add(carPoolElectric);
          _graphActsName.add(DemoLocalizations.of(context).trans("electric"));
        }if(walk != 0){
          _graphActs.add(walk);
          _graphActsName.add(DemoLocalizations.of(context).trans("walk"));
        }if(electricCar != 0){
          _graphActs.add(electricCar);
          _graphActsName.add(DemoLocalizations.of(context).trans("electric_car"));
        }if(run != 0){
          _graphActs.add(run);
          _graphActsName.add(DemoLocalizations.of(context).trans("run"));
        }if(remoteWork != 0){
          _graphActs.add(remoteWork);
          _graphActsName.add(DemoLocalizations.of(context).trans("rad"));
        }if(vehicle != 0){
          _graphActs.add(vehicle);
          _graphActsName.add(DemoLocalizations.of(context).trans("veh"));
        }if(drivingAlone != 0){
          _graphActs.add(drivingAlone);
          _graphActsName.add(DemoLocalizations.of(context).trans("drive"));
        }if(train != 0){
          _graphActs.add(train);
          _graphActsName.add(DemoLocalizations.of(context).trans("train"));
        }if(metro != 0){
          _graphActs.add(metro);
          _graphActsName.add(DemoLocalizations.of(context).trans("metro"));
        }
        var total = bike+ transitBus+carPool+carPoolElectric+walk+electricCar+run+remoteWork+vehicle+
            drivingAlone+train+metro;

        if(total == 0.0 ){
          pieChart = 0;
        }else{
          pieChart = 1;
        }


        _initPieData(2, bike, transitBus,carPool,carPoolElectric,walk,electricCar,run,remoteWork,vehicle,
            drivingAlone,train,metro,total,_graphActs,_graphActsName);
//        _initBarDatas();

      }
    });
  }



  /*
  * adding controll bars for bar graph*/
  /*for bar graph*/
  Future _initControllerBar(int loopValue) async{
    var desc = Description()..enabled = false;
    _controllersBar = BarChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft.drawGridLines = (false);
          axisLeft.textColor = AppColors.colorBlue;
          axisLeft.drawBottomYLabelEntry = false;
//          axisLeft.drawLabels = false;
          axisLeft.setStartAtZero(true);
          axisLeft.granularityEnabled = false;
          axisLeft.setValueFormatter(MyValueFormatter("\km"));

        },
        legendSettingFunction: (legend, controller) {
          legend.enabled = (false);
          legend.drawInside = false;
        },
        xAxisSettingFunction: (xAxis, controller) {
          if(_index == 0){
            //tab personal stats is selected
            if(_indexDuration== 0){
              //formatting based on days of week
              xAxis
                ..position = (XAxisPosition.BOTTOM)
                ..setValueFormatter(WeekFormatter(controller,context))
                ..drawGridLines = (false);
            }else if(_indexDuration == 1){
              //formatting based on month
              xAxis
                ..position = (XAxisPosition.BOTTOM)
                ..setValueFormatter(MonthFormatter(controller,context))
                ..drawGridLines = (false);
            }else{
              //year format
              xAxis
                ..position = (XAxisPosition.BOTTOM)
                ..setValueFormatter(YearFormatter(controller,context))
                ..drawGridLines = (false);
            }
          }else{
            //tab challenge is selected
            xAxis
              ..position = (XAxisPosition.BOTTOM)
              ..setValueFormatter(WeekFormatter(controller,context))
              ..drawGridLines = (false);
          }

        },
        pinchZoomEnabled: false,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        fitBars: true,
        drawBarShadow: false,
        description: desc);
  }



  /*
  * get last 7 sessions*/
  Future<void> _distanceData(Store<AppState> store, String _type) async {
    int _loopValue = 0;
    List<double> _listDistance = new List();
    _controllersBar = null;
    String sortDbValue = "currentDay";
    String formatterDbValue = "'yyyy-MM-dd'";

    DateTime todayDate = DateTime.now();
    DateTime startDateWeek = now;
    DateTime endDateWeek = now;

    if(_type == "week"){
      if (now.weekday == tuesday) {
        startDateWeek = now.subtract(new Duration(days: 2));
        endDateWeek = now.add(new Duration(days: 5));
      } else if (now.weekday == wednesday) {
        startDateWeek = now.subtract(new Duration(days: 3));
        endDateWeek = now.add(new Duration(days: 4));
      } else if (now.weekday == thursday) {
        startDateWeek = now.subtract(new Duration(days: 4));
        endDateWeek = now.add(new Duration(days: 3));
      } else if (now.weekday == friday) {
        startDateWeek = now.subtract(new Duration(days: 5));
        endDateWeek = now.add(new Duration(days: 2));
      } else if (now.weekday == saturday) {
        startDateWeek = now.subtract(new Duration(days: 6));
      } else if (now.weekday == monday) {
        startDateWeek = now.subtract(new Duration(days: 1));
        endDateWeek = now.add(new Duration(days: 6));
      } else if (now.weekday == sunday) {
        endDateWeek = now.add(new Duration(days: 6));
      }
      _loopValue = 6;
      startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
      endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);
      todayDate = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
    }
    else if(_type == "month"){
      startDateWeek = DateTime(now.year, now.month, 1);
      endDateWeek = DateTime(now.year, now.month, 31);
      if (now.month == 4 ||
          now.month == 6 ||
          now.month == 9 ||
          now.month == 11) {
        endDateWeek = DateTime(now.year, now.month, 30);
      }
      _loopValue = 30;
      startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
      endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);
      todayDate = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
    }else if(_type == "year"){
      if(now.month  < 6){
        startDateWeek = DateTime(now.year, 1, 1);
        _loopValue = now.month - 1;
      }else{
        startDateWeek = DateTime(now.year, now.month - 6, 1);
        _loopValue = 5;
      }
      endDateWeek = DateTime(now.year, now.month, 31);
      sortDbValue = "sessionYear";
      formatterDbValue = "yyyy-MM";
      startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
      endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);
      print("start: $startDateWeek");
      todayDate = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
    }
    print("aaaaa: $startDateWeek");
    var vv = todayDate.toString().split(" ")[0];
    print("aaaaa: $vv");


    double distanceUser = 0.0;
    for (int j = 0; j <= _loopValue; j++) {
      distanceUser = 0.0;
      await _database
          .reference()
          .child(DataBaseConstants.sessionData)
          .orderByChild(sortDbValue)
          .equalTo(todayDate.toString().split(" ")[0])
          .once()
          .then((snapshot) async {
        if (snapshot.value != null) {
          //all sessions for a day
          Map<dynamic, dynamic> map = snapshot.value;
          print(map);
          distanceUser = 0.0;
          print(_prefs.getString(PreferenceNames.orgName));
          for (int i = 0; i < map.length; i++) {
            //get all sessions for a day for an user.
            //....add filter for user now..get all user with same organisation
            var vv = _prefs.getString(PreferenceNames.orgName);
            var avv = _prefs.getString(PreferenceNames.orgName);

            await _database.reference()
                .child(DataBaseConstants.users)
                .orderByChild("organisationName")
                .equalTo(_prefs.getString(PreferenceNames.orgName))
                .once().then((snapshot2) async {
              Map<dynamic, dynamic> map2 = snapshot2.value;
              for (int j = 0; j < map2.length; j++) {
                String activityType = map.values
                    .toList()[i]["data"]["SessionData"]["activityType"];
                String isDelete = map.values.toList()[i]["delete"] ?? "0";

                if( activityType.toLowerCase() == DemoLocalizations.of(context).trans('rad').toLowerCase() ||
              activityType.toLowerCase() == "Remote work".toLowerCase() || activityType.toLowerCase()
              == "Travail à distance".toLowerCase() || activityType == DemoLocalizations.of(context).trans('trans') ||
                    activityType.toLowerCase() == "Autobus".toLowerCase() ||
                    activityType.toLowerCase() == "Transit bus".toLowerCase() ||
                    activityType.toLowerCase() == 'Vélo'.toLowerCase() ||
                    activityType.toLowerCase() == 'Bike'.toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans('bike').toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans('carpool').toLowerCase() ||
                    activityType.toLowerCase() == "Covoiturage".toLowerCase() ||
                    activityType.toLowerCase() == "Carpooling".toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans('train').toLowerCase() ||
                    activityType.toLowerCase() == "Train".toLowerCase()
                    || activityType.toLowerCase() == "Train".toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans('walk').toLowerCase() ||
                    activityType.toLowerCase() == "Walking".toLowerCase() ||
                    activityType.toLowerCase() == "Marche".toLowerCase() || activityType.toLowerCase() == "walk".toLowerCase() ||
                    activityType.toLowerCase() == "Walking".toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans('electric').toLowerCase() ||
                    activityType.toLowerCase() == "Covoiturage en voiture électrique".toLowerCase()
                    || activityType.toLowerCase() == "Carpooling electric car".toLowerCase()
                    || activityType.toLowerCase() == DemoLocalizations.of(context).trans('metro').toLowerCase() ||
                    activityType.toLowerCase() == "Métro".toLowerCase() ||
                    activityType.toLowerCase() == "Metro".toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans('electric_car').toLowerCase() ||
                    activityType.toLowerCase() == "Voiture électrique".toLowerCase()
                    || activityType.toLowerCase() == "Electric car".toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans('run').toLowerCase() ||
                    activityType.toLowerCase() == "Course".toLowerCase() ||
                    activityType.toLowerCase() == "Running".toLowerCase()) {
                  if (map2.values.toList()[j]["userId"] ==
                      map.values.toList()[i]["userId"] && double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) > 500 && isDelete == "0")
                    distanceUser = distanceUser + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                }
              }
            });
          }
        }
      });
      _listDistance.add(distanceUser);
      todayDate = todayDate.add(new Duration(days: 1));
      if(_type == "year"){
        if (now.month == 4 ||
            now.month == 6 ||
            now.month == 9 ||
            now.month == 11) {
          todayDate = todayDate.add(new Duration(days: 30));
        }else{
          todayDate = todayDate.add(new Duration(days: 31));
        }

      }

      print(todayDate.toString());
      print(_listDistance.length.toString());
    }

    await _initControllerBar(_loopValue);
     _initBarDatas(_listDistance);
  }


  /*
  * get last 7 sessions when challenge tab is selected*/
  Future<void> _distanceDataChallenge(Store<AppState> store, String _type) async {
    int _loopValue = 0;
    List<double> _listDistance = new List();
    _controllersBar = null;

    DateTime todayDate = now;
    DateTime startDateWeek = now;
    DateTime endDateWeek = now;
    if (now.weekday == tuesday) {
      startDateWeek = now.subtract(new Duration(days: 2));
      endDateWeek = now.add(new Duration(days: 5));
    } else if (now.weekday == wednesday) {
      startDateWeek = now.subtract(new Duration(days: 3));
      endDateWeek = now.add(new Duration(days: 4));
    } else if (now.weekday == thursday) {
      startDateWeek = now.subtract(new Duration(days: 4));
      endDateWeek = now.add(new Duration(days: 3));
    } else if (now.weekday == friday) {
      startDateWeek = now.subtract(new Duration(days: 5));
      endDateWeek = now.add(new Duration(days: 2));
    } else if (now.weekday == saturday) {
      startDateWeek = now.subtract(new Duration(days: 6));
    } else if (now.weekday == monday) {
      startDateWeek = now.subtract(new Duration(days: 1));
      endDateWeek = now.add(new Duration(days: 6));
    } else if (now.weekday == sunday) {
      endDateWeek = now.add(new Duration(days: 6));
    }
    startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
    endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);



    _loopValue = 6;

    startDateWeek = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);
    endDateWeek = DateTime(endDateWeek.year,endDateWeek.month,endDateWeek.day);
    todayDate = DateTime(startDateWeek.year,startDateWeek.month,startDateWeek.day);

    var gg = DateFormat('yyyy-MM-dd').format(todayDate);
    print(gg);

    double distanceUser = 0.0;
    for (int j = 0; j <= _loopValue; j++) {
      distanceUser = 0.0;
      await _database
          .reference()
          .child(DataBaseConstants.sessionData)
          .orderByChild("currentDay")
          .equalTo(DateFormat('yyyy-MM-dd').format(todayDate))
          .once()
          .then((snapshot) async {
        if (snapshot.value != null) {
          //all sessions for a day
          Map<dynamic, dynamic> map = snapshot.value;
          print("map");
          print(map);
          distanceUser = 0.0;
          var hj = _prefs.getString(PreferenceNames.orgName);
          print(_prefs.getString(PreferenceNames.orgName));
          for (int i = 0; i < map.length; i++) {
            //get all sessions for a day for an user.
            //....add filter for user now..get all user with same organisation
            await _database.reference()
                .child(DataBaseConstants.challengeParticipant)
                .orderByChild("idChallenge")
                .equalTo(challengeData[_indexChallenge].challengeId)
                .once().then((snapshot2) async {
              Map<dynamic, dynamic> map2 = snapshot2.value;
              for (int j = 0; j < map2.length; j++) {
                String activityType = map.values
                    .toList()[i]["data"]["SessionData"]["activityType"];
                String isDelete = map.values.toList()[i]["delete"] ?? "0";
                if (activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('rad').toLowerCase() ||
                    activityType.toLowerCase() == "Remote work".toLowerCase() ||
                    activityType.toLowerCase()
                        == "Travail à distance".toLowerCase() || activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('trans').toLowerCase() ||
                    activityType.toLowerCase() == "Autobus".toLowerCase() ||
                    activityType.toLowerCase() == "Transit bus".toLowerCase() ||
                    activityType.toLowerCase() == 'Vélo'.toLowerCase() ||
                    activityType.toLowerCase() == 'Bike'.toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('bike').toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('carpool').toLowerCase() ||
                    activityType.toLowerCase() == "Covoiturage".toLowerCase() ||
                    activityType.toLowerCase() == "Carpooling".toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('train').toLowerCase() ||
                    activityType.toLowerCase() == "Train".toLowerCase()
                    || activityType.toLowerCase() == "Train".toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('walk').toLowerCase() ||
                    activityType.toLowerCase() == "Walking".toLowerCase() ||
                    activityType.toLowerCase() == "Marche".toLowerCase() || activityType.toLowerCase() ==
                    "walk".toLowerCase() || activityType.toLowerCase() == "Walking" ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans(
                        'electric').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Covoiturage en voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Carpooling electric car".toLowerCase() ||
                    activityType.toLowerCase() == DemoLocalizations.of(context).trans(
                        'metro').toLowerCase() ||
                    activityType.toLowerCase() == "Métro".toLowerCase() ||
                    activityType.toLowerCase() == "Metro".toLowerCase() ||
                    activityType.toLowerCase() ==
                        DemoLocalizations.of(context).trans('electric_car').toLowerCase() ||
                    activityType.toLowerCase() ==
                        "Voiture électrique".toLowerCase()
                    || activityType.toLowerCase() ==
                        "Electric car".toLowerCase() || activityType.toLowerCase() ==
                    DemoLocalizations.of(context).trans('run').toLowerCase() ||
                    activityType.toLowerCase() == "Course".toLowerCase() ||
                    activityType.toLowerCase() == "Running".toLowerCase()) {
                  if (map2.values.toList()[j]["userId"] ==
                      map.values.toList()[i]["userId"] && double.parse(map.values
                      .toList()[i]["data"]["SessionData"]["distance"]) > 500 && isDelete == "0")
                    distanceUser = distanceUser + double.parse(map.values
                        .toList()[i]["data"]["SessionData"]["distance"]) / 1000;
                }
              }
            });
          }
        }
      });
      _listDistance.add(distanceUser);
      todayDate = todayDate.add(new Duration(days: 1));
      print(todayDate.toString());
      print(_listDistance.length.toString());
    }

    await _initControllerBar(_loopValue);
     _initBarDatas(_listDistance);
  }


//init controller for bar graph...
  Future _initBarDatas(List<double> listDistance) async{
    _controllersBar.data = await generateData(0, listDistance.length, listDistance);
    setState(() {

    });
  }

  //bar data generated here...
  Future<BarData> generateData(int cnt, int loop, List<double> valueY) async{
    List<BarEntry> entries = List();
    for (int i = 0; i < valueY.length; i++) {
      Object ob = "M";
      entries
          .add(BarEntry(x: i.toDouble(), y: valueY[i], data: ob));
//      _controllersBar.data.setValueFormatter(YearFormatter(controller));

    }

    BarDataSet d = BarDataSet(entries, "");
    d.setColors1(AppColors.VORDIPLOM_COLORS);
    d.setBarShadowColor(Color.fromARGB(255, 203, 203, 203));
    d.setDrawValues(false);

    List<IBarDataSet> sets = List();
    sets.add(d);

    BarData cd = BarData(sets);
    cd.barWidth = (0.9);
    _controllersBar.highLightPerTapEnabled = false;
    _controllersBar.highlightFullBarEnabled = false;

//    _controllersBar.data.setValueFormatter(DayAxisValue1Formatter(controller));

    return cd;
  }

}

class _DashModel {
  final Store<AppState> store;
  final bool loader;
  final double dashPercent;
  final String dashCalorie;
  final List<User> listParticipant;
  final List<UserAppModal> listUser;

  _DashModel(this.store, this.loader, this.dashPercent, this.dashCalorie, this.listParticipant, this.listUser);

  factory _DashModel.create(Store<AppState> store, BuildContext context) {
    return _DashModel(store, store.state.loaderDashboard, store.state.dashboardPercent,
    store.state.dashboardCalories,store.state.listParticipant, store.state.listUserDashboard);
  }
}
