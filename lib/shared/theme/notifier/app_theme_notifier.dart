import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_template/shared/theme/base/theme_entity.dart';
import 'package:flutter_template/shared/theme/dark/en_dark_mode.dart';
import 'package:flutter_template/shared/theme/light/en_light_mode.dart';
import 'package:flutter_template/shared/theme/system/system_mode.dart';
import 'app_theme_state.dart';

part 'app_theme_notifier.g.dart';

@Riverpod(keepAlive: true)
class AppThemeNotifier extends _$AppThemeNotifier {
  static const _prefKey = 'selected_theme';

  @override
  AppThemeState build() {
    final themes = [
      ThemeEntity(SystemMode(), 'System'),
      ThemeEntity(EnLightMode(), 'Light Mode'),
      ThemeEntity(EnDarkMode(), 'Dark Mode'),
    ];
    _loadThemeFromPrefs();
    return AppThemeState.initial(themes);
  }

  /// Load saved theme from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_prefKey);
    if (savedName != null) {
      final entity = state.themes.firstWhere(
        (t) => t.displayName == savedName,
        orElse: () => state.currentTheme,
      );
      state = state.copyWith(currentTheme: entity);
    }
  }

  /// Set theme and save to SharedPreferences
  Future<void> setTheme(ThemeEntity entity) async {
    state = state.copyWith(currentTheme: entity);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, entity.displayName);
  }

  /// Set theme by name and save
  Future<void> setThemeByName(String displayName) async {
    final entity = state.themes.firstWhere(
      (t) => t.displayName == displayName,
      orElse: () => state.currentTheme,
    );
    state = state.copyWith(currentTheme: entity);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, entity.displayName);
  }

  /// Toggle theme in list and save
  Future<void> toggleTheme() async {
    final currentIndex = state.themes.indexOf(state.currentTheme);
    final nextIndex = (currentIndex + 1) % state.themes.length;
    final nextTheme = state.themes[nextIndex];
    state = state.copyWith(currentTheme: nextTheme);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, nextTheme.displayName);
  }
}
