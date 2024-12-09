import 'dart:async';

class TimerService {
  Timer? _timer;
  int _seconds = 0;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _seconds++;
      // Update UI or notify listeners
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  int get seconds => _seconds;
}