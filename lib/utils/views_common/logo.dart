import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TopLogo extends StatelessWidget {

  final screenType;

  const TopLogo(
       this.screenType);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 664)..init(context);
    return
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(left: 5),
            child: Image.asset(
              'asset/logo_leaf.png',
              height: ScreenUtil.getInstance().setWidth(40),
              width: ScreenUtil.getInstance().setWidth(40),
            ),
          ),
          Container(
            child: Image.asset(
              'asset/green_text.png',
              height: ScreenUtil.getInstance().setWidth(40),
              width: ScreenUtil.getInstance().setWidth(130),
            ),
          ),

        ],
      ) ;
  }
}
