import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_exchange_example_app/views/file/receiver_view.dart';
import 'package:file_exchange_example_app/views/file/sender_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FileExchangePage extends StatefulWidget {
  const FileExchangePage({Key? key}) : super(key: key);

  @override
  State<FileExchangePage> createState() => _FileExchangePageState();
}

class _FileExchangePageState extends State<FileExchangePage> {
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];

  void _toggleDataChannelType(DataChannelType type) {
    setState(() {
      if (_dataChannelTypes.contains(type)) {
        _dataChannelTypes.remove(type);
      } else {
        _dataChannelTypes.add(type);
        _checkAssociatedPermissions(type);
      }
    });
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
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('File exchange example'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.send), text: "Send file"),
                Tab(icon: Icon(Icons.inbox_sharp), text: "Receive file")
              ],
            ),
          ),
          body: Flex(
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
                groupValue: _bootstrapChannelType,
                onChanged: (v) {
                  setState(() {
                    _bootstrapChannelType = v!;
                  });
                },
              ),
              RadioListTile<BootstrapChannelType>(
                title: const Text('BLE'),
                value: BootstrapChannelType.ble,
                groupValue: _bootstrapChannelType,
                onChanged: (v) {
                  setState(() {
                    _bootstrapChannelType = v!;
                  });
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
                onTap: () => _toggleDataChannelType(DataChannelType.wifi),
                trailing: Checkbox(
                    value: _dataChannelTypes.contains(DataChannelType.wifi),
                    onChanged: (v) => _toggleDataChannelType(DataChannelType.wifi)
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: const Divider(),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SenderView(
                        bootstrapChannelType: _bootstrapChannelType,
                        dataChannelTypes: _dataChannelTypes),
                    ReceiverView(
                        bootstrapChannelType: _bootstrapChannelType,
                        dataChannelTypes: _dataChannelTypes),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
