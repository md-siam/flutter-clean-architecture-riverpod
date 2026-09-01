import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template/presentation/screen/dashboard/notifier/internet_notifier.dart';

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

  Future<void> dispose() => _controller.close();
}

void main() {
  late FakeConnectivityPlatform platform;
  late ProviderContainer container;

  setUp(() {
    platform = FakeConnectivityPlatform();
    ConnectivityPlatform.instance = platform;
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await platform.dispose();
  });

  test('build starts connected before any event arrives', () {
    expect(container.read(internetProvider).isConnected, isTrue);
  });

  test('emits disconnected when connectivity drops to none', () async {
    final states = <bool>[];
    container.listen(
      internetProvider,
      (_, next) => states.add(next.isConnected),
    );

    platform.emit([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);

    expect(states, [false]);
  });

  test('emits connected again once a real connection returns', () async {
    final states = <bool>[];
    container.listen(
      internetProvider,
      (_, next) => states.add(next.isConnected),
    );

    platform.emit([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    platform.emit([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    expect(states, [false, true]);
  });

  test('an empty result list counts as disconnected', () async {
    final states = <bool>[];
    container.listen(
      internetProvider,
      (_, next) => states.add(next.isConnected),
    );

    platform.emit([]);
    await Future<void>.delayed(Duration.zero);

    expect(states, [false]);
  });
}
