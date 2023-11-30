import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CopyPasteReceiverView extends StatefulWidget {
  const CopyPasteReceiverView({super.key});

  @override
  State<StatefulWidget> createState() => _CopyPasteReceiverViewState();
}

class _CopyPasteReceiverViewState extends State<CopyPasteReceiverView> {
  bool canReceiveText() {
    return Provider.of<AppModel>(context, listen: false).dataChannelTypes.isNotEmpty;
  }

  void startReceivingText(BuildContext context) {

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