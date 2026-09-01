import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_template/presentation/theme/notifier/app_theme_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  tearDown(() => container.dispose());

  test('build defaults to the System theme when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();

    final state = container.read(appThemeProvider);

    expect(state.currentTheme.displayName, 'System');
    expect(state.themes.map((t) => t.displayName), [
      'System',
      'Light Mode',
      'Dark Mode',
    ]);
  });

  test('build restores a previously saved theme', () async {
    SharedPreferences.setMockInitialValues({'selected_theme': 'Dark Mode'});
    container = ProviderContainer();

    // `_loadThemeFromPrefs()` is fire-and-forget from `build()`, so wait
    // for the state it eventually writes rather than guessing a delay.
    final completer = Completer<void>();
    container.listen(appThemeProvider, (_, next) {
      if (next.currentTheme.displayName == 'Dark Mode') completer.complete();
    });
    await completer.future.timeout(const Duration(seconds: 2));

    expect(container.read(appThemeProvider).currentTheme.displayName, 'Dark Mode');
  });

  test('setTheme updates state and persists the display name', () async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    final notifier = container.read(appThemeProvider.notifier);
    final darkTheme = container.read(appThemeProvider).themes[2];

    await notifier.setTheme(darkTheme);

    expect(container.read(appThemeProvider).currentTheme.displayName, 'Dark Mode');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_theme'), 'Dark Mode');
  });

  test('setThemeByName looks the theme up by display name', () async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();

    await container.read(appThemeProvider.notifier).setThemeByName('Light Mode');

    expect(container.read(appThemeProvider).currentTheme.displayName, 'Light Mode');
  });

  test('toggleTheme advances to the next theme and wraps around', () async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    final notifier = container.read(appThemeProvider.notifier);

    await notifier.toggleTheme();
    expect(container.read(appThemeProvider).currentTheme.displayName, 'Light Mode');

    await notifier.toggleTheme();
    expect(container.read(appThemeProvider).currentTheme.displayName, 'Dark Mode');

    await notifier.toggleTheme();
    expect(container.read(appThemeProvider).currentTheme.displayName, 'System');
  });
}
