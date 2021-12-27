// Flutter imports:
import 'package:flutter/foundation.dart';

class ProgressModel extends ChangeNotifier {
  ProgressModel({this.progress = 0.0, this.isDoneScanning = true});

  double progress;
  bool isDoneScanning;

  void setProgress(double value) {
    progress = value;
    notifyListeners();
  }

  void changeIsDoneStateTo(bool value) {
    isDoneScanning = value;
    notifyListeners();
  }
}
