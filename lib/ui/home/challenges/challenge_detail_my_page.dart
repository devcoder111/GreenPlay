import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/redux/action/reducer_action_common/challenge_action.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/redux/model/add_challenge_data_modal.dart';
import 'package:greenplayapp/redux/model/add_my_challenge_modal.dart';
import 'package:greenplayapp/redux/model/challenge_user_modal.dart';
import 'package:greenplayapp/redux/model/challenge_list_response.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/config/constants.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

class ChallengeDetailMyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChallengeDetailMyScreenState();
  }
}

class _ChallengeDetailMyScreenState extends State<ChallengeDetailMyScreen> {
  String startDate ;
  String endDate ;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var _styleTab = GoogleFonts.roboto(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorWhite,
    fontWeight: FontWeight.w500,
  );

  var _styleHeader = GoogleFonts.roboto(
    fontSize: ScreenUtil.getInstance().setWidth(15),
    color: AppColors.colorWhite,
    fontWeight: FontWeight.w500,
  );

  Store<AppState> store;
  int _index;
  bool isLoader = false;
  int _stateAccept = 0;
  int _buttonAccept = 1;

  final FirebaseDatabase _database = FirebaseDatabase.instance;


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);

    return StoreConnector<AppState, _ChallengeModel>(
        converter: (Store<AppState> store) {
      this.store = store;
      return _ChallengeModel.create(store, context);
    }, onInit: (store) {

      final int arguments = ModalRoute.of(context).settings.arguments;
      _index = arguments;
      startDate = store.state.challengeListResponse.data[_index].startDate;
      endDate = store.state.challengeListResponse.data[_index].endDate;
      if(DateTime.now().difference(DateTime(int.parse(startDate.split('-')[0]),
        int.parse(startDate.split('-')[1]),
        int.parse(startDate.split('-')[2]),
      )).inDays < 1){
        startDate = DemoLocalizations.of(context).trans('challenge_today');
      }else{
        if(DateTime.now().isAfter(DateTime(int.parse(startDate.split('-')[0]),
          int.parse(startDate.split('-')[1]),
          int.parse(startDate.split('-')[2]),
        ))){
          startDate = DateTime.now().difference(DateTime(int.parse(startDate.split('-')[0]),
            int.parse(startDate.split('-')[1]),
            int.parse(startDate.split('-')[2]),
          )).inDays.toString() + ' ' + DemoLocalizations.of(context).trans('challenge_after');
        }else{
          startDate = DateTime.now().difference(DateTime(int.parse(startDate.split('-')[0]),
            int.parse(startDate.split('-')[1]),
            int.parse(startDate.split('-')[2]),
          )).inDays.toString() + ' ' + DemoLocalizations.of(context).trans('challenge_before');
        }

      }

      _loadParticipant(store);
      _loadAcceptStatus(store);
      DateTime _currentDateTime = new DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day);

      DateTime _startDateTime = new DateTime(int.parse(store.state.challengeListResponse.data[_index].startDate.split('-')[0]),
          int.parse(store.state.challengeListResponse.data[_index].startDate.split('-')[1]),
          int.parse(store.state.challengeListResponse.data[_index].startDate.split('-')[2]));
      DateTime _endDateTime = new DateTime(int.parse(endDate.split('-')[0]),
          int.parse(endDate.split('-')[1]),
          int.parse(endDate.split('-')[2]));
      if(_currentDateTime.isAfter(_endDateTime)){
        _buttonAccept = 0;
      }
    }, builder: (BuildContext context, _ChallengeModel reduxSetup) {
      return Scaffold(
          backgroundColor: AppColors.colorBgGray,
          appBar: AppBar(
              backgroundColor: AppColors.colorBlue,
              elevation: 0.0,
              title: Container(
                child: Text(
                  DemoLocalizations.of(context).trans('challenge_det'),
                  style: _styleTab,
                  textAlign: TextAlign.center,
                ),
              ),
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: AppColors.colorWhite),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: AppColors.colorWhite,
              )),
          body: isLoader
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
              : Stack(
                  children: <Widget>[
                    Container(
                      child: ClipRect(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 170,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    'asset/placeholder.png',
                                  )),
                              borderRadius: BorderRadius.all(Radius.circular(0.0)),
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10,top: 0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[_listActiveChallenge(reduxSetup)],
                        ),
                      ),
                    ),
                  ],
                ));
    });
  }

  Widget _listActiveChallenge(_ChallengeModel reduxSetup) {
    return SingleChildScrollView(
      child: ListView.builder(
          itemCount: 1,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return _card(reduxSetup,index);
          }),
    );
  }

  /*Each card view for newsfeed detail*/
  Widget _card(_ChallengeModel reduxSetup, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _userImage(reduxSetup),

        _challengeNameHeader(),

        _acceptChallengeButton(),

        _textDate(),

        _scheduleDetail(),

        _challengeType(),

        _description(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.10,
        ),
//        _textCurrentParticipant(reduxSetup),
      ],
    );
  }

  /*Top user image......*/
  Widget _userImage(_ChallengeModel reduxSetup) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Column(
        children: <Widget>[
          /*Image.asset(
                    'asset/icon_distance.png',
                    height: ScreenUtil.getInstance().setWidth(20),
                    width: ScreenUtil.getInstance().setWidth(20),
                  )*/
          Container(
            child:
            Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child:
                  ClipOval(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Container(
                        height: ScreenUtil.getInstance().setWidth(150),
                        width: ScreenUtil.getInstance().setWidth(150),
                        child:Container(
                          height: ScreenUtil.getInstance().setWidth(10),
                          width: ScreenUtil.getInstance().setWidth(10)
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.colorBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child:
                  Container(
                    margin: EdgeInsets.only(top: 45),
                    child:
                    reduxSetup.challengeResponse.data[_index].challengeType == '1' ? Image.asset(
                      'asset/icon_time.png',color: AppColors.colorWhiteText,
                      height: ScreenUtil.getInstance().setWidth(70),
                      width: ScreenUtil.getInstance().setWidth(70),
                    ) :
                    Image.asset(
                      'asset/icon_distance.png',color: AppColors.colorWhiteText,
                      height: ScreenUtil.getInstance().setWidth(70),
                      width: ScreenUtil.getInstance().setWidth(70),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /*package text heading*/
  Widget _challengeNameHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Text(
          store.state.challengeListResponse.data[_index].challengeName
              ?? '-',
          maxLines: 3,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.openSans(
            fontSize: ScreenUtil.getInstance().setWidth(24),
            color: AppColors.colorBlack,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _acceptChallengeButton() {
    return
      _buttonAccept == 1? Container(
        height: 52,
        margin: EdgeInsets.only(left: 20.0, right: 20.0,top: 20),
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          color: AppColors.colorBlue,
          child: Text(
            store.state.challengeListResponse.data[_index].isAccepted ==
                1
                ? DemoLocalizations.of(context).trans('accepted')
                : DemoLocalizations.of(context).trans('accept'),
            style: GoogleFonts.openSans(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: ScreenUtil.getInstance().setWidth(15),
              color: AppColors.colorWhite,
              fontWeight: FontWeight.w600,
            ),
              textScaleFactor: 1.0
          ),
          onPressed: () async {
            if (store.state.challengeListResponse.data[_index].isAccepted ==
                0 || store.state.challengeListResponse.data[_index].isAccepted == null
                || store.state.challengeListResponse.data[_index].isAccepted == 2) {
              setState(() {
                isLoader = true;
              });
//                store.state.challengeListResponse.data.removeAt(_index);
              await _addChallengeParticipant().then((int response)async {
                if (response == 1) {
                  await _addChallengeUser().then((int response) {
                    if (response == 1) {

                      setState(() {
                        store.state.challengeListResponse.data[_index].isAccepted =
                        1;
                      });
                      print("test");
                      store.dispatch(ChallengeResponseAction(
                          store.state.challengeListResponse));
                      store.dispatch(MyChallengeApiAction());
                    }
                  });
                }
              });
            }else{
              FlutterToast.showToastCenter(DemoLocalizations.of(context).trans('already_participant'));
            }
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: AppColors.colorBlue,
              )),
        ),
      )
    :
    Container();
  }

  /*package text heading*/
  Widget _textDate() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 3),
              child:
              Icon(
                Icons.calendar_today,
                color: Color(0xFFB8B8B8),
                size: 20,
              ),
            ),
            Container(
              width: ScreenUtil.getInstance().setWidth(250),
              margin: EdgeInsets.only(left: 10),
              child:
              Text(
                DemoLocalizations.of(context).trans('from') + new DateFormat("dd MMMM yyyy").format(DateTime.parse(store.state.challengeListResponse.data[_index].startDate.toString()))
                    +" "+ DemoLocalizations.of(context).trans('to') +
                    new DateFormat("dd MMMM yyyy").format(DateTime.parse(store.state.challengeListResponse.data[_index].
                    endDate.toString())) + ' - ' +
                    startDate,maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: ScreenUtil.getInstance().setWidth(15),
                  color: Color(0xFF353535),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /*package text heading*/
  Widget _scheduleDetail() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 3),
              child:
              Icon(
                Icons.card_travel,
                color: Color(0xFFB8B8B8),
                size: 20,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    store.state.challengeListResponse.data[_index].scheduleType == '1' ?
                    DemoLocalizations.of(context).trans('no_schedule_one') : DemoLocalizations.of(context).trans('no_schedule_two'),
                    style: GoogleFonts.poppins(
                      fontSize: ScreenUtil.getInstance().setWidth(15),
                      color: Color(0xFF353535),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: ScreenUtil.getInstance().setWidth(250),
                    child:
                    Text(
                      store.state.challengeListResponse.data[_index].scheduleType == '1' ?  DemoLocalizations.of(context).trans('no_schedule_one_desc')
                          : DemoLocalizations.of(context).trans('no_schedule_two_desc'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: ScreenUtil.getInstance().setWidth(12),
                        color: Color(0xFF7D7C81),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _challengeType() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 3),
              child:
              SvgPicture.asset(
                'asset/target.svg',
                height: 20,
                width: 20,
                allowDrawingOutsideViewBox: true,
                color: Color(0xFFB8B8B8),
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 10),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    store.state.challengeListResponse.data[_index].challengeType == '1' ?
                    DemoLocalizations.of(context).trans('challenge_one') : DemoLocalizations.of(context).trans('challenge_two'),
                    style: GoogleFonts.poppins(
                      fontSize: ScreenUtil.getInstance().setWidth(15),
                      color: Color(0xFF353535),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: ScreenUtil.getInstance().setWidth(250),
                    child:
                    Text(
                      store.state.challengeListResponse.data[_index].scheduleType == '1' ?
                      DemoLocalizations.of(context).trans('challenge_one_desc')
                          : DemoLocalizations.of(context).trans('challenge_two_desc'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: ScreenUtil.getInstance().setWidth(12),
                        color: Color(0xFF7D7C81),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              )
            )
          ],
        ),
      ),
    );
  }


  /*package text heading*/
  Widget _description() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 3),
              child:
              SvgPicture.asset(
                'asset/challenge.svg',
                height: 20,
                width: 20,
                allowDrawingOutsideViewBox: true,
                color: Color(0xFFB8B8B8),
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 10),
              width: ScreenUtil.getInstance().setWidth(250),
              child:
              Text(
                store.state.challengeListResponse.data[_index].description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: ScreenUtil.getInstance().setWidth(15),
                  color: Color(0xFF353535),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  /*package text heading*/



  /*package text heading*/
  Widget _textCurrentParticipant(_ChallengeModel reduxSetup) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              DemoLocalizations.of(context).trans('challenge_part'),
              style: _styleHeader,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: reduxSetup.listParticipant.length > 0 ? _listNextChallenge(reduxSetup) :
            Container(
              margin: EdgeInsets.fromLTRB(0, 5, 20, 10),
              child: Text('No participant yet...',textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.colorBlueLanding,
                ),
                  textScaleFactor: 1.0
              ),
            ),
          )
        ],
      ),
    );
  }


  Widget _listNextChallenge(_ChallengeModel reduxSetup) {
    return
      SingleChildScrollView(
        child:
        Container(
          child:
          new ListView.builder(
              itemCount: reduxSetup.listParticipant.length > 0 ? reduxSetup.listParticipant.length : 0  ,
              physics: NeverScrollableScrollPhysics(), ///
              shrinkWrap: true, ///
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 20, 10),
                  child: Text(reduxSetup.listParticipant[index].userName,textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.colorBlueLanding,
                    ),
                      textScaleFactor: 1.0
                  ),
                );
              }
          ),
        ),
      );
  }



  Future<int> _addChallengeParticipant() async {
    User _userModalDetail = new User();
    _userModalDetail.userId = store.state.userAppModal.userId;
    _userModalDetail.userName = store.state.userAppModal.firstName;
    if( store.state.challengeListResponse.data[_index].userData == null){
      store.state.challengeListResponse.data[_index].userData = new List();
    }
    store.state.challengeListResponse.data[_index].userData
        .add(_userModalDetail);
    try {
      _database
          .reference()
          .child(DataBaseConstants.challengeParticipant)
          .orderByChild("idChallenge")
          .equalTo(store.state.challengeListResponse.data[_index].idChallenge)
          .once()
          .then((snapshot) async {
        Map<dynamic, dynamic> map = snapshot.value;
        try {
          String _key = map.keys.toList()[0];
          List<dynamic> userData = map.values.toList()[0]["userData"];

           userData.forEach((user) {
            var userName = user['userName'];
            var userId = user['userId'];
            if(!store.state.challengeListResponse.data[_index].userData.contains(userId)){
              User _userModalDetail = new User();
              _userModalDetail.userId = userId;
              _userModalDetail.userName = userName;

              store.state.challengeListResponse.data[_index].userData
                  .add(_userModalDetail);
            }
          });
          await _database
              .reference()
              .child(DataBaseConstants.challengeParticipant)
              .child(_key)
              .update(store.state.challengeListResponse.data[_index].toJson());
          setState(() {
            isLoader = false;
          });
          return 1;
        } catch (e) {
          await _database
              .reference()
              .child(DataBaseConstants.challengeParticipant)
              .push()
              .set(store.state.challengeListResponse.data[_index].toJson());
          setState(() {
            isLoader = false;
          });
          return 1;
        }
      });
      return 1;
    } catch (e) {
      await _database
          .reference()
          .child(DataBaseConstants.challengeParticipant)
          .push()
          .set(store.state.challengeListResponse.data[_index].toJson());
      setState(() {
        isLoader = false;
      });
      return 1;
    }
  }


  Future<int> _addChallengeUser() async {
    List<ChallengeData> challengeData = new List();
    ChallengeData _modalChallenge = new ChallengeData();
    _modalChallenge.challengeName = store.state.challengeListResponse.data[_index].challengeName;
    _modalChallenge.challengeId = store.state.challengeListResponse.data[_index].idChallenge.toString();
    _modalChallenge.challengeStartDate = store.state.challengeListResponse.data[_index].startDate.toString();
    _modalChallenge.challengeEndDate = store.state.challengeListResponse.data[_index].endDate.toString();
    _modalChallenge.challengeDescription = store.state.challengeListResponse.data[_index].description.toString();
    _modalChallenge.challengeDistance = store.state.challengeListResponse.data[_index].challengeDistance.toString();
    _modalChallenge.challengeCreatedBy = store.state.challengeListResponse.data[_index].createdBy.toString();
    _modalChallenge.scheduleType = store.state.challengeListResponse.data[_index].scheduleType.toString();
    challengeData.add(_modalChallenge);

    try {
      _database
          .reference()
          .child(DataBaseConstants.userChallenges)
          .orderByChild("userId")
          .equalTo(store.state.userAppModal.userId)
          .once()
          .then((snapshot) async {
        Map<dynamic, dynamic> map = snapshot.value;
        try {
          String _key = map.keys.toList()[0];
          List<dynamic> challengeMap = map.values.toList()[0]["challenges"];

          challengeMap.forEach((user) {
            ChallengeData _modalChallenge = new ChallengeData();
            _modalChallenge.challengeName = user['challengeName'] ?? '';
            _modalChallenge.challengeId = user['challengeId'].toString();
            _modalChallenge.challengeStartDate = user['StartDate'] ?? '';
            _modalChallenge.challengeEndDate = user['EndDate'] ?? '';
            _modalChallenge.challengeStartDate = user['StartDate'] ?? '';
            _modalChallenge.challengeEndDate = user['EndDate'];
            _modalChallenge.challengeDescription = user['Description'];
            _modalChallenge.challengeDistance = user['ChallengeDistance'];
            _modalChallenge.challengeCreatedBy = user['createdBy'];
            _modalChallenge.scheduleType = user['ScheduleType'];
            challengeData
                .add(_modalChallenge);
          });

          MyChallengeAddModal _modalAddChallengeUser = new MyChallengeAddModal(store.state.userAppModal.userId,
              store.state.userAppModal.firstName, store.state.userAppModal.lastName, challengeData);
          await _database
              .reference()
              .child(DataBaseConstants.userChallenges)
              .child(_key)
              .update(_modalAddChallengeUser.toJson());
          setState(() {
            isLoader = false;
          });
          return 1;
        } catch (e) {
          MyChallengeAddModal _modalAddChallengeUser = new MyChallengeAddModal(store.state.userAppModal.userId,
              store.state.userAppModal.firstName, store.state.userAppModal.lastName, challengeData);

          await _database
              .reference()
              .child(DataBaseConstants.userChallenges)
              .push()
              .set(_modalAddChallengeUser.toJson());
          setState(() {
            isLoader = false;
          });
          return 1;
        }
      });
      return 1;
    } catch (e) {
      MyChallengeAddModal _modalAddChallengeUser = new MyChallengeAddModal(store.state.userAppModal.userId,
          store.state.userAppModal.firstName, store.state.userAppModal.lastName, challengeData);
      await _database
          .reference()
          .child(DataBaseConstants.userChallenges)
          .push()
          .set(_modalAddChallengeUser.toJson());
      setState(() {
        isLoader = false;
      });
      return 1;
    }
  }

  Future<void> _loadParticipant(Store<AppState> store) async{

    _database.reference().child(DataBaseConstants.challengeParticipant).orderByChild("idChallenge").
    equalTo(store.state.challengeListResponse.data[_index].idChallenge).
    once().then((snapshot )async{
      if (snapshot .value != null){
        if (this.mounted){
          setState(() {
            isLoader = true;
          });
        }


        Map<dynamic, dynamic> map = snapshot.value;
        List<dynamic> userData = map.values.toList()[0]["userData"];

        List<User> _us = new List();
        userData.forEach((user) {
          var userName = user['userName'];
          var userId = user['userId'];
          User _userModalDetail = new User();
          _userModalDetail.userId = userId;
          _userModalDetail.userName = userName;

          _us.add(_userModalDetail);
        });

        store.dispatch(ChallengeParticipantListAction(_us));

        if (this.mounted){
          setState(() {
            isLoader = false;
          });
        }
      }else{
        print("no exists!");
        if (this.mounted){
          setState(() {
            isLoader = false;
          });
        }
      }
    });
  }


  Future<void> _loadAcceptStatus(Store<AppState> store) async{
    _database.reference().child(DataBaseConstants.userChallenges).orderByChild("userId").equalTo(store.state.userAppModal.userId).
    once().then((snapshot )async{
      if (snapshot .value != null){
        Map<dynamic, dynamic> map = snapshot.value;
        List<dynamic> userData = map.values.toList()[0]["challenges"];

        int _value = 0; //no change
        userData.forEach((user) {
          var challengeName = user['challengeName'];
          var challengeId = user['challengeId'];

          if(challengeId.toString() == store.state.challengeListResponse.data[_index].idChallenge.toString()){
            setState(() {
              store.state.challengeListResponse.data[_index].isAccepted =
              1;
              _stateAccept = 1;
            });
            _value = 1;
            store.dispatch(ChallengeResponseAction(
                store.state.challengeListResponse));
            return;
          }
          });
        if (this.mounted){
        if (_value == 0){
          setState(() {
            store.state.challengeListResponse.data[_index].isAccepted =
            2;
            _stateAccept = 2;
          });
         }
        }
        store.dispatch(ChallengeResponseAction(
            store.state.challengeListResponse));
      }else{
        if (this.mounted){
          setState(() {
            store.state.challengeListResponse.data[_index].isAccepted =
            2;
            _stateAccept = 2;
          });
        }
        store.dispatch(ChallengeResponseAction(
            store.state.challengeListResponse));
      }
    });
  }
}


class _ChallengeModel {
  final Store<AppState> store;
  final bool loader;
  final ChallengeResponse challengeResponse;
  final List<User> listParticipant;

  _ChallengeModel(this.store, this.loader, this.challengeResponse,this.listParticipant);

  factory _ChallengeModel.create(Store<AppState> store, BuildContext context) {
    return _ChallengeModel(
        store, store.state.challengeLoaderAll, store.state.challengeListResponse,store.state.listParticipant);
  }
}
