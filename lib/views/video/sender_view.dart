import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:file_exchange_example_app/views/video/image_encoding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// UI for the video streaming sending part of the application.
///
/// This contains a button that will fire up the device camera, display its feed
/// in a modal dialog.
class VideoSenderView extends StatefulWidget {
  const VideoSenderView({super.key});

  @override
  State<StatefulWidget> createState() => _VideoSenderViewState();
}

class _VideoSenderViewState extends State<VideoSenderView> {
  /// Camera controller instance, used to initialize, start and stop video
  /// streaming.
  late CameraController controller;

  /// Bytes of the last camera image received.
  Uint8List? imageBytes;

  /// This frames-per-second (FPS) indicator informs developers about device
  /// performances while video streaming is happening: an image encoding process
  /// is required to send images through the network, and it might have an
  /// impact on performances.
  int imagesCount = 0;

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      controller = CameraController(cameras[0], ResolutionPreset.high);
      controller.initialize();
    });
  }

  /// Returns whether video sending can begin.
  /// For this to be true, at least one data channel must be selected.
  bool canSendVideo() {
    return Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  /// Does the actual video streaming sending magic.
  ///
  /// This will retrieve bootstrap and data channels to be used in the video
  /// reception process, initialize a [Scheduler] instance with them, and start
  /// video reception.
  ///
  /// During the process, some toast messages will be displayed to inform user
  /// about what's going on.
  void startVideoStreaming(BuildContext context) {
    imagesCount = 0;
    controller.startImageStream((image) {
      imagesCount += 1;
      setState(() {
        imageBytes = convertYUV420toImageColor(image);
      });
    });

    // Update frames-per-second indicator every second
    Timer t = Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint("==> FPS: $imagesCount");
      imagesCount = 0;
    });

    // Display camera feed in a modal window
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.80,
          child: CameraPreview(controller),
        )
    ).whenComplete(() {
      controller.stopImageStream();
      t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (context, model, child) {
          return Scaffold(
            // Displays last camera image, used for debug purposes
            body: imageBytes == null ? Container() : Image.memory(imageBytes!),
            bottomNavigationBar: ElevatedButton(
              onPressed: canSendVideo() ? () => startVideoStreaming(context) : null,
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