import 'package:flutter/material.dart';

enum AppTab {
  feed,
  search,
  messages,
  notifications,
  clubs,
  events,
  marketplace,
  confessions,
  polls,
  pegasus,
  profile,
  settings,
  admin,
}

class UIProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.feed;
  String? _selectedProfileUsername;
  int _logoClickCount = 0;
  DateTime? _lastLogoClickTime;
  bool _isPegasusFloatingOpen = false;

  AppTab get currentTab => _currentTab;
  String? get selectedProfileUsername => _selectedProfileUsername;
  bool get isPegasusFloatingOpen => _isPegasusFloatingOpen;

  void setTab(AppTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void openProfile(String username) {
    _selectedProfileUsername = username;
    _currentTab = AppTab.profile;
    notifyListeners();
  }

  void togglePegasusFloating() {
    _isPegasusFloatingOpen = !_isPegasusFloatingOpen;
    notifyListeners();
  }

  void setPegasusFloating(bool isOpen) {
    _isPegasusFloatingOpen = isOpen;
    notifyListeners();
  }

  /// Hidden admin entrance triggered by clicking logo 5 times within 3 seconds
  void handleLogoClick(bool isAdmin, BuildContext context) {
    final now = DateTime.now();
    if (_lastLogoClickTime == null || now.difference(_lastLogoClickTime!).inSeconds > 3) {
      _logoClickCount = 1;
    } else {
      _logoClickCount++;
    }
    _lastLogoClickTime = now;

    if (_logoClickCount >= 5) {
      _logoClickCount = 0;
      if (isAdmin) {
        setTab(AppTab.admin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin access restricted to verified campus admins.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      setTab(AppTab.feed);
    }
  }
}
