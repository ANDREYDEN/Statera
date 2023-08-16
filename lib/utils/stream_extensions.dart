import 'dart:async';

extension StreamExtensions<T> on Stream<T> {
  Stream<T> throttle(Duration duration) {
    T? lastEvent;
    Timer? throttleTimer;
    StreamController<T> resultStreamController = StreamController<T>();

    listen((event) {
      lastEvent = event;
      throttleTimer ??= Timer(
        duration,
        () {
          throttleTimer = null;
          if (lastEvent != null) {
            resultStreamController.add(lastEvent!);
            lastEvent = null;
          }
        },
      );
    });

    return resultStreamController.stream;
  }
}
