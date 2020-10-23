import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//String data = await rootBundle.loadString('asset/lang/${this.locale.languageCode}.json');
class DemoLocalizations {
 Locale locale;
 static Map<dynamic, dynamic> _localisedValues;

 DemoLocalizations(Locale locale) {
  this.locale = locale;
  _localisedValues = null;
 }

 static DemoLocalizations of(BuildContext context) {
  return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
 }

 static Future<DemoLocalizations> load(Locale locale) async {
  DemoLocalizations appTranslations = DemoLocalizations(locale);
  String jsonContent =
  await rootBundle.loadString("asset/lang/${locale.languageCode}.json");
  _localisedValues = json.decode(jsonContent);
  return appTranslations;
 }

 get currentLanguage => locale.languageCode;


 String trans(String key) {
  if(_localisedValues == null) return "";
  return _localisedValues[key] ?? "$key not found";
 }

}
