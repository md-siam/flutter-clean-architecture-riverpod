import 'package:flutter/material.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';

import 'navigation_drawer_item.dart';

/// Landscape/tablet navigation for the dashboard shell, opened from the
/// floating menu button in [DashboardLandscape] rather than shown as a
/// permanent side rail.
class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  final void Function(int index) onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Drawer(
      width: 200,
      backgroundColor: theme.surface,
      // Only guard against the status bar / home indicator. Also
      // reserving the notch/Dynamic-Island side inset here would eat a
      // big chunk of an already-narrow 200px drawer — that side of the
      // screen isn't near the drawer's own content anyway.
      child: SafeArea(
        left: false,
        right: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppConstant.verticalGap16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NavigationDrawerItem(
                title: context.l10n.navHome,
                onTap: () => onTap(0),
                isSelected: currentIndex == 0,
                icon: Icons.home_rounded,
              ),
              NavigationDrawerItem(
                title: context.l10n.navWidgets,
                onTap: () => onTap(1),
                isSelected: currentIndex == 1,
                icon: Icons.widgets_rounded,
              ),
              NavigationDrawerItem(
                title: context.l10n.navArchitecture,
                onTap: () => onTap(2),
                isSelected: currentIndex == 2,
                icon: Icons.account_tree_rounded,
              ),
              NavigationDrawerItem(
                title: context.l10n.navSettings,
                onTap: () => onTap(3),
                isSelected: currentIndex == 3,
                icon: Icons.settings_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
