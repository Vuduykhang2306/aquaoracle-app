import 'package:flutter/material.dart';

class SettingsProvider extends InheritedWidget {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationToggle;

  const SettingsProvider({
    super.key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.onThemeToggle,
    required this.onNotificationToggle,
    required super.child,
  });

  static SettingsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsProvider>();
  }

  @override
  bool updateShouldNotify(SettingsProvider oldWidget) {
    return isDarkMode != oldWidget.isDarkMode ||
        notificationsEnabled != oldWidget.notificationsEnabled;
  }
}