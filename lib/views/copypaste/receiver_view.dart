import 'dart:convert';

import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:venice_core/channels/events/bootstrap_channel_event.dart';
import 'package:venice_core/channels/events/data_channel_event.dart';
import 'package:venice_core/metadata/channel_metadata.dart';
import 'package:venice_core/network/message.dart';

/// UI for the copy-pasting reception part of the application.
///
/// This contains a text input widget that can be used to paste text received
/// through data channels, and a button used to start text reception.
class CopyPasteReceiverView extends StatefulWidget {
  const CopyPasteReceiverView({super.key});

  @override
  State<StatefulWidget> createState() => _CopyPasteReceiverViewState();
}

class _CopyPasteReceiverViewState extends State<CopyPasteReceiverView> {
  /// Returns whether text reception can start.
  /// For this to be true, at least one data channel must be selected.
  bool canReceiveText() {
    return Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  /// Does the actual text reception magic.
  ///
  /// This will retrieve bootstrap and data channels to be used in the text
  /// reception process, initialize a [Receiver] instance with them, and start
  /// text reception.
  ///
  /// During the process, some toast messages will be displayed to inform user
  /// about what's going on.
  void startReceivingText(BuildContext context) async {
    // Configure bootstrap + data channels
    AppModel model = Provider.of<AppModel>(context, listen: false);
    BootstrapChannel bootstrapChannel = model.getBootstrapChannel(context);
    List<DataChannel> dataChannels = model.getDataChannels(context);

    int initializedChannels = 0;
    bool allChannelsInitialized = false;

    // We only expect channel metadata here
    bootstrapChannel.on = (BootstrapChannelEvent event, dynamic data) async {
      switch(event) {
        case BootstrapChannelEvent.channelMetadata:
          ChannelMetadata channelMetadata = data;

          // Get matching channel to only send data to it, and not other channels.
          DataChannel matchingChannel = dataChannels.firstWhere((element) =>
          element.identifier == channelMetadata.channelIdentifier,
              orElse: () => throw ArgumentError(
                  'No channel with identifier "${channelMetadata.channelIdentifier}" was found in receiver channels.')
          );
          await matchingChannel.initReceiver(channelMetadata);

          // Start receiving once all channels have been initialized.
          initializedChannels += 1;
          if (initializedChannels == dataChannels.length) {
            allChannelsInitialized = true;
          }
          break;
        default:
          break;
      }
    };
    await bootstrapChannel.initReceiver();

    VeniceMessage? message;

    // Only use one data channel in this use-case since there's not much data to
    // transmit
    DataChannel channel = dataChannels.first;
    channel.on = (DataChannelEvent event, dynamic data) {
      VeniceMessage chunk = data;
      message = chunk;
      channel.sendMessage(VeniceMessage.acknowledgement(message!.messageId));
    };

    // Wait for bootstrap channel to receive channel information and initialize
    // them.
    while (!allChannelsInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Waiting for data reception
    while(message == null) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    String received = utf8.decode(message!.data);
    await Clipboard.setData(ClipboardData(text: received));
    Fluttertoast.showToast(
        msg: "Text copied successfully!",
        toastLength: Toast.LENGTH_LONG
    );
  }

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
                  margin: const EdgeInsets.all(50),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Try to paste some text here!"
                    ),
                    minLines: 2,
                    maxLines: 2,
                  )
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Consumer<AppModel>(
        builder: (BuildContext context, AppModel value, Widget? child) {
          return ElevatedButton(
            onPressed: canReceiveText() ? () => startReceivingText(context) : null,
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
              )
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              child: const Text("Receive text"),
            ),
          );
        },
      ),
    );
  }
}