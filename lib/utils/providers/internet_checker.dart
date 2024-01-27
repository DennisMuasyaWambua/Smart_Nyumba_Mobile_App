import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetChecker extends ChangeNotifier {
  late bool isInternetActive;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void checkForInternetConnection() async {
    isInternetActive = await InternetConnectionChecker().hasConnection;
    notifyListeners();
  }
  
}
