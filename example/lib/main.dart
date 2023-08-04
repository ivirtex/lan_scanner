import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() {
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

  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('lan_scanner example'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LinearProgressIndicator(value: progress),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    progress = 0.0;
                    _hosts.clear();
                  });

                  final scanner = LanScanner(debugLogging: true);
                  final stream = scanner.icmpScan(
                    ipToCSubnet(await NetworkInfo().getWifiIP() ?? ''),
                    scanThreads: 20,
                    progressCallback: (newProgress) {
                      setState(() {
                        progress = newProgress;
                      });

                      print('progress: $progress');
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
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _hosts.length,
                itemBuilder: (context, index) {
                  final host = _hosts[index];

                  return Card(
                    child: ListTile(
                      title: Text(host.ip),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
