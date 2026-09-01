import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_status_notifier.freezed.dart';
part 'device_status_notifier.g.dart';
part 'device_status_state.dart';

@Riverpod(keepAlive: true)
class DeviceStatusNotifier extends _$DeviceStatusNotifier {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  late final AppLifecycleListener _listener;

  @override
  DeviceStatusState build() {
    _subscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectionChange,
    );
    _listener = AppLifecycleListener(
      onResume: () async {
        final connection = await Connectivity().checkConnectivity();
        _handleConnectionChange(connection);
      },
    );
    ref.onDispose(() {
      _subscription?.cancel();
      _listener.dispose();
    });
    return DeviceStatusState.empty();
  }

  Future<void> _handleConnectionChange(List<ConnectivityResult> result) async {
    final mobileNetwork = result.contains(ConnectivityResult.mobile);
    final wifiNetwork = result.contains(ConnectivityResult.wifi);
    state = state.copyWith(
      mobileNetwork: mobileNetwork,
      wifiNetwork: wifiNetwork,
      hasInternet: await _isInternetConnected(result),
    );
  }

  Future<bool> _isInternetConnected(List<ConnectivityResult> result) async {
    final mobileNetwork = result.contains(ConnectivityResult.mobile);
    final wifiNetwork = result.contains(ConnectivityResult.wifi);
    final ethernet = result.contains(ConnectivityResult.ethernet);
    if (!mobileNetwork && !wifiNetwork && !ethernet) return false;
    try {
      final response = await InternetAddress.lookup('google.com');
      return response.isNotEmpty && response.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}
