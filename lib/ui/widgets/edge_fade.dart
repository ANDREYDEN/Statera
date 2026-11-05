import 'package:flutter/material.dart';

/// Fades out the edges of a scrollable child when there is more content
/// to scroll to in that direction. The fade grows stronger the more content
/// is hidden past that edge, up to [fadeExtent] pixels.
class EdgeFade extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller)
  builder;
  final Axis axis;

  /// Length (in logical pixels) of the faded area at each edge.
  final double fadeExtent;

  const EdgeFade({
    super.key,
    required this.builder,
    this.axis = Axis.horizontal,
    this.fadeExtent = 24,
  });

  @override
  State<EdgeFade> createState() => _EdgeFadeState();
}

class _EdgeFadeState extends State<EdgeFade> {
  static const _fadedAlpha = 13;
  static const _opaqueAlpha = 255;

  final ScrollController _controller = ScrollController();
  // 0 = no fade, 1 = full fade. Grows as there is more content past the edge.
  double _startStrength = 0;
  double _endStrength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFades);
    // Content size is only known after the first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        final length = widget.axis == Axis.horizontal
            ? bounds.width
            : bounds.height;
        final fraction = length == 0
            ? 0.0
            : (widget.fadeExtent / length).clamp(0.0, 0.5);

        final isHorizontal = widget.axis == Axis.horizontal;

        return LinearGradient(
          begin: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
          end: isHorizontal ? Alignment.centerRight : Alignment.bottomCenter,
          colors: [
            Colors.white.withAlpha(_alphaFor(_startStrength)),
            Colors.white,
            Colors.white,
            Colors.white.withAlpha(_alphaFor(_endStrength)),
          ],
          stops: [0, fraction, 1 - fraction, 1],
        ).createShader(bounds);
      },
      child: widget.builder(context, _controller),
    );
  }

  void _updateFades() {
    if (!mounted || !_controller.hasClients) return;

    final position = _controller.position;
    final startStrength = _strengthFor(position.extentBefore);
    final endStrength = _strengthFor(position.extentAfter);
    if (startStrength == _startStrength && endStrength == _endStrength) return;

    setState(() {
      _startStrength = startStrength;
      _endStrength = endStrength;
    });
  }

  /// Full strength once at least [EdgeFade.fadeExtent] of content is hidden.
  double _strengthFor(double hiddenExtent) {
    if (widget.fadeExtent <= 0) return 0;
    return (hiddenExtent / widget.fadeExtent).clamp(0.0, 1.0);
  }

  int _alphaFor(double strength) {
    return (_opaqueAlpha + (_fadedAlpha - _opaqueAlpha) * strength).round();
  }
}
