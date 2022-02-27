// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:lan_scanner/lan_scanner.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:lan_scanner_example/models/progress_model.dart';
import 'components/list_builder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProgressModel(),
      child: const MyApp(),
    ),
  );
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

  double scanSpeed = 10;
  bool isScanning = false;

  void update() {
    // TODO: not updating for some reason idk i will fix this later i wanna go to sleep now
    context.read<ProgressModel>().changeIsDoneStateTo(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Selector<ProgressModel, double>(
                selector: (context, model) => model.progress,
                builder: (context, double progress, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: LinearProgressIndicator(value: progress),
                        ),
                      ),
                      Text('$progress'),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: scanSpeed,
                      min: 1,
                      max: 20,
                      divisions: 20,
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
              Visibility(
                visible: isScanning,
                child: StreamBuilder(
                  stream: scanner.icmpScan(
                    '192.168.0',
                    scanThreads: scanSpeed.toInt(),
                    timeout: const Duration(seconds: 1),
                    progressCallback: (String progress) {
                      // print('Progress: $progress %');

                      context
                          .read<ProgressModel>()
                          .setProgress(double.parse(progress));
                    },
                  ),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<HostModel> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      hosts.add(snapshot.data!);
                    }

                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return buildHostsListView(hosts);
                      case ConnectionState.waiting:
                        return const Text("Waiting for data...");
                      case ConnectionState.active:
                        return buildHostsListView(hosts);
                      case ConnectionState.done:
                        WidgetsBinding.instance!
                            .addPostFrameCallback((_) => update);

                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          return buildHostsListView(hosts);
                        }
                      default:
                        return const Text("Unknown state");
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<ProgressModel>(
        builder: (context, model, child) {
          return FloatingActionButton(
            onPressed: () {
              model.changeIsDoneStateTo(!model.isDoneScanning);
              hosts.clear();

              setState(() {
                isScanning = !isScanning;
              });
            },
            tooltip: 'Start scanning',
            child: model.isDoneScanning
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.stop),
          );
        },
      ),
    );
  }
}
