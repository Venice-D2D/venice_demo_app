import 'package:file_exchange_example_app/views/file/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
        '/file': (_) => const FileExchangePage()
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
          )
        ],
      ),
    );
  }
}