import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoReceiverView extends StatefulWidget {
  const VideoReceiverView({super.key});

  @override
  State<StatefulWidget> createState() => _VideoReceiverViewState();
}

class _VideoReceiverViewState extends State<VideoReceiverView> {
  bool canReceiveVideo() {
    return Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  void startReceivingStreaming(BuildContext context) {

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