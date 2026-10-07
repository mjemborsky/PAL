import 'dart:async';
import 'package:flutter/foundation.dart';

class MockPhoneStatusService extends ChangeNotifier {
  int _batteryLevel = 84;
  bool _isCharging = false;
  int _wifiSignalStrength = 3; // 0 to 4
  bool _isBluetoothConnected = true;
  String _deviceName = "User's Phone";

  int get batteryLevel => _batteryLevel;
  bool get isCharging => _isCharging;
  int get wifiSignal => _wifiSignalStrength;
  bool get bluetoothConnected => _isBluetoothConnected;
  String get deviceName => _deviceName;

  MockPhoneStatusService() {
    Timer.periodic(const Duration(minutes: 1), (_) {
      if (_batteryLevel > 15) {
        _batteryLevel -= 1;
        notifyListeners();
      }
    });
  }
}
