import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'internet_notifier.g.dart';
part 'internet_state.dart';

@riverpod
class InternetNotifier extends _$InternetNotifier {
  @override
  InternetState build() {
    final subscription = Connectivity().onConnectivityChanged.listen((
      statusList,
    ) {
      final hasConnection =
          statusList.isNotEmpty &&
          statusList.any((status) => status != ConnectivityResult.none);

      state = hasConnection
          ? const InternetState.connected()
          : const InternetState.disconnected();
    });
    ref.onDispose(subscription.cancel);
    return const InternetState.connected();
  }
}
