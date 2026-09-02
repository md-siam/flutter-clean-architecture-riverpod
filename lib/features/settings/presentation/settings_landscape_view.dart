import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/core/injector/injected_providers.dart';
import 'package:flutter_template/features/settings/presentation/components/language_drop_down_button.dart';
import 'package:flutter_template/features/settings/presentation/components/settings_section.dart';
import 'package:flutter_template/features/settings/presentation/components/settings_tile.dart';
import 'package:flutter_template/features/user/presentation/components/theme_drop_down_button.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'package:flutter_template/shared/route/app_router.gr.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';
import 'package:flutter_template/shared/widgets/app_bar/widgets.dart';
import 'package:flutter_template/shared/widgets/dashboard_drawer/drawer_menu_button.dart';
import 'package:gap/gap.dart';

class SettingsLandscapeView extends ConsumerWidget {
  const SettingsLandscapeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: l10n.settingsTitle,
        leading: const DrawerMenuButton(),
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppConstant.horizontalGap16),
          children: [
            SettingsSection(
              title: l10n.settingsAppearance,
              children: [
                SettingsTile(
                  icon: Icons.palette_outlined,
                  title: l10n.settingsTheme,
                  trailing: const ThemeDropDownButton(),
                ),
                SettingsTile(
                  icon: Icons.language_outlined,
                  title: l10n.settingsLanguage,
                  trailing: const LanguageDropDownButton(),
                ),
              ],
            ),
            Gap(AppConstant.verticalGap20),
            SettingsSection(
              title: l10n.settingsAccount,
              children: [
                SettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: theme.error,
                  title: l10n.logout,
                  subtitle: l10n.logoutSubtitle,
                  onTap: () async {
                    await ref
                        .read(secureStorageServiceProvider)
                        .clearAccessToken();
                    if (context.mounted) {
                      context.router.replace(const LogInRoute());
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
