import 'dart:async';

class Throttle<S, T> implements StreamTransformer<S, T> {
  final Duration duration;

  Throttle(this.duration);

  @override
  Stream<T> bind(Stream<S> stream) {
    Timer? throttleTimer;
    final resultStreamController = StreamController<T>();

    stream.listen((event) {
      if (throttleTimer == null || !throttleTimer!.isActive) {
        throttleTimer = Timer(duration, () {});
        resultStreamController.add(event as T);
      }
    });

    return resultStreamController.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
