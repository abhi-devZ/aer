import 'package:flutter/material.dart';

class TabService extends ChangeNotifier {
  static final TabService _instance = TabService._internal();

  factory TabService() => _instance;

  TabService._internal();

  final List<Widget> _tabList = [];

  bool _showTabs = false;
  int _currentIndex = 0;

  List<Widget> get tabList => _tabList;

  bool get showTabs => _showTabs;

  int get currentIndex => _currentIndex;

  void addTab(Widget tab) {
    _tabList.add(tab);
    notifyListeners();
  }

  void removeTab(int index) {
    if (index >= 0 && index < _tabList.length) {
      _tabList.removeAt(index);
      notifyListeners();
    }
  }

  void toggleTabs() {
    _showTabs = !_showTabs;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _tabList.length) {
      _currentIndex = index;
      _showTabs = false;
      notifyListeners();
    }
  }

  Widget get currentTab => _tabList.isNotEmpty ? _tabList[_currentIndex] : Container();
}
