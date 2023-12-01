import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void startReceivingText(BuildContext context) {
    throw UnimplementedError();
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
                    minLines: 1,
                    maxLines: 1,
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