import 'dart:io';

import 'package:ble_bootstrap_channel/ble_bootstrap_channel.dart';
import 'package:qr_code_bootstrap_channel/qr_code_bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:delta_scheduler/receiver/receiver.dart';
import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wifi_data_channel/wifi_data_channel.dart';

class ReceiverView extends StatefulWidget {
  const ReceiverView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReceiverViewState();
}

class _ReceiverViewState extends State<ReceiverView> {
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];
  Directory? _destination;

  void _setBootstrapChannelType(BootstrapChannelType type) {
    setState(() {
      _bootstrapChannelType = type;
    });
  }

  void _toggleDataChannelType(DataChannelType type) {
    setState(() {
      if (_dataChannelTypes.contains(type)) {
        _dataChannelTypes.remove(type);
      } else {
        _dataChannelTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: ElevatedButton(
                onPressed: () async {
                  String? result = await FilePicker.platform.getDirectoryPath(dialogTitle: "test");
                  if (result != null) {
                    setState(() {
                      _destination = Directory(result);
                    });
                  } else {
                    debugPrint("User selected no file.");
                  }
                },
                child: Text(
                    _destination != null
                        ? _destination!.uri.toString()
                        : "Select file destination"
                )
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: const Divider(),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Select bootstrap channel:',
            ),
          ),
          ListTile(
            title: const Text('QR code'),
            onTap: () => _setBootstrapChannelType(BootstrapChannelType.qrCode),
            trailing: Checkbox(
                value: _bootstrapChannelType == BootstrapChannelType.qrCode,
                onChanged: (v) => _setBootstrapChannelType(BootstrapChannelType.qrCode)),
          ),
          ListTile(
            title: const Text("BLE"),
            onTap: () => _setBootstrapChannelType(BootstrapChannelType.ble),
            trailing: Checkbox(
              value: _bootstrapChannelType == BootstrapChannelType.ble,
              onChanged: (v) => _setBootstrapChannelType(BootstrapChannelType.ble),
            ),
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
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _canReceiveFile() ? () => _startReceivingFile(context) : null,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
            )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Text("Receive file"),
        ),
      ),
    );
  }

  bool _canReceiveFile() {
    return _destination != null && _dataChannelTypes.isNotEmpty;
  }

  Future<void> _startReceivingFile(BuildContext context) async {
    if (_destination == null) {
      Fluttertoast.showToast(
          msg: "Select a destination directory before starting file reception."
      );
      return;
    }

    Fluttertoast.showToast(
        msg: "Starting file reception..."
    );

    // set bootstrap channel
    BootstrapChannel bootstrapChannel;
    switch(_bootstrapChannelType) {
      case BootstrapChannelType.qrCode:
        bootstrapChannel = QrCodeBootstrapChannel(context);
        break;
      case BootstrapChannelType.ble:
        bootstrapChannel = BleBootstrapChannel(context);
        break;
      default:
        throw UnimplementedError("Bootstrap channel not initialized.");
    }
    Receiver receiver = Receiver(bootstrapChannel);

    // add data channels
    for (var type in _dataChannelTypes) {
      switch(type) {
        case DataChannelType.wifi:
          receiver.useChannel( WifiDataChannel("wifi_data_channel") );
          break;
      }
    }

    await receiver.receiveFile(_destination!);
    Fluttertoast.showToast( msg: "File successfully received!" );
  }
}