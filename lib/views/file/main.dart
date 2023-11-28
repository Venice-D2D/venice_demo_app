import 'package:file_exchange_example_app/components/channels_selector.dart';
import 'package:file_exchange_example_app/views/file/receiver_view.dart';
import 'package:file_exchange_example_app/views/file/sender_view.dart';
import 'package:flutter/material.dart';

class FileExchangePage extends StatefulWidget {
  const FileExchangePage({Key? key}) : super(key: key);

  @override
  State<FileExchangePage> createState() => _FileExchangePageState();
}

class _FileExchangePageState extends State<FileExchangePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('File exchange example'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.send), text: "Send file"),
                Tab(icon: Icon(Icons.inbox_sharp), text: "Receive file")
              ],
            ),
          ),
          body: const Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 2,
                child: ChannelsSelector(),
              ),
              Expanded(
                flex: 1,
                child: TabBarView(
                  children: [
                    SenderView(),
                    ReceiverView(),
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
