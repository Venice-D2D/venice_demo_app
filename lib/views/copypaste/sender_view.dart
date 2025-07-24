import 'dart:convert';
import 'dart:typed_data';

import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:venice_core/channels/events/data_channel_event.dart';
import 'package:venice_core/metadata/file_metadata.dart';
import 'package:venice_core/network/message.dart';

/// UI for the copy-pasting sending part of the application.
///
/// This contains a text input component holding text that will be send through
/// the network, and a button starting the data sending process.
class CopyPasteSenderView extends StatefulWidget {
  const CopyPasteSenderView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CopyPasteViewState();
}

class _CopyPasteViewState extends State<CopyPasteSenderView> {
  /// Text to be send through network.
  String textToSend = "\"Fear will always make you blind.\" - Daft Punk, Todd Edwards";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 50),
                child: TextFormField(
                  initialValue: textToSend,
                  minLines: 2,
                  maxLines: 2,
                  onChanged: (v) {
                    setState(() {
                      textToSend = v;
                    });
                  },
                )
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Consumer<AppModel>(
        builder: (BuildContext context, AppModel value, Widget? child) {
          return ElevatedButton(
            onPressed: _canSendText(context) ? () => _startSendingText(context) : null,
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
                )
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              child: const Text("Send text"),
            ),
          );
        },
      ),
    );
  }

  /// Returns whether text sending process can begin.
  ///
  /// For this to be true, text input component must contain some words (= not
  /// empty) and at least one data channel must be selected.
  bool _canSendText(BuildContext context) {
    return textToSend.isNotEmpty && Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  /// Does the actual text sending magic.
  ///
  /// This will retrieve bootstrap and data channels to be used in the text
  /// sending process, initialize a [Scheduler] instance with them, and start
  /// text sending.
  ///
  /// During the process, some toast messages will be displayed to inform user
  /// about what's going on.
  Future<void> _startSendingText(BuildContext context) async {
    if (textToSend.isEmpty) {
      Fluttertoast.showToast(
          msg: "Enter some text to send."
      );
      return;
    }

    // Configure bootstrap + data channels
    AppModel model = Provider.of<AppModel>(context, listen: false);
    BootstrapChannel bootstrapChannel = model.getBootstrapChannel(context);
    List<DataChannel> dataChannels = model.getDataChannels(context);

    // Open all channels
    await bootstrapChannel.initSender();
    // Fake data
    await bootstrapChannel.sendFileMetadata(
        FileMetadata("hello there", 100000, 1)
    );
    await Future.wait(dataChannels.map((c) => c.initSender( bootstrapChannel )));

    // Only use one data channel in this use-case since there's not much data to
    // transmit
    bool transmitted = false;
    DataChannel channel = dataChannels.first;
    channel.on = (DataChannelEvent event, dynamic data) {
      switch(event) {
        case DataChannelEvent.acknowledgment:
          transmitted = true;
          break;
        default:
          break;
      }
    };
    final List<int> codeUnits = textToSend.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);
    //VeniceMessage message = VeniceMessage.data(0, utf8.encode(textToSend));
    VeniceMessage message = VeniceMessage.data(0, unit8List);
    dataChannels.first.sendMessage( message );

    while(!transmitted) {
      await Future.delayed(const Duration(seconds: 1));
    }

    Fluttertoast.showToast(
      msg: "Text copied successfully!",
      toastLength: Toast.LENGTH_LONG
    );

    // Clean up resources
    bootstrapChannel.close();
    for (DataChannel channel in dataChannels) {
      channel.close();
    }
  }
}