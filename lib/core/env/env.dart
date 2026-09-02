import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_template/shared/app/app.dart';

import '../injector/injected_providers.dart';

abstract class Env {
  static late Env shared;
  abstract String name;
  abstract String baseUrl;
  bool initialized = false;

  Env() {
    shared = this;
    bootstrap(() => const App());
  }

  Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      log(details.exceptionAsString(), stackTrace: details.stack);
    };

    // Mirrors get_it's `@preResolve`: resolve the one async dependency up
    // front, then hand it to the graph as a plain override so every
    // provider in injected_providers.dart can stay synchronous.
    final sharedPreferences = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        observers: [AppProviderObserver()],
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: await builder(),
      ),
    );
  }
}

base class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final provider = context.provider;
    log(
      'onChange(${provider.name ?? provider.runtimeType}, '
      '$previousValue -> $newValue)',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final provider = context.provider;
    log(
      'onError(${provider.name ?? provider.runtimeType}, $error, $stackTrace)',
    );
  }
}
