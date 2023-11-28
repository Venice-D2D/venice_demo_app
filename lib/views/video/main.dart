import 'package:file_exchange_example_app/components/channels_selector.dart';
import 'package:flutter/material.dart';

class VideoStreamingPage extends StatefulWidget {
  const VideoStreamingPage({super.key});

  @override
  State<StatefulWidget> createState() => _VideoStreamingPageState();
}

class _VideoStreamingPageState extends State<VideoStreamingPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Video streaming example'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.send), text: "Send video"),
                Tab(icon: Icon(Icons.inbox_sharp), text: "Receive video")
              ],
            ),
          ),
          body: const Flex(
            direction: Axis.vertical,
            children: [
              Flex(
                direction: Axis.vertical,
                children: [
                  ChannelsSelector()
                ],
              )
            ]
          ),
        ),
      ),
    );
  }
}