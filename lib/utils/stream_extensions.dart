import 'dart:async';

import 'package:flutter/foundation.dart';

extension StreamExtensions<T> on Stream<T> {
  Stream<T> throttle(Duration duration) {
    T? lastEvent;
    Timer? throttleTimer;
    StreamController<T> resultStreamController = StreamController<T>();

    listen((event) {
      if (throttleTimer != null) {
        lastEvent = event;
        return;
      }

      resultStreamController.add(event);
      throttleTimer = Timer(
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

  ChangeNotifier toChangeNotifier() {
    return StreamChangeNotifier<T>(this);
  }
}

class StreamChangeNotifier<T> extends ChangeNotifier {
  late final StreamSubscription<T> _subscription;

  StreamChangeNotifier(Stream<T> stream) {
    notifyListeners();
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
