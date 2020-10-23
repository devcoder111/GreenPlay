import 'package:device_info/device_info.dart';
import 'package:greenplayapp/utils/config/configs.dart';

class DataBaseConstants {

  //list of all firebase db names used in app..........
   static String sessionData = 'SessionDataMay';
   static String users = 'Users';
   static String userChallenges = 'ChallengeUser';
   static String challengeParticipant = 'ChallengeParticipant';
   static String userSettings = 'UserSettings';
   static String allChallenge = 'All_Challenges';
}

class Constants {
   static int ageConstant = 70;
   static int ageMan = 80;
   static int ageWoMan = 55;
   static double remoteWorkCalorie = 1.5;
   static double remoteWorkGES = 0.0;
   static double transitBusCalorie = 1.3;
   static double transitBusGES = 0.06;
   static double bikeCalorie = 7.5;
   static double bikeGES = 0.0;
   static double carPoolingCalorie = 1.0;
   static double carPoolingGES = 0.08;
   static double trainCalories = 1.5;
   static double trainGES = 0.00007;
   static double walkCalories = 3.0;
   static double walkGES = 0.0;
   static double carPoolElectricCarCalorie = 1.0;
   static double carPoolElectricCarGES = 0.00011;
   static double tiltingCalorie = 1.0;
   static double tiltingGES = 0.0;
   static double metroCalorie = 1.5;
   static double metroGES = 0.00007;
   static double footCalorie = 3.0;
   static double footGES = 0.0;
   static double electricCarCalorie = 1.0;
   static double electricCarGES = 0.00034;
   static double runningCalorie = 11;
   static double runningGES = 0;
   static double aloneGES =  0.21;
   static String dbName =  "greenplay";
}

class GetTime{
   static String formatDuration(Duration duration) {
      return duration.toString().split('.').first.padLeft(8, '0');
   }
}