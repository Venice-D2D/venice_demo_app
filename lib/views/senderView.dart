import 'dart:io';

import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_exchange_example_app/scheduler_implementation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_bootstrap_channel/qr_code_bootstrap_channel.dart';
import 'package:wifi_data_channel/wifi_data_channel.dart';

class SenderView extends StatefulWidget {
  const SenderView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SenderViewState();
}

class _SenderViewState extends State<SenderView> {
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];
  File? _file;

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
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: ElevatedButton(
                onPressed: () async {
                  // Please note that selecting a file that does not belong to
                  // current user will throw an error.
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _file = File(result.files.single.path!);
                    });
                  } else {
                    debugPrint("User selected no file.");
                  }
                },
                child: Text(
                    _file != null
                        ? _file!.uri.pathSegments.last
                        : "Select file to send"
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
        onPressed: _canSendFile() ? () => _startSendingFile(context) : null,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
            )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Text("Send file"),
        ),
      ),
    );
  }

  bool _canSendFile() {
    return _file != null && _dataChannelTypes.isNotEmpty;
  }

  Future<void> _startSendingFile(BuildContext context) async {
    if (_file == null) {
      Fluttertoast.showToast(
          msg: "Select a file before starting file sending."
      );
      return;
    }

    BootstrapChannel bootstrapChannel = QrCodeBootstrapChannel(context);
    Scheduler scheduler = SchedulerImplementation(bootstrapChannel);

    // add data channels
    for (var type in _dataChannelTypes) {
      switch(type) {
        case DataChannelType.wifi:
          scheduler.useChannel( WifiDataChannel("wifi_data_channel") );
          break;
      }
    }

    await scheduler.sendFile(_file!, 100000);
    Fluttertoast.showToast( msg: "File successfully sent!" );
  }
}