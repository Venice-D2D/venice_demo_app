import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

/// UI for the channels selection that's used in all experiment subviews of this
/// application.
///
/// This is barely an interface for the [AppModel] instance, allowing user to
/// select the channels they want to use in this demonstration example app.
class ChannelsSelector extends StatelessWidget {
  const ChannelsSelector({super.key});

  /// Registers a data channel type in the list of channels to be used in future
  /// data exchanges, or removes it from the list if it's already included.
  void _toggleDataChannelType(DataChannelType type, AppModel model) {
    if (model.dataChannelTypes.contains(type)) {
      model.removeDataChannelType(type);
    } else {
      model.addDataChannelType(type);
      _checkAssociatedPermissions(type);
    }
  }

  /// Asks user to give all permissions required by channel [type] to the demo
  /// app.
  void _checkAssociatedPermissions(DataChannelType type) async {
    switch(type) {
      case DataChannelType.wifi:
        await Permission.locationWhenInUse.request();
        // Prompt user for nearby devices detection permission (on Android SDK > 32)
        await Permission.nearbyWifiDevices.request();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, model, child) {
        return Flex(
          direction: Axis.vertical,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: const Text(
                'Select bootstrap channel:',
              ),
            ),
            RadioListTile<BootstrapChannelType>(
              title: const Text('QR code'),
              value: BootstrapChannelType.qrCode,
              groupValue: model.bootstrapChannelType,
              onChanged: (v) {
                model.bootstrapChannelType = v!;
              },
            ),
            RadioListTile<BootstrapChannelType>(
              title: const Text('BLE'),
              value: BootstrapChannelType.ble,
              groupValue: model.bootstrapChannelType,
              onChanged: (v) {
                model.bootstrapChannelType = v!;
              },
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: const Text(
                'Select data channels (at least one):',
              ),
            ),
            ListTile(
              title: const Text('Wi-Fi'),
              onTap: () => _toggleDataChannelType(DataChannelType.wifi, model),
              trailing: Checkbox(
                  value: model.dataChannelTypes.contains(DataChannelType.wifi),
                  onChanged: (v) => _toggleDataChannelType(DataChannelType.wifi, model)
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child: const Divider(),
            ),
          ],
        );
      },
    );
  }
}