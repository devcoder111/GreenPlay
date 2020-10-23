import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:greenplayapp/redux/app_state.dart';
import 'package:greenplayapp/ui/authentication/forgot_password_page.dart';
import 'package:greenplayapp/ui/authentication/login_page.dart';
import 'package:greenplayapp/ui/authentication/register_page.dart';
import 'package:greenplayapp/ui/home/account/account_page.dart';
import 'package:greenplayapp/ui/home/challenges/challenge_detail_page.dart';
import 'package:greenplayapp/ui/home/drawer_page.dart';
import 'package:greenplayapp/ui/home/sessions/session_add_page.dart';
import 'package:greenplayapp/ui/home/sessions/session_edit_page.dart';
import 'package:greenplayapp/ui/home/sessions/session_view_page.dart';
import 'package:greenplayapp/ui/splash_page.dart';
import 'package:greenplayapp/utils/colors/app_colors.dart';
import 'package:greenplayapp/utils/language/language_application.dart';
import 'package:greenplayapp/utils/language/localization_delegate.dart';
import 'package:greenplayapp/utils/navigator/routes.dart';
import 'package:redux/redux.dart';



class Application extends StatefulWidget {
  final Store<AppState> store;

  Application(this.store) : super();

  @override
  State<StatefulWidget> createState() {
    return _MyAppState(store);
  }
}

class _MyAppState extends State<Application> with WidgetsBindingObserver{
  DemoLocalizationsDelegate _newLocaleDelegate;

  final Store<AppState> store;

  _MyAppState(this.store) : super();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _newLocaleDelegate = DemoLocalizationsDelegate(newLocale: null);
    languageApplication.onLocaleChanged = onLocaleChange;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale> locale) {
    _updateRemoteConfig();
  }

  Future<void> _updateRemoteConfig() async {
    languageApplication.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = DemoLocalizationsDelegate(newLocale: locale);
    });
  }

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      color: AppColors.colorBlue,
      localizationsDelegates: [
        _newLocaleDelegate,

        //provides localised strings
        GlobalMaterialLocalizations.delegate,
        //provides RTL support
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en"),
        const Locale("fr_FR"),
        const Locale('fr', ''),
      ],


      darkTheme: ThemeData(
        brightness: Brightness.dark, //theme of app
        primaryColor:AppColors.colorBlue,
      ),

      navigatorKey: Keys.navKey,
      //key navigator for app to be used globally throughout app
      debugShowCheckedModeBanner: false,
      //debug tag - as false
      home: SplashScreen(),
      //list all routes to be used in app
      routes: <String, WidgetBuilder>{
        Routes.loginScreen: (context) {
          //Login Page
          return LoginPage();
        } ,
        Routes.signUpScreen: (context) {
          //Register Page
          return RegisterPage();
        },
        Routes.forgotPasswordScreen: (context) {
          //ForgotPassword Page
          return ForgotPasswordPage();
        },
        Routes.drawerScreen: (context) {
          //Drawer Page
          return DrawerPage();
        },
        Routes.challengeDetailScreen: (context) {
          //Drawer Page
          return ChallengeDetailScreen();
        },
        Routes.addSessionScreen: (context) {
          //Drawer Page
          return SessionAddPage();
        },
        Routes.editSessionScreen: (context) {
          //Drawer Page
          return SessionEditPage();
        },
        Routes.viewSessionScreen: (context) {
          //Drawer Page
          return SessionViewPage();
        },
        Routes.accountScreen: (context) {
          //Drawer Page
          return AccountPage();
        },
      },
    );
  }
}
