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

/// UI for the video streaming display part of the application.
///
/// This contains an [Image] widget used to display received video stream, and a
/// button used to start video reception.
class VideoReceiverView extends StatefulWidget {
  const VideoReceiverView({super.key});

  @override
  State<StatefulWidget> createState() => _VideoReceiverViewState();
}

class _VideoReceiverViewState extends State<VideoReceiverView> {
  Uint8List? imageData;

  /// Returns whether video reception can begin.
  /// For this to be true, at least one data channel must be selected.
  bool canReceiveVideo() {
    return Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  /// Does the actual video streaming reception and display.
  ///
  /// This will retrieve bootstrap and data channels to be used in the video
  /// reception process, initialize a [Receiver] instance with them, and start
  /// video reception.
  ///
  /// During the process, some toast messages will be displayed to inform user
  /// about what's going on.
  void startReceivingStreaming(BuildContext context) async {
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

    // Only use one data channel for now
    DataChannel channel = dataChannels.first;
    channel.on = (DataChannelEvent event, dynamic data) {
      VeniceMessage chunk = data;
      channel.sendMessage(VeniceMessage.acknowledgement(chunk.messageId));
      setState(() {
        imageData = chunk.data;
      });
    };

    // Wait for bootstrap channel to receive channel information and initialize
    // them.
    while (!allChannelsInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    Fluttertoast.showToast(
      msg: "Ready to receive data!",
      toastLength: Toast.LENGTH_LONG
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (context, model, child) {
          return Scaffold(
            bottomNavigationBar: ElevatedButton(
              onPressed: canReceiveVideo() ? () => startReceivingStreaming(context) : null,
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
                  )
              ),
              child: Container(
                margin: const EdgeInsets.all(20),
                child: const Text("Start streaming"),
              ),
            ),
          );
        }
    );
  }
}