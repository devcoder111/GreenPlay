import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/config/configs.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:greenplayapp/utils/views_common/OptionalDialogListener.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<ForgotPasswordPage> implements OptionalDialogListener{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _emailController = new TextEditingController();
  bool _isLoader = false;




  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return Scaffold(
      backgroundColor: AppColors.colorBlue,
      appBar: AppBar(backgroundColor: AppColors.colorBgGray, elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: AppColors.colorBlue),
          onPressed:(){
            Navigator.pop(context);
        } ,
          color: AppColors.colorWhite,
        )),
      body:  _isLoader
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
          ) ) :Container(
        color: AppColors.colorBlue,
        child:
        SingleChildScrollView(
          child:
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _logo(),
              _greenPlayForm(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _logo() {
    return Container(
      color: AppColors.colorBgGray,
      height: MediaQuery.of(context).size.height / 2.8,
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
    );
  }


  Widget _greenPlayForm() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.colorBgBlue, AppColors.colorBgBlueGradLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
      child: Column(
        children: <Widget>[
          _forgotText(),
          _emailField(), //email

          _buttonForgot(),
        ],
      ),
    );
  }


  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(38.0, 20.0, 38.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        style: GoogleFonts.openSans(
          textStyle: Theme.of(context).textTheme.display1,
          fontSize: ScreenUtil.getInstance().setWidth(15),
          color: AppColors.colorWhite,
          fontWeight: FontWeight.w600,
        ),//
        cursorColor: AppColors.colorWhiteText,
        decoration: new InputDecoration(
            filled: true,
            fillColor: AppColors.colorBgEditField,
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: AppColors.colorBgEditField)),
            enabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.colorBgEditField, width: 0.0),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.colorBgEditField, width: 0.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.colorBgEditField, width: 0.0),
            ),
            hintText: DemoLocalizations.of(context).trans('login_email'),
            hintStyle: GoogleFonts.openSans(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: ScreenUtil.getInstance().setWidth(15),
              color: AppColors.colorWhite,
              fontWeight: FontWeight.w200,
            ),
            prefixText: ' '),
      ),
    );
  }


  Widget _forgotText() {
    return Container(
      padding: EdgeInsets.only(left: 35, right : 35),
      margin: EdgeInsets.only(left: 15, right : 15,bottom: 20,top: 30),
      child:
      Align(
        alignment: Alignment.center,
        child: Text(
          DemoLocalizations.of(context).trans('forgot_email_header'),
          style: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: ScreenUtil.getInstance().setWidth(20),
            color: AppColors.colorWhite,
            fontWeight: FontWeight.w400,
          ),
          textScaleFactor: 1.0,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }



  Widget _buttonForgot() {
    return
      Container(
        height: 52,
        margin: EdgeInsets.only(left: 38.0, right: 38.0,top: 30),
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          color: Colors.white,
          child:  Container(
            child:
            Text(
              DemoLocalizations.of(context).trans('forgot_submit'),
                textScaleFactor: 1.0,
              style: GoogleFonts.openSans(
                textStyle: Theme.of(context).textTheme.display1,
                fontSize: ScreenUtil.getInstance().setWidth(15),
                color: AppColors.colorGrayDarkButton,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onPressed: () async {
            if(_emailController.text.isEmpty){
              FlutterToast.showToastCenter(DemoLocalizations.of(context)
                  .trans('login_enter_email'));
            }else if(!EmailValidator.validate(_emailController.text, true)){
              FlutterToast.showToastCenter(DemoLocalizations.of(context)
                  .trans('login_not_email'));
            }else {
              setState(() {
                _isLoader = true;
              });
              try {
                String language = Localizations.localeOf(context).languageCode;
                _auth.setLanguageCode(language);
                await _auth.sendPasswordResetEmail(
                  email: _emailController.text,
                );
                setState(() {
                  _isLoader = false;
                });
                AppDialogs().showAlertDialog(
                    context, DemoLocalizations.of(context)
                    .trans('success'), DemoLocalizations.of(context)
                    .trans('link_sent'), DemoLocalizations.of(context)
                    .trans('dialog_ok'), "", this);
              } catch (e) {
                print('Error: $e');
                setState(() {
                  _isLoader = false;
                });
                AppDialogs().showAlertDialog(
                    context, DemoLocalizations.of(context)
                    .trans('err'), e.toString(), DemoLocalizations.of(context)
                    .trans('dialog_ok'), "", this);
              }
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
