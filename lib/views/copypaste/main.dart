import 'package:file_exchange_example_app/components/channels_selector.dart';
import 'package:file_exchange_example_app/views/copypaste/receiver_view.dart';
import 'package:file_exchange_example_app/views/copypaste/sender_view.dart';
import 'package:flutter/material.dart';

class CopyPastePage extends StatefulWidget {
  const CopyPastePage({Key? key}) : super(key: key);

  @override
  State<CopyPastePage> createState() => _CopyPastePageState();
}

class _CopyPastePageState extends State<CopyPastePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Copy/paste example'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.copy_rounded), text: "Copy text"),
                Tab(icon: Icon(Icons.content_paste_go_rounded), text: "Paste text")
              ],
            ),
          ),
          body: const Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 5,
                child: ChannelsSelector(),
              ),
              Expanded(
                flex: 4,
                child: TabBarView(
                  children: [
                    CopyPasteSenderView(),
                    CopyPasteReceiverView(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
