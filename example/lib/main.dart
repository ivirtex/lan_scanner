// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:lan_scanner/lan_scanner.dart';

// Project imports:
import 'list_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAN Scanner Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'LAN Scanner Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<HostModel> hosts = <HostModel>{};
  LanScanner scanner = LanScanner();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildHostsListView(hosts),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          hosts.clear();

          var stream = scanner.icmpScan(
            '192.168.0',
          );

          stream.listen((HostModel device) {
            setState(() {
              hosts.add(device);
            });
          });
        },
        tooltip: 'Start scanning',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
