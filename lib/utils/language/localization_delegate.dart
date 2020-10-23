import 'dart:async';

import 'package:flutter/material.dart';

import 'demo_localization.dart';
import 'language_application.dart';

class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations> {
  final Locale newLocale;
  const DemoLocalizationsDelegate({this.newLocale});

  @override
  bool isSupported(Locale locale) {
    return languageApplication.supportedLanguagesCodes.contains(locale.languageCode);
  }

  @override
  Future<DemoLocalizations> load(Locale locale) {
    return DemoLocalizations.load(newLocale ?? locale);
  }


  @override
  bool shouldReload(DemoLocalizationsDelegate old) => true;
}
