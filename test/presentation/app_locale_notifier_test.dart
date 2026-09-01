import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'package:flutter_template/presentation/locale/notifier/app_locale_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  tearDown(() => container.dispose());

  test('build starts with no locale override when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();

    final state = container.read(appLocaleProvider);

    expect(state.currentLocale, isNull);
    expect(state.supportedLocales, AppLocalizations.supportedLocales);
  });

  test('build restores a previously saved locale', () async {
    SharedPreferences.setMockInitialValues({'selected_locale': 'es'});
    container = ProviderContainer();

    // `_loadLocaleFromPrefs()` is fire-and-forget from `build()`, so wait
    // for the state it eventually writes rather than guessing a delay.
    final completer = Completer<void>();
    container.listen(appLocaleProvider, (_, next) {
      if (next.currentLocale != null) completer.complete();
    });
    await completer.future.timeout(const Duration(seconds: 2));

    final state = container.read(appLocaleProvider);
    expect(state.currentLocale?.languageCode, 'es');
  });

  test('setLocale updates state and persists the language code', () async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();

    await container
        .read(appLocaleProvider.notifier)
        .setLocale(const Locale('es'));

    expect(container.read(appLocaleProvider).currentLocale?.languageCode, 'es');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_locale'), 'es');
  });

  test('setLocale(null) follows the system locale and clears the pref', () async {
    SharedPreferences.setMockInitialValues({'selected_locale': 'es'});
    container = ProviderContainer();
    await Future<void>.delayed(Duration.zero);

    await container.read(appLocaleProvider.notifier).setLocale(null);

    expect(container.read(appLocaleProvider).currentLocale, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_locale'), isNull);
  });
}
