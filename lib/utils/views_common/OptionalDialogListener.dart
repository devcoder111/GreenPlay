import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';

abstract class OptionalDialogListener {
  void onPositiveClick(BuildContext context);

  void onNegativeClick();
}


typedef OkDialogListener = void Function();


class AppDialogs {
  static final AppDialogs _singleton = AppDialogs._internal();

  factory AppDialogs() {
    return _singleton;
  }

  AppDialogs._internal();

  void showOKDialog(BuildContext context, String title, String content,
      OkDialogListener onOkClick) {
    // flutter defined function
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ) ,
          title:  Text(title),
          content:  Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            FlatButton(
              child:  Text("OK"),
              onPressed: () {
                onOkClick();
              },
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog(
      BuildContext context,
      String title,
      String content,
      String positiveBtnName,
      String negativeBtnName,
      OptionalDialogListener listener) {
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
          title:  Text(title,
          style: GoogleFonts.openSans(
            fontSize: 15,
            color: AppColors.colorBlack,
            fontWeight: FontWeight.w600,
          ),),
          content:  Text(content,
          style: GoogleFonts.openSans(
            fontSize: 15,
            color: AppColors.colorBlack,
            fontWeight: FontWeight.w400,
          ),),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child:  Text(negativeBtnName,
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  color: AppColors.colorBlue,
                  fontWeight: FontWeight.w600,
                ),),
              onPressed: () {
                listener.onNegativeClick();
              },
            ),
            FlatButton(
              child:  Text(positiveBtnName,
              style: GoogleFonts.openSans(
                fontSize: 15,
                color: AppColors.colorBlue,
                fontWeight: FontWeight.w600,
              ),),
              onPressed: () {
                listener.onPositiveClick(context);
              },
            ),
          ],
        );
      },
    );
  }
}

