import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/challenge_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_challenge_data_modal.dart';
import 'package:greenplayapp/redux/model/challenge_list_response.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/database/prefs_singleton.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:greenplayapp/redux/model/challenge_data.dart' as prefixchallenge;


import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class NewsFeedTabPage extends StatefulWidget {
  @override
  _NewsFeedTabPageState createState() => _NewsFeedTabPageState();
}

class _NewsFeedTabPageState extends State<NewsFeedTabPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Store<AppState> store;
  SharedPreferences _prefs;
  ChallengeResponse _response = new ChallengeResponse();
  ChallengeResponse _responseAvoided = new ChallengeResponse();
  var refreshKeyAll = GlobalKey<RefreshIndicatorState>();



  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return StoreConnector<AppState, _NewsModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _NewsModel.create(store, context);
        }, onInit: (store) async {
//      _dbInit(store);
      getChallengeList();
    }, builder: (BuildContext context, _NewsModel data) {
      return Scaffold(
        backgroundColor: AppColors.colorWhite,
        body: Container(
          color: AppColors.colorBlue,
          child:
          Scaffold(
            backgroundColor: AppColors.colorBgGray,
            body:
            Container(
              child:
              Column(
                children: <Widget>[
                  Expanded(
                    child : RefreshIndicator(
                      key: refreshKeyAll,
                      onRefresh: _getData,
                      child: ListView.builder(
                          itemCount: _response.data != null ? _response.data.length > 10 ? 10 : _response.data.length : 0,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return _card(context, index);
                          }),), )
                ],
              )
            )
          ),
        ),
      );
    });
  }


  Future<void> _getData() async {
    refreshKeyAll.currentState?.show(
        atTop:
        true);
    await getChallengeList();
  }


  /*Each card view for news feed detail*/
  Widget _card(BuildContext context, int index) {
    return InkWell(
      onTap: () {
//        store.dispatch(ChallengeParticipantListAction(new List()));
//        Keys.navKey.currentState
//            .pushNamed(Routes.challengeDetailScreen, arguments: index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: AppColors.colorWhite),
                ),
                elevation: 0.0,
                color: AppColors.colorWhite,
                child: Row(
                  children: <Widget>[
                    _userImage(context),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        _textDetailHeader(context, index),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.003,
                        ),
                        _textDescription(context, index),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.001,
                        ),
                        _textDate(context, index),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.009,
                        )
                      ],
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  /*Top user image......*/
  Widget _userImage(BuildContext context) {
    return
      Container(
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
                          image: AssetImage(
                            'asset/placeholder.png',
                          )),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
  }

  /*package text heading*/
  Widget _textDetailHeader(BuildContext context, int index) {
    return
      Align(
        alignment: Alignment.topLeft,
        child:
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: ScreenUtil.getInstance().setWidth(220),
          child: Text(
            _response.data[index].challengeName ?? '',
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: GoogleFonts.openSans(
              fontSize: ScreenUtil.getInstance().setWidth(17),
              color: Color(0xFF353535),
              fontWeight: FontWeight.w500,
            ),
              textScaleFactor: 1.0
          ),
        ),
      );
  }

  Widget _textDescription(BuildContext context, int index) {
    return
      Align(
        alignment: Alignment.topLeft,
        child:
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: ScreenUtil.getInstance().setWidth(220),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.directions_run,
                color: AppColors.colorWhiteLight,
                size: 20,
              ),
          Expanded(child:Text(
                _response.data[index].description ?? '',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: GoogleFonts.openSans(
                  fontSize: ScreenUtil.getInstance().setWidth(13),
                  color: Color(0xFF353535),
                  fontWeight: FontWeight.w400,
                ),
                  textScaleFactor: 1.0
              ))
            ],
          ),
        ),
      );
  }

  /*package text heading*/
  Widget _textDate(BuildContext context, int index) {
    return
      Flexible(
        fit: FlexFit.loose,
        child:
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: ScreenUtil.getInstance().setWidth(200),
            margin: EdgeInsets.fromLTRB(20, 5, 10, 20),
            child: Text(
                DemoLocalizations.of(context).trans('from') +" "+ GetMonth.getMonth
                  (_response.data[index].startDate.toString().toString(),context )
                    +" " + DemoLocalizations.of(context).trans('to')
                    + " "+GetMonth.getMonth
                  (_response.data[index].endDate.toString(),context )
              /*DemoLocalizations.of(context).trans('from') +
                  new DateFormat("dd MMMM yyyy").format(DateTime.parse(_response.data[index].startDate.toString()) )
                  + DemoLocalizations.of(context).trans('to')
                  + new DateFormat("dd MMMM yyyy").format(DateTime.parse(_response.data[index].endDate.toString()) )*/,
              style: GoogleFonts.openSans(
                fontSize: ScreenUtil.getInstance().setWidth(13),
                color: Color(0xFF353535),
                fontWeight: FontWeight.w400,
              ),
                textScaleFactor: 1.0
            ),
          ),
        ),
      );
  }


  Future<ChallengeResponse> getChallengeList() async {
    _response.data = new List();
    _responseAvoided.data = new List();
    _prefs = PrefsSingleton.prefs;

    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(DataBaseConstants.allChallenge)
        .once();
    Map notificationMap = snapshot.value;
    if (notificationMap != null) {
      var chatList = snapshot.value; //-M5e8eLYYEPAsbYHTpcl
      Map<dynamic, dynamic> chatListMap = chatList;
      for (int i = 0; i < chatListMap.values.toList()[0].length; i++) {
        Map<dynamic, dynamic> v22 = chatListMap.values.toList()[0];
        var element =
        chatListMap[chatListMap.keys.elementAt(0)][v22.keys.elementAt(i)];
        prefixchallenge.Data _modal = new prefixchallenge.Data();
        String value = _prefs.getString(PreferenceNames.id) ?? "";

        _modal.idChallenge = element['idChallenge'];
        _modal.challengeName = element['ChallengeName'] ?? '-';
        _modal.createdBy = element['createdBy'] ?? '-';
        _modal.description = element['Description'] ?? '-';
        _modal.challengeType = element['ChallengeType'] ?? '';
        _modal.challengeDistance = element['ChallengeDistance'] ?? '0';
        _modal.scheduleType = element['ScheduleType'] ?? '-';
        String startDate = element['StartDate'];
        if (startDate != null) {
          if (startDate.split('-')[1].length == 1) {
            startDate =
                startDate.split('-')[0] + '-0' + startDate.split('-')[1] +
                    '-' + startDate.split('-')[2];
          }
          if (startDate.split('-')[2].length == 1) {
            startDate =
                startDate.split('-')[0] + '-' + startDate.split('-')[1] +
                    '-0' + startDate.split('-')[2];
          }
        } else {
          String month = DateTime
              .now()
              .month
              .toString()
              .length == 1 ? '0' + DateTime
              .now()
              .month
              .toString() : DateTime
              .now()
              .month
              .toString();
          String day = DateTime
              .now()
              .day
              .toString()
              .length == 1 ? '0' + DateTime
              .now()
              .day
              .toString() : DateTime
              .now()
              .day
              .toString();
          startDate = DateTime
              .now()
              .year
              .toString() +
              '-' +
              month +
              '-' +
              day;
        }

        String endDate = element['EndDate'];
        if (endDate != null) {
          if (endDate.split('-')[1].length == 1) {
            endDate =
                endDate.split('-')[0] + '-0' + endDate.split('-')[1] + '-' +
                    endDate.split('-')[2];
          }
          if (endDate.split('-')[2].length == 1) {
            endDate =
                endDate.split('-')[0] + '-' + endDate.split('-')[1] + '-0' +
                    endDate.split('-')[2];
          }
        } else {
          String month = DateTime
              .now()
              .month
              .toString()
              .length == 1 ? '0' + DateTime
              .now()
              .month
              .toString() : DateTime
              .now()
              .month
              .toString();
          String day = DateTime
              .now()
              .day
              .toString()
              .length == 1 ? '0' + DateTime
              .now()
              .day
              .toString() : DateTime
              .now()
              .day
              .toString();
          endDate = DateTime
              .now()
              .year
              .toString() +
              '-' +
              month +
              '-' +
              day;
        }
        _modal.endDate = endDate;
        _modal.startDate = startDate;
        if(!value.contains(element['idChallenge']) ) {
          _response.data.add(_modal);
        }else{
          _responseAvoided.data.add(_modal);
        }
        print(_response.data.length.toString());
        if(_prefs.getString(PreferenceNames.id) == null){
          _prefs.setString(PreferenceNames.id, _modal.idChallenge);
        }
        else if( i != chatListMap.values.toList()[0].length - 1){
          _prefs.setString(PreferenceNames.id, _modal.idChallenge+","+_prefs.getString(PreferenceNames.id));
        }
        print(_prefs.getString(PreferenceNames.id));
      }
//      _responseAvoided.data = _responseAvoided.data.reversed.toList();
      if(_response.data.length < 10){
        _response.data.addAll( _responseAvoided.data);
      }
      setState(() {

      });
    } else {

    }

    return null;
  }


}

class _NewsModel {
  final Store<AppState> store;
  final bool loader;
  final ChallengeResponse challengeResponse;

  _NewsModel(this.store, this.loader, this.challengeResponse);

  factory _NewsModel.create(Store<AppState> store, BuildContext context) {
    return _NewsModel(
        store, store.state.challengeLoaderAll, store.state.challengeListResponse);
  }
}

