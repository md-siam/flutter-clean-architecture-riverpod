part of 'device_status_notifier.dart';

@freezed
sealed class DeviceStatusState with _$DeviceStatusState {
  const factory DeviceStatusState({
    required bool mobileNetwork,
    required bool wifiNetwork,
    required bool hasInternet,
  }) = _DeviceStatusState;

  factory DeviceStatusState.empty() => const DeviceStatusState(
    mobileNetwork: false,
    wifiNetwork: false,
    hasInternet: true,
  );
}
