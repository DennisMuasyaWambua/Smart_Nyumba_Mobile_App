import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../widgets/internet_connection_dialog.dart';

class InternetChecker extends ChangeNotifier {
  late bool isInternetActive;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void checkForInternetConnection() async {
    isInternetActive = await InternetConnectionChecker().hasConnection;
    notifyListeners();
  }

  showInternetConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InternetConnectionDialog(),
    );
  }
}
