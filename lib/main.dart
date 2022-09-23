import 'package:file_exchange_example_app/views/receiverView.dart';
import 'package:file_exchange_example_app/views/senderView.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File exchange example app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'File exchange example app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.send), text: "Send file"),
                Tab(icon: Icon(Icons.inbox_sharp), text: "Receive file")
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              SenderView(),
              ReceiverView()
            ],
          ),
        ),
      ),

    );
  }
}
