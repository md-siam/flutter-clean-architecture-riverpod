import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/shared/widgets/dashboard_drawer/dashboard_drawer_controller.dart';

import 'components/custom_navigation_drawer.dart';

class DashboardLandscape extends StatefulWidget {
  final Widget child;

  const DashboardLandscape({super.key, required this.child});

  @override
  State<DashboardLandscape> createState() => _DashboardLandscapeState();
}

class _DashboardLandscapeState extends State<DashboardLandscape> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: CustomNavigationDrawer(
        currentIndex: tabsRouter.activeIndex,
        onTap: (index) {
          tabsRouter.setActiveIndex(index);
          Navigator.of(context).pop();
        },
      ),
      // Each tab renders its own Scaffold/app bar, so `Scaffold.of` from
      // inside `child` would find that inner Scaffold, not this outer
      // drawer-owning one. DashboardDrawerController hands the open
      // callback down explicitly so a tab's DrawerMenuButton (its app
      // bar's `leading`) can reach it and stay aligned with the title.
      body: DashboardDrawerController(
        openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        child: widget.child,
      ),
    );
  }
}
