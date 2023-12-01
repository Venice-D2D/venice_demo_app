import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  String textToSend = "Prouver que j’ai raison serait accorder que je puis avoir tort.";

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

    debugPrint("Trying to send some text: $textToSend");

    throw UnimplementedError();
  }
}