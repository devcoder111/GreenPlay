import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/language/demo_localization.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_share_plugin/social_share_plugin.dart';


class FaqScreen extends StatefulWidget {
  @override
  _FaqScreenState createState() => new _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)
      ..init(context);
    return new Scaffold(
      backgroundColor: AppColors.colorBgGray,
      body:
      Container(
        margin: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setHeight(20), ScreenUtil.getInstance().setHeight(20),
            ScreenUtil.getInstance().setHeight(20), ScreenUtil.getInstance().setHeight(20)),
        child:
        Stack(
          children: <Widget>[
            Container(
              color: AppColors.colorWhite,
              margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(70)),
              child:
              ListView.builder(
                itemCount: 5,
                itemBuilder: (context, i) {
                  return new
                  Container(
                    child:
                    Container(
                      margin: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setHeight(10), ScreenUtil.getInstance().setHeight(10)
                          , ScreenUtil.getInstance().setHeight(10), 0),
                      child:
                      Card(
                          elevation: 2,
                          child: ExpansionTile(
                            title: Padding(padding: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setHeight(10), ScreenUtil.getInstance().setHeight(10)
                                , ScreenUtil.getInstance().setHeight(10), ScreenUtil.getInstance().setHeight(10)),
                              child:
                              Text(i == 0 ? DemoLocalizations.of(context).trans('faq_one') : i == 1 ? DemoLocalizations.of(context).trans('faq_two')
                                  : i == 2 ? DemoLocalizations.of(context).trans('faq_three') : i == 3 ? DemoLocalizations.of(context).trans('faq_four') :
                              DemoLocalizations.of(context).trans('faq_five'), style:
                              GoogleFonts.openSans(
                                fontSize: ScreenUtil.getInstance().setWidth(15),
                                color: Color(0xFF646E8D),
                                fontWeight: FontWeight.w700,
                              ),
                                  textScaleFactor: 1.0),),
                            children: <Widget>[
                              new Column(
                                children: _buildExpandableContent(i),
                              ),
                            ],
                          )),
                    ),
                  );
                },
              ),
            ),

            Container(
              height: ScreenUtil.getInstance().setHeight(70),
                child:
                InkWell(
                  onTap: () async {
                    _sendEmail();
                  },
                  child:
                  Align(
                      alignment: Alignment.topCenter,
                      child:
                      Text.rich(
                        TextSpan(
                          text: DemoLocalizations.of(context).trans('faq_head'),
                          style: GoogleFonts.openSans(
                            fontSize: ScreenUtil.getInstance().setWidth(13),
                            color: Color(0xFF646E8D),
                            fontWeight: FontWeight.w400,
                          ),

                          children: <TextSpan>[
                            TextSpan(
                              text: DemoLocalizations.of(context).trans('faq_head_email'),
                              style: GoogleFonts.openSans(
                                  fontSize: ScreenUtil.getInstance().setWidth(13),
                                  color: Color(0xFF646E8D),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline),
                            ),

                            // can add more TextSpans here...
                          ],
                        ),
                      )),
                )),

          ],
        ),
      )
    );
  }

  _buildExpandableContent(int i) {
    List<Widget> columnContent = [];

    columnContent.add(
      new Container(
        margin: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setHeight(10), ScreenUtil.getInstance().setHeight(10)
            , ScreenUtil.getInstance().setHeight(10), ScreenUtil.getInstance().setHeight(10)),
        child:
        ListTile(
          title:
          new Text(i == 0 ? DemoLocalizations.of(context).trans('faq_one_sub') :
          i == 1 ? DemoLocalizations.of(context).trans('faq_two_sub')
              : i == 2 ? DemoLocalizations.of(context).trans('faq_three_sub') :
          i == 3 ? DemoLocalizations.of(context).trans('faq_four_sub') :
          DemoLocalizations.of(context).trans('faq_five_sub'),
            style: GoogleFonts.openSans(
              fontSize: ScreenUtil.getInstance().setWidth(15),
              color: Color(0xFF646E8D),
              fontWeight: FontWeight.w400,
            ),
              textScaleFactor: 1.0),
        ),
      ),
    );

    return columnContent;
  }


 /*
 * send email content*/
 Future _sendEmail() async{
   /*final Email email = Email(
     body: '',
     subject: 'Greenplay FAQ',
     recipients: ['info@greenplay.social'],
     isHTML: false,
   );

   await FlutterEmailSender.send(email);*/

   final mailtoLink = Mailto(
     to: ['info@greenplay.social'],
     subject: 'Greenplay FAQ',
     body: '',
   );
   // Convert the Mailto instance into a string.
   // Use either Dart's string interpolation
   // or the toString() method.
   await launch('$mailtoLink');
//   File file = await ImagePicker.pickImage(source: ImageSource.gallery);
//   await SocialSharePlugin.shareToFeedFacebook(path: file.path);

//   await SocialSharePlugin.shareToFeedFacebookLink(quote: 'quote', url: 'https://flutter.dev');
   }
 }


class Vehicle {
  final String title;
  List<String> contents = [];
  final IconData icon;

  Vehicle(this.title, this.contents, this.icon);
}

List<Vehicle> vehicles = [
  new Vehicle(
    'How often are trips updated?',
    ['Vehicle no. 1', 'Vehicle no. 2', 'Vehicle no. 7', 'Vehicle no. 10'],
    Icons.motorcycle,
  ),
  new Vehicle(
    'Cars',
    ['Vehicle no. 3', 'Vehicle no. 4', 'Vehicle no. 6'],
    Icons.directions_car,
  ),
];