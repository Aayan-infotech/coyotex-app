import 'package:flutter/material.dart';

class IndexProvider extends ChangeNotifier {
  int _currentIndex = 0;
  Key _mapKey = UniqueKey();

  int get currentIndex => _currentIndex;
  Key get mapKey => _mapKey;


  void updateIndex(int index) {
    if (index == 1) {
      _mapKey = UniqueKey();
    }
    _currentIndex = index;
    notifyListeners();
  }
}