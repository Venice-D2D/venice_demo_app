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
}