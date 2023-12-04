import 'dart:io';

import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:provider/provider.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:delta_scheduler/receiver/receiver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';

/// UI for the file reception part of the application.
///
/// This contains a directory selection button, required to select the
/// destination folder to be used to store received files, and a button used to
/// start file reception.
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

  /// Returns whether file reception can begin.
  ///
  /// For that to happen, a filesystem directory destination must be set, and at
  /// least one data channel must be selected.
  bool _canReceiveFile(BuildContext context) {
    return _destination != null && Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  /// Does the actual file reception.
  ///
  /// This will retrieve bootstrap and data channels to be used in the file
  /// exchange, initialize a [Receiver] instance with them, and start the file
  /// reception.
  ///
  /// During the process, some toast messages will be displayed to inform user
  /// about what's going on.
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

    // Configure bootstrap + data channels
    AppModel model = Provider.of<AppModel>(context, listen: false);
    BootstrapChannel bootstrapChannel = model.getBootstrapChannel(context);
    List<DataChannel> dataChannels = model.getDataChannels(context);

    Receiver receiver = Receiver(bootstrapChannel);
    for (DataChannel channel in dataChannels) {
      receiver.useChannel(channel);
    }

    // Receive file
    await receiver.receiveFile(_destination!);
    Fluttertoast.showToast( msg: "File successfully received!" );

    // Clean up resources
    bootstrapChannel.close();
    for (DataChannel channel in dataChannels) {
      channel.close();
    }
  }
}