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
    List<Permission> requiredPermissions = type.neededPermissions;
    for (Permission permission in requiredPermissions) {
      await permission.request();
    }
  }

  List<Widget> _getDataChannelTiles(AppModel model) {
    return DataChannelType.values.map((type) => ListTile(
      title: Text(type.label),
      onTap: () => _toggleDataChannelType(type, model),
      trailing: Checkbox(
          value: model.dataChannelTypes.contains(type),
          onChanged: (v) => _toggleDataChannelType(type, model)
      ),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, model, child) {
        List<Widget> children = [
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
        ];

        // Data channels
        children.addAll(_getDataChannelTiles(model));

        children.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: const Divider(),
        ));

        return Flex(
          direction: Axis.vertical,
          children: children,
        );
      },
    );
  }
}