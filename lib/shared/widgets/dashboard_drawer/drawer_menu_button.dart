import 'package:flutter/material.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';

import 'dashboard_drawer_controller.dart';

/// Opens the dashboard's landscape/tablet drawer. Drop this in as a tab
/// app bar's `leading` widget so it sits in the same row as the title
/// instead of floating over the content. Renders nothing if there's no
/// [DashboardDrawerController] ancestor (e.g. the view is shown outside
/// the dashboard shell).
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final openDrawer = DashboardDrawerController.maybeOf(context);
    if (openDrawer == null) return const SizedBox.shrink();

    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: openDrawer,
      icon: Icon(Icons.menu_rounded, color: context.colors.onSurface),
    );
  }
}
