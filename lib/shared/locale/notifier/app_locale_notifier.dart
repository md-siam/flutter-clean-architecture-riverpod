import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'app_locale_state.dart';

part 'app_locale_notifier.g.dart';

@Riverpod(keepAlive: true)
class AppLocaleNotifier extends _$AppLocaleNotifier {
  static const _prefKey = 'selected_locale';

  @override
  AppLocaleState build() {
    _loadLocaleFromPrefs();
    return AppLocaleState.initial(AppLocalizations.supportedLocales);
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey);
    if (savedCode == null) return;

    for (final locale in state.supportedLocales) {
      if (locale.languageCode == savedCode) {
        state = state.copyWith(currentLocale: locale);
        break;
      }
    }
  }

  /// Set locale and save to SharedPreferences. Pass `null` to follow the
  /// system locale.
  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(currentLocale: locale);

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, locale.languageCode);
    }
  }
}
