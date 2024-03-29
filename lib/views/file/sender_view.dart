import 'dart:io';

import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:provider/provider.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:delta_scheduler/scheduler/scheduler.dart';
import 'package:file_exchange_example_app/scheduler_implementation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';

/// UI for the file sending part of the application.
///
/// This contains a file selection button, to select the file to be sent, and
/// another button used to start file sending.
class SenderView extends StatefulWidget {
  const SenderView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SenderViewState();
}

class _SenderViewState extends State<SenderView> {
  File? file;

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
                    // Please note that selecting a file that does not belong to
                    // current user will throw an error.
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        file = File(result.files.single.path!);
                      });
                    } else {
                      debugPrint("User selected no file.");
                    }
                  },
                  child: Text(
                      file != null
                          ? file!.uri.pathSegments.last
                          : "Select file to send"
                  )
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Consumer<AppModel>(
        builder: (BuildContext context, AppModel value, Widget? child) {
          return ElevatedButton(
            onPressed: _canSendFile(context) ? () => _startSendingFile(context) : null,
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
                )
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              child: const Text("Send file"),
            ),
          );
        },
      ),
    );
  }

  /// Returns whether file sending can begin.
  ///
  /// For this to be true, a file to send must be selected, and at least one
  /// data channel must be selected.
  bool _canSendFile(BuildContext context) {
    return file != null && Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  /// Does the actual file sending.
  ///
  /// This will retrieve bootstrap and data channels to be used in the file
  /// sending process, initialize a [Scheduler] instance with them, and start
  /// file sending.
  ///
  /// During the process, some toast messages will be displayed to inform user
  /// about what's going on.
  Future<void> _startSendingFile(BuildContext context) async {
    if (file == null) {
      Fluttertoast.showToast(
          msg: "Select a file before starting file sending."
      );
      return;
    }

    // Configure bootstrap + data channels
    AppModel model = Provider.of<AppModel>(context, listen: false);
    BootstrapChannel bootstrapChannel = model.getBootstrapChannel(context);
    List<DataChannel> dataChannels = model.getDataChannels(context);

    Scheduler scheduler = SchedulerImplementation( bootstrapChannel );
    for (DataChannel channel in dataChannels) {
      scheduler.useChannel(channel);
    }

    // Send file
    await scheduler.sendFile(file!, 100000);
    Fluttertoast.showToast( msg: "File successfully sent!" );

    // Clean up resources
    bootstrapChannel.close();
    for (DataChannel channel in dataChannels) {
      channel.close();
    }
  }
}