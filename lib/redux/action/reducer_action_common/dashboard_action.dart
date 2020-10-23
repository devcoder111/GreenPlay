

import 'package:greenplayapp/redux/model/user_model.dart';

class DashboardLoaderAction {
  bool dashLoader;

  DashboardLoaderAction(this.dashLoader);
}

class DashboardPercentAction {
  double dashboardPercent;

  DashboardPercentAction(this.dashboardPercent);
}

class DashboardCaloriesAction {
  String caloriesCount;

  DashboardCaloriesAction(this.caloriesCount);
}


class DashboardUsersAction {

  DashboardUsersAction();
}


class DashboardUsersResponseAction {
  List<UserAppModal> listUserDashboard;
  DashboardUsersResponseAction(this.listUserDashboard);
}
