import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/features/dashboard/presentation/dashboard_landscape_view.dart';
import 'package:flutter_template/features/dashboard/presentation/dashboard_portrait_view.dart';
import 'package:flutter_template/shared/route/app_router.gr.dart';
import 'package:flutter_template/shared/widgets/widgets.dart';

@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        WidgetsRoute(),
        ArchitectureRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        return _ResponsiveDashboard(child: child);
      },
    );
  }
}

class _ResponsiveDashboard extends Screen {
  final Widget child;

  const _ResponsiveDashboard({required this.child});

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return DashboardPortrait(child: child);
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    return DashboardLandscape(child: child);
  }

  @override
  Widget buildTabletView(BuildContext context) {
    return DashboardLandscape(child: child);
  }
}
