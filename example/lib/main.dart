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
  LanScanner scanner = LanScanner(debugLogging: true);

  double scanSpeed = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: scanSpeed,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        scanSpeed = value;
                      });
                    },
                  ),
                ),
                Text(scanSpeed.toStringAsFixed(1)),
              ],
            ),
            buildHostsListView(hosts),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          hosts.clear();

          final stream = scanner.icmpScan(
            '192.168.0',
            scanSpeeed: scanSpeed.toInt(),
          );

          stream.listen(
            (HostModel device) {
              setState(() {
                hosts.add(device);
              });

              print("Found host: ${device.ip}");
            },
          );
        },
        tooltip: 'Start scanning',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
