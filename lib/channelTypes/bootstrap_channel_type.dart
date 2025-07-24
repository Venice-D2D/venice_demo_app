import 'package:ble_bootstrap_channel/ble_bootstrap_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_code_bootstrap_channel/qr_code_bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';

enum BootstrapChannelType {
  qrCode,
  ble
}

extension BootstrapChannelTypeUtils on BootstrapChannelType {
  String get label {
    switch(this) {
      case BootstrapChannelType.qrCode:
        return 'QR code';
      case BootstrapChannelType.ble:
        return 'BLE';
    }
  }

  BootstrapChannel getBootstrapChannel(BuildContext context) {
    switch(this) {
      case BootstrapChannelType.qrCode:
        return QrCodeBootstrapChannel(context);
      case BootstrapChannelType.ble:
        return BleBootstrapChannel(context);
    }
  }
}