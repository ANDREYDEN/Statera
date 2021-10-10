import 'package:flutter/material.dart';
import 'package:statera/widgets/loader.dart';

class CustomStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext, T) builder;

  const CustomStreamBuilder(
      {Key? key, required this.stream, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: this.stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text("Error: ${snap.error}");
        }

        if (!snap.hasData || snap.connectionState == ConnectionState.waiting) {
          return Loader();
        }

        T data = snap.data!;

        return this.builder(context, data);
      },
    );
  }
}
