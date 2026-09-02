import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';

import 'components/custom_navigation_drawer.dart';

class DashboardLandscape extends StatelessWidget {
  final Widget child;

  const DashboardLandscape({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: CustomNavigationDrawer(
        currentIndex: tabsRouter.activeIndex,
        onTap: (index) {
          tabsRouter.setActiveIndex(index);
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          child,
          Padding(
            padding: EdgeInsets.all(AppConstant.horizontalGap12),
            child: Builder(
              builder: (context) =>
                  _MenuButton(onTap: () => Scaffold.of(context).openDrawer()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating trigger for [CustomNavigationDrawer] — sits over the active
/// tab's content instead of a dedicated toolbar, so it doesn't stack a
/// second app bar on top of tabs that already render their own.
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Material(
      color: theme.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: theme.shadow,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(AppConstant.horizontalGap12),
          child: Icon(
            Icons.menu_rounded,
            color: theme.onSurface,
            size: AppConstant.iconSize,
          ),
        ),
      ),
    );
  }
}
