import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/widgets/widgets.dart';

import 'login_portrait_view.dart';

@RoutePage()
class LogInScreen extends Screen {
  const LogInScreen({super.key});

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return const LogInPortraitView();
  }
}
