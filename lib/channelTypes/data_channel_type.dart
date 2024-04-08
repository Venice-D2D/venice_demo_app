import 'package:permission_handler/permission_handler.dart';

enum DataChannelType {
  ble,
  wifi
}

extension DataChannelTypeUtils on DataChannelType {
  String get label {
    switch(this) {
      case DataChannelType.ble:
        return 'BLE';
      case DataChannelType.wifi:
        return 'Wi-Fi';
    }
  }

  List<Permission> get neededPermissions {
    switch(this) {
      case DataChannelType.ble:
        return [Permission.bluetooth];
      case DataChannelType.wifi:
        return [
          Permission.locationWhenInUse,
          // Prompt user for nearby devices detection permission (on Android SDK > 32)
          Permission.nearbyWifiDevices
        ];
    }
  }
}