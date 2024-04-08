import 'package:ble_data_channel/ble_data_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:wifi_data_channel/wifi_data_channel.dart';

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

  /// Returns a data channel that can be used in data exchanges.
  DataChannel get dataChannel {
    switch(this) {
      case DataChannelType.ble:
        return BleDataChannel("ble_data_channel");
      case DataChannelType.wifi:
        return WifiDataChannel("wifi_data_channel");
    }
  }
}