import 'package:flutter/material.dart';

/// Exposes the dashboard shell's drawer-open callback to descendant tab
/// screens (across features), so each tab's own app bar can host the
/// menu button as part of its `leading` slot — keeping it vertically
/// aligned with the title instead of floating independently on top of
/// the content. Provided by `DashboardLandscape` in the dashboard
/// feature; consumed via [DrawerMenuButton] by any tab.
class DashboardDrawerController extends InheritedWidget {
  const DashboardDrawerController({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;

  /// The nearest [DashboardDrawerController]'s callback, or `null` when
  /// there's no drawer to open (e.g. a screen rendered outside
  /// `DashboardLandscape`, such as in portrait).
  static VoidCallback? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DashboardDrawerController>()
        ?.openDrawer;
  }

  @override
  bool updateShouldNotify(DashboardDrawerController oldWidget) =>
      openDrawer != oldWidget.openDrawer;
}
