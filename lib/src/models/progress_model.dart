/// Represents progress during scan operation
class ProgressModel {
  /// Constructor of the ProgressModel
  ProgressModel({
    required this.percent,
    required this.currIP,
  });

  /// Progress in percent
  double percent;

  /// IP address that is being pinged currently
  int currIP;
}
