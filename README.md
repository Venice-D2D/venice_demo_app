# Venice example app

An example application to test communication channels.

Several use-cases have been implemented in this application and are available for you to try:
* file exchange;
* video streaming;
* remote text copy/pasting.

The following communication channels are currently implemented:
* Bootstrap channels:
  * BLE: https://github.com/Venice-D2D/ble_bootstrap_channel
  * QR code: https://github.com/Venice-D2D/qr_code_bootstrap_channel
* Data channels:
  * Wi-Fi: https://github.com/Venice-D2D/wifi_data_channel

## Development

This application has been tested with Flutter version `3.16.0`.

```shell
# Install dependencies
flutter pub get

# Run app
flutter pub run
```
