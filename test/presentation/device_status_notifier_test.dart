import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template/core/notifier/device_status/device_status_notifier.dart';

/// Fake [ConnectivityPlatform] so the notifier's `Connectivity()` stream can
/// be driven from the test instead of touching a real platform channel.
class FakeConnectivityPlatform extends ConnectivityPlatform {
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];

  void emit(List<ConnectivityResult> result) => _controller.add(result);

  bool get hasListener => _controller.hasListener;

  Future<void> dispose() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeConnectivityPlatform platform;
  late ProviderContainer container;

  setUp(() {
    platform = FakeConnectivityPlatform();
    ConnectivityPlatform.instance = platform;
    container = ProviderContainer();
  });

  tearDown(() async {
    // The last test disposes `container` itself to assert on cleanup —
    // tolerate a second dispose() call here instead of duplicating tearDown.
    try {
      container.dispose();
    } on StateError {
      // Already disposed.
    }
    await platform.dispose();
  });

  test('build starts from the empty state before any event arrives', () {
    final state = container.read(deviceStatusProvider);

    expect(state.mobileNetwork, isFalse);
    expect(state.wifiNetwork, isFalse);
    expect(state.hasInternet, isTrue);
  });

  test(
    'no connectivity clears the network flags without a real DNS lookup',
    () async {
      // `[ConnectivityResult.none]` short-circuits `_isInternetConnected`
      // before it reaches the real `InternetAddress.lookup` call, so this
      // stays a true unit test — no network is touched.
      final states = <DeviceStatusState>[];
      container.listen(
        deviceStatusProvider,
        (_, next) => states.add(next),
      );

      platform.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(1));
      expect(states.single.mobileNetwork, isFalse);
      expect(states.single.wifiNetwork, isFalse);
      expect(states.single.hasInternet, isFalse);
    },
  );

  test('disposing the provider cancels the connectivity subscription', () {
    container.read(deviceStatusProvider); // Trigger build() to subscribe.
    expect(platform.hasListener, isTrue);

    container.dispose();

    expect(platform.hasListener, isFalse);
  });
}
