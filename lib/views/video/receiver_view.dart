import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void startReceivingStreaming(BuildContext context) {
    throw UnimplementedError();
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