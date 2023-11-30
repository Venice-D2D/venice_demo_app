import 'package:file_exchange_example_app/model/app_model.dart';
import 'package:file_exchange_example_app/views/copypaste/main.dart';
import 'package:file_exchange_example_app/views/file/main.dart';
import 'package:file_exchange_example_app/views/video/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
        create: (_) => AppModel(),
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Venice example app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => const HomePage(),
        '/file': (_) => const FileExchangePage(),
        '/video': (_) => const VideoStreamingPage(),
        '/copy': (_) => const CopyPastePage()
      },
      initialRoute: '/',
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Venice example app"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.file_copy_rounded),
            title: const Text('File exchange'),
            subtitle: const Text('Send files from one phone to another.'),
            onTap: () => Navigator.of(context).pushNamed('/file'),
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Video streaming'),
            subtitle: const Text('Display video stream of one device on another.'),
            onTap: () => Navigator.of(context).pushNamed('/video'),
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_go_rounded),
            title: const Text('Copy paste'),
            subtitle: const Text('Copy text on one device, paste it on another.'),
            onTap: () => Navigator.of(context).pushNamed('/copy'),
          )
        ],
      ),
    );
  }
}