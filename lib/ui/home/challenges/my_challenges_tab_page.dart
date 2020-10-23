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
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

class ChallengeTabScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChallengeTabScreenState();
  }
}

class _ChallengeTabScreenState extends State<ChallengeTabScreen> {
  int _index = 0; //default tab

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  Store<AppState> store;

  var refreshKeyAll = GlobalKey<RefreshIndicatorState>();
  var refreshKeyActive = GlobalKey<RefreshIndicatorState>();
  var refreshKeyNext = GlobalKey<RefreshIndicatorState>();
  var refreshKeyPast = GlobalKey<RefreshIndicatorState>();

  var _styleTab = GoogleFonts.poppins(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorBlack,
    fontWeight: FontWeight.w500,
  );



  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)
      ..init(context);
    return StoreConnector<AppState, _ChallengeModel>(
        converter: (Store<AppState> store) {
          this.store = store;
          return _ChallengeModel.create(store, context);
        },
        onInit: (store) async {
          store.dispatch(ChallengeLoaderAction(true));
          await store.dispatch(ChallengeApiAction(context));
//          _loadMyChallenges(store);
//          store.dispatch(ChallengeApiAction(context));
        },
        builder: (BuildContext context, _ChallengeModel data) {
          return
      Scaffold(
        backgroundColor: AppColors.colorBgGray,
        body:
        data.loader
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
        Stack(
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(top: 50),
              child:
              _index == 0 ?
              Container(
                  margin: EdgeInsets.only(top: 5),
                  child: data.challengeResponse.data != null &&  data.challengeResponse.data.length > 0 ?
                  _listAllChallenge(data) :
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child :
                      Align(
                        child:
                        Text(
                          DemoLocalizations.of(context).trans('no_challenge'),
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

              )
                  :
              _index == 1 ?data._listChallengeActive.length > 0 ? _listActiveChallenge(data) :
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child :
                  Align(
                    child:
                    Text(
                      DemoLocalizations.of(context).trans('no_challenge'),
                      style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.display1,
                        fontSize: ScreenUtil.getInstance().setWidth(15),
                        color: AppColors.colorBlueLanding,
                        fontWeight: FontWeight.w400,
                      ),
                        textScaleFactor: 1.0
                    ),
                    alignment: Alignment.center,
                  )):
              _index == 2 ?
              data._listChallengeNext.length > 0 ? _listNextChallenge(data) :
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child :
                  Align(
                    child:
                    Text(
                      DemoLocalizations.of(context).trans('no_challenge'),
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
                  :
              data._listChallengePast.length > 0 ? _listPastChallenge(data) :
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child :
                  Align(
                    child:
                    Text(
                      DemoLocalizations.of(context).trans('no_challenge'),
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
            ),



            Container(
              margin: EdgeInsets.only(top: 15,left: 5,right: 5),
              child:
              SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _tabAllChallenge(),

                    _tabActive(),

                    _tabNext(),

                    _tabPast()
                  ],
                ),
              ),
            ),


          ],
        )
    );
  });
  }


  Widget _tabAllChallenge() {
    return
      Expanded(
          child:
          InkWell(
            onTap:(){
              setState(() {
                _index = 0;
              });
            } ,
            child:
            Container(
              height: 40.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      DemoLocalizations.of(context).trans('challenge_all').toUpperCase(),
                      style: _styleTab,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width,height: 2,
                    color: _index == 0 ? AppColors.colorBlue : Colors.transparent,)
                ],
              ),
            ),
          ));
  }


  Widget _tabActive() {
    return
      Expanded(
          child:
          InkWell(
            onTap:(){
              setState(() {
                _index = 1;
              });
            } ,
            child:
            Container(
              height: 40.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      DemoLocalizations.of(context).trans('active').toUpperCase(),
                      style: _styleTab,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width,height: 2,
                    color: _index == 1 ? AppColors.colorBlue : Colors.transparent,)
                ],
              ),
            ),
          ));
  }

  Widget _tabNext() {
    return
      Expanded(
          child:
          InkWell(
            onTap:(){
              setState(() {
                _index = 2;
              });
            } ,
            child:
            Container(
              height: 40.0,
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      DemoLocalizations.of(context).trans('next').toUpperCase(),
                      style: _styleTab,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width,height: 2,
                    color: _index == 2 ? AppColors.colorBlue : Colors.transparent,)
                ],
              ),
            ),
          ));
  }

  Widget _tabPast() {
    return
      Expanded(
          child:
          InkWell(
            onTap:(){
              setState(() {
                _index = 3;
              });
            } ,
            child:
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
//              margin: EdgeInsets.only(left: 50.0, right: 50.0),
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      DemoLocalizations.of(context).trans('past').toUpperCase(),
                      style: _styleTab,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width,height: 2,
                    color: _index == 3 ? AppColors.colorBlue : Colors.transparent,)
                ],
              ),
            ),
          ));
  }

  Widget _listAllChallenge(_ChallengeModel data) {
    return
      Column(
        children: <Widget>[
          Expanded(
            child : RefreshIndicator(
              key: refreshKeyAll,
              onRefresh: _getData,
              child: ListView.builder(
                  itemCount: data.challengeResponse.data.length,
//          physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return _cardAll(data, index);
                  }),), )
        ],
      )
    ;
  }

  Future<void> _getData() async {
    refreshKeyAll.currentState?.show(
        atTop:
        true);
    await store.dispatch(ChallengeApiAction(context));
  }


  Widget _listActiveChallenge(_ChallengeModel data) {
    return
      Column(
        children: <Widget>[
          Expanded(
            child:
            RefreshIndicator(
              key: refreshKeyActive,
              onRefresh: _getDataActive,
              child:ListView.builder(
                itemCount: data._listChallengeActive.length,
//                physics: NeverScrollableScrollPhysics(), ///
                shrinkWrap: true, ///
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return _cardActive(data,index);
                }
            ),)
          )
        ],
      );
  }

  Future<void> _getDataActive() async {
    refreshKeyActive.currentState?.show(
        atTop:
        true);
    await store.dispatch(ChallengeApiAction(context));
  }

  Widget _listNextChallenge(_ChallengeModel data) {
    return
     Column(
       children: <Widget>[
         Expanded(
           child:
           Container(
             child:
             RefreshIndicator(
               key: refreshKeyNext,
               onRefresh: _getDataNext,
               child:new ListView.builder(
                 itemCount: data._listChallengeNext.length,
//                 physics: NeverScrollableScrollPhysics(), ///
                 shrinkWrap: true, ///
                 scrollDirection: Axis.vertical,
                 itemBuilder: (BuildContext context, int index) {
                   return _cardNext(data,index);
                 }
             ),)
           ),
         )
       ],
     );
  }

  Future<void> _getDataNext() async {
    refreshKeyNext.currentState?.show(
        atTop:
        true);
    await store.dispatch(ChallengeApiAction(context));
  }

  Widget _listPastChallenge(_ChallengeModel data) {
    return
     Column(
       children: <Widget>[
         Expanded(
           child:
           Container(
             child:
             RefreshIndicator(
               key: refreshKeyPast,
               onRefresh: _getDataPast,
               child:new ListView.builder(
                 itemCount: data._listChallengePast.length,
//                 physics: NeverScrollableScrollPhysics(), ///
                 shrinkWrap: true, ///
                 scrollDirection: Axis.vertical,
                 itemBuilder: (BuildContext context, int index) {
                   return _cardPast(data,index);
                 }
             ),)
           ),
         )
       ],
     );
  }

  Future<void> _getDataPast() async {
    refreshKeyPast.currentState?.show(
        atTop:
        true);
    await store.dispatch(ChallengeApiAction(context));
  }

  Widget _cardAll(_ChallengeModel data, int index) {
    return InkWell(
      onTap: () {
        store.dispatch(ChallengeParticipantListAction(new List()));
        Keys.navKey.currentState
            .pushNamed(Routes.challengeDetailScreen, arguments: index);
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
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child:
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: ScreenUtil.getInstance().setWidth(220),
                            child: Text(
                              data.challengeResponse.data[index].challengeName ?? '',
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: GoogleFonts.openSans(
                                fontSize: ScreenUtil.getInstance().setWidth(17),
                                color: Color(0xFF353535),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.003,
                        ),
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
                                Expanded(child: Text(
                                  data.challengeResponse.data[index].description ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: GoogleFonts.openSans(
                                    fontSize: ScreenUtil.getInstance().setWidth(13),
                                    color: Color(0xFF353535),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.001,
                        ),

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
                                  (data.challengeResponse.data[index].startDate.toString(),context )
                                   +" " + DemoLocalizations.of(context).trans('to')
                                    + " "+GetMonth.getMonth
                                    (data.challengeResponse.data[index].endDate.toString(),context ),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(13),
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
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


  /*Each card view for newsfeed detail*/
  Widget _cardActive(_ChallengeModel data, int index){
    return
      InkWell(
        onTap:() {
//          Keys.navKey.currentState.pushNamed(Routes.challengeDetailScreen);
        } ,
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.015,),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child:
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),side : BorderSide(color: AppColors.colorWhite),
                  ),
                  elevation: 0.0,
                  color: AppColors.colorWhite,
                  child:
                  Row(
                    children: <Widget>[
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
                                          )
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.02,),
                          Align(
                            alignment: Alignment.topLeft,
                            child:
                            Container(
                              width: ScreenUtil.getInstance().setWidth(220),
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Text(data._listChallengeActive[index].challengeName,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(17),
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),


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
                                  Expanded(child: Text(
                                    data._listChallengeActive[index].challengeDescription ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: GoogleFonts.openSans(
                                      fontSize: ScreenUtil.getInstance().setWidth(13),
                                      color: Color(0xFF353535),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.topLeft,
                            child:
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                              child: Text(DemoLocalizations.of(context).trans('from') + " "+
                                  GetMonth.getMonth
                                    (data._listChallengeActive[index].challengeStartDate.toString(),context )
                                  + ' ' +
                                  DemoLocalizations.of(context).trans('to')
                                  +" "+ GetMonth.getMonth
                                (data._listChallengeActive[index].challengeEndDate.toString(), context),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(13),
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.009,)
                        ],
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
      );
  }


  /*Each card view for newsfeed detail*/
  Widget _cardPast(_ChallengeModel data, int index){
    return
      InkWell(
        onTap:() {
//          Keys.navKey.currentState.pushNamed(Routes.challengeDetailScreen);
        } ,
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.015,),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child:
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),side : BorderSide(color: AppColors.colorWhite),
                  ),
                  elevation: 0.0,
                  color: AppColors.colorWhite,
                  child:
                  Row(
                    children: <Widget>[
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
                                          )
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.02,),
                          Align(
                            alignment: Alignment.topLeft,
                            child:
                            Container(
                              width: ScreenUtil.getInstance().setWidth(220),
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Text(data._listChallengePast[index].challengeName,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(17),
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),


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
                                  Expanded(child: Text(
                                    data._listChallengePast[index].challengeDescription ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: GoogleFonts.openSans(
                                      fontSize: ScreenUtil.getInstance().setWidth(13),
                                      color: Color(0xFF353535),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.topLeft,
                            child:
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                              child: Text(DemoLocalizations.of(context).trans('from') + " " +
                                  GetMonth.getMonth
                                    (data._listChallengePast[index].challengeStartDate.toString(),context )
                                  + ' ' + DemoLocalizations.of(context).trans('to')
                                  + " "+ GetMonth.getMonth
                                 (data._listChallengePast[index].challengeEndDate.toString(),context ),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(13),
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.009,)
                        ],
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
      );
  }


  /*Each card view for newsfeed detail*/
  Widget _cardNext(_ChallengeModel data, int index){
    return
      InkWell(
        onTap:() {
//          Keys.navKey.currentState.pushNamed(Routes.challengeDetailScreen);
        } ,
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.015,),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child:
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),side : BorderSide(color: AppColors.colorWhite),
                  ),
                  elevation: 0.0,
                  color: AppColors.colorWhite,
                  child:
                  Row(
                    children: <Widget>[
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
                                          )
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.02,),
                          Align(
                            alignment: Alignment.topLeft,
                            child:
                            Container(
                              width: ScreenUtil.getInstance().setWidth(220),
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Text(data._listChallengeNext[index].challengeName,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(17),
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),


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
                                  Expanded(child: Text(
                                    data._listChallengeNext[index].challengeDescription ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: GoogleFonts.openSans(
                                      fontSize: ScreenUtil.getInstance().setWidth(13),
                                      color: Color(0xFF353535),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ),


                          Align(
                            alignment: Alignment.topLeft,
                            child:
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                              child: Text(DemoLocalizations.of(context).trans('from') + new DateFormat("dd MMMM yyyy").format(
                                  DateTime.parse(data._listChallengeNext[index].challengeStartDate.toString()) )
                                  + ' ' + DemoLocalizations.of(context).trans('to')
                                  + new DateFormat("dd MMMM yyyy").format(
                                  DateTime.parse(data._listChallengeNext[index].challengeEndDate.toString()) ),
                                style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(13),
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.009,)
                        ],
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
      );
  }


}


class _ChallengeModel {
  final Store<AppState> store;
  final bool loader;
  final ChallengeResponse challengeResponse;
  final List<ChallengeData> _listChallengeActive;
  final List<ChallengeData> _listChallengePast ;
  final List<ChallengeData> _listChallengeNext;

  _ChallengeModel(this.store, this.loader, this.challengeResponse, this._listChallengeActive, this._listChallengePast,
      this._listChallengeNext);

  factory _ChallengeModel.create(Store<AppState> store, BuildContext context) {
    return _ChallengeModel(store, store.state.challengeLoaderAll, store.state.challengeListResponse, store.state.listChallengeActive,
        store.state.challengeListPast,store.state.challengeListNext);
  }
}