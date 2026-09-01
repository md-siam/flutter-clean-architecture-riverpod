import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'package:flutter_template/presentation/theme/notifier/app_theme_notifier.dart';
import 'package:flutter_template/presentation/theme/text/app_text.dart';

class ThemeDropDownButton extends ConsumerWidget {
  const ThemeDropDownButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appThemeProvider);

    return DropdownButton<String>(
      value: state.currentTheme.displayName,
      onChanged: (value) {
        if (value != null) {
          ref.read(appThemeProvider.notifier).setThemeByName(value);
        }
      },
      items: state.themes.map((themeEntity) {
        return DropdownMenuItem<String>(
          value: themeEntity.displayName,
          child: AppText.bodyMedium(
            _localizedThemeName(context, themeEntity.displayName),
          ),
        );
      }).toList(),
    );
  }

  /// The [displayName] doubles as the selection key, so it stays a stable
  /// identifier — only the label shown to the user is localized.
  String _localizedThemeName(BuildContext context, String displayName) {
    return switch (displayName) {
      'System' => context.l10n.themeSystem,
      'Light Mode' => context.l10n.themeLight,
      'Dark Mode' => context.l10n.themeDark,
      _ => displayName,
    };
  }
}
