import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:lan_scanner_ios/lan_scanner_ios.dart';

void main() {
  LanScannerIOS.registerForIOS();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'lan_scanner example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<HostModel> _hosts = <HostModel>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('lan_scanner example'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                final scanner = LanScanner();

                final stream = scanner.icmpScan(
                  '192.168.0',
                  progressCallback: (progress) {
                    if (kDebugMode) {
                      print('progress: $progress');
                    }
                  },
                );

                stream.listen((HostModel host) {
                  setState(() {
                    _hosts.add(host);
                  });
                });
              },
              child: const Text('Scan'),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final host = _hosts[index];

                return Card(
                  child: ListTile(
                    title: Text(host.ip),
                  ),
                );
              },
              itemCount: _hosts.length,
            ),
          ],
        ),
      ),
    );
  }
}
