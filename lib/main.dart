import 'dart:io';

import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];
  File? _file;

  void _setBootstrapChannelType(BootstrapChannelType type) {
    setState(() {
      _bootstrapChannelType = type;
    });
  }
  
  void _toggleDataChannelType(DataChannelType type) {
    setState(() {
      if (_dataChannelTypes.contains(type)) {
        _dataChannelTypes.remove(type);
      } else {
        _dataChannelTypes.add(type);
      }
    });
  }

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
          body: TabBarView(
            children: [
              _buildSenderView(),
              _buildReceiverView()
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildSenderView() {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    _file = File(result.files.single.path!);
                  });
                } else {
                  debugPrint("User selected no file.");
                }
              },
              child: Text(
                _file != null
                  ? _file!.uri.pathSegments.last
                  : "Select file to send"
              )
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: const Divider(),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Select bootstrap channel:',
            ),
          ),
          ListTile(
            title: const Text('QR code'),
            onTap: () => _setBootstrapChannelType(BootstrapChannelType.qrCode),
            trailing: Checkbox(
                value: _bootstrapChannelType == BootstrapChannelType.qrCode,
                onChanged: (v) => _setBootstrapChannelType(BootstrapChannelType.qrCode)),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Select data channels (at least one):',
            ),
          ),
          ListTile(
            title: const Text('Wi-Fi'),
            onTap: () => _toggleDataChannelType(DataChannelType.wifi),
            trailing: Checkbox(
              value: _dataChannelTypes.contains(DataChannelType.wifi),
              onChanged: (v) => _toggleDataChannelType(DataChannelType.wifi)
            ),
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _canSendFile() ? _startSendingFile : null,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
          )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Text("Send file"),
        ),
      ),
    );
  }

  Widget _buildReceiverView() {
    return Column();
  }

  bool _canSendFile() {
    return _file != null && _dataChannelTypes.isNotEmpty;
  }

  Future<void> _startSendingFile() async {
    if (_file == null) {
      Fluttertoast.showToast(
          msg: "Select a file before starting file sending."
      );
      return;
    }

    Fluttertoast.showToast(
      msg: "Starting to send ${_file!.uri.pathSegments.last}..."
    );

    // TODO send file using selecting channels
  }
}
