import 'dart:async';

import 'package:camera/camera.dart';
import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoSenderView extends StatefulWidget {
  const VideoSenderView({super.key});

  @override
  State<StatefulWidget> createState() => _VideoSenderViewState();
}

class _VideoSenderViewState extends State<VideoSenderView> {
  late CameraController controller;

  // todo remove
  int imagesCount = 0;

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      controller = CameraController(cameras[0], ResolutionPreset.high);
      controller.initialize();
    });
  }

  bool canSendVideo() {
    return Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  void startVideoStreaming(BuildContext context) {
    imagesCount = 0;
    controller.startImageStream((image) {
      imagesCount += 1;
    });
    Timer t = Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint("==> FPS: $imagesCount");
      imagesCount = 0;
    });

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