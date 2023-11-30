import 'dart:io';

import 'package:ble_bootstrap_channel/ble_bootstrap_channel.dart';
import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:provider/provider.dart';
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
  Directory? _destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(50),
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
          )
        ],
      ),
      bottomNavigationBar: Consumer<AppModel>(
        builder: (BuildContext context, AppModel value, Widget? child) {
          return ElevatedButton(
            onPressed: _canReceiveFile(context) ? () => _startReceivingFile(context) : null,
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
              )
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              child: const Text("Receive file"),
            ),
          );
        },
      ),
    );
  }

  bool _canReceiveFile(BuildContext context) {
    return _destination != null && Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
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
    switch(Provider.of<AppModel>(context, listen: false).bootstrapChannelType) {
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
    for (var type in Provider.of<AppModel>(context, listen: false).dataChannelTypes) {
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