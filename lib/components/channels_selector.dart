import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChannelsSelector extends StatelessWidget {
  const ChannelsSelector({super.key});

  void _toggleDataChannelType(DataChannelType type, AppModel model) {
    if (model.dataChannelTypes.contains(type)) {
      model.removeDataChannelType(type);
    } else {
      model.addDataChannelType(type);
      _checkAssociatedPermissions(type);
    }
  }

  void _checkAssociatedPermissions(DataChannelType type) async {
    switch(type) {
      case DataChannelType.wifi:
        await Permission.locationWhenInUse.request();
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