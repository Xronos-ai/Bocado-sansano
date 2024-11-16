import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String iDuser;
  int loged;

  UserProvider({
    this.iDuser = '',
    this.loged = 0,
  });

  void changeIDuser({
    required String newiDuser,
  }) async {
    iDuser = newiDuser;
    notifyListeners();
  }

  void changeLoged({
    required int newloged,
  }) async {
    loged = newloged;
    notifyListeners();
  }
}