import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'package:flutter_template/presentation/locale/notifier/app_locale_notifier.dart';
import 'package:flutter_template/presentation/route/app_router.dart';
import 'package:flutter_template/presentation/theme/notifier/app_theme_notifier.dart';
import '../widgets/widgets.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(appThemeProvider);
    final localeState = ref.watch(appLocaleProvider);

    return ScreenUtilInit(
      designSize: Screen.screenSize(context),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
        theme: themeState.currentTheme.theme.getAppTheme(
          orientation: MediaQuery.of(context).orientation,
        ),
        locale: localeState.currentLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
