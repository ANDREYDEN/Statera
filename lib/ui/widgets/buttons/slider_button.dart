import 'package:flutter/material.dart';
import 'package:statera/ui/styling/spacing.dart';

class SliderButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onSlideComplete;
  final Key? knobKey;

  const SliderButton({
    super.key,
    required this.text,
    required this.onSlideComplete,
    this.knobKey,
  });

  @override
  State<SliderButton> createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton> {
  static const _knobSize = 32.0;
  static const _completionThreshold = 0.95;
  static const _animationDuration = Duration(milliseconds: 200);

  double _dragExtent = 0;
  bool _isDragging = false;
  bool _isCompleting = false;

  Duration get _currentAnimationDuration =>
      _isDragging ? Duration.zero : _animationDuration;

  double _maxDragExtent(double trackWidth) => trackWidth - _knobSize;

  void _handleDragStart(DragStartDetails details) {
    if (_isCompleting) return;

    setState(() => _isDragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (_isCompleting) return;

    setState(() {
      _dragExtent = (_dragExtent + details.delta.dx).clamp(
        0,
        _maxDragExtent(trackWidth),
      );
    });
  }

  void _handleDragEnd(double trackWidth) {
    if (_isCompleting) return;

    setState(() => _isDragging = false);

    final reachedThreshold =
        _dragExtent >= _maxDragExtent(trackWidth) * _completionThreshold;

    if (reachedThreshold) {
      _complete(trackWidth);
    } else {
      setState(() => _dragExtent = 0);
    }
  }

  Future<void> _complete(double trackWidth) async {
    setState(() {
      _isCompleting = true;
      _dragExtent = _maxDragExtent(trackWidth);
    });

    try {
      await widget.onSlideComplete();
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
          _dragExtent = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = Spacing.xs_5;
        final trackWidth = constraints.maxWidth - padding * 2;

        return Container(
          height: _knobSize + padding * 2,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(1000),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                widget.text,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              Positioned(
                left: 0,
                child: AnimatedContainer(
                  duration: _currentAnimationDuration,
                  curve: Curves.easeOut,
                  width: _dragExtent + _knobSize,
                  height: _knobSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _currentAnimationDuration,
                curve: Curves.easeOut,
                left: _dragExtent,
                child: GestureDetector(
                  key: widget.knobKey,
                  onHorizontalDragStart: _handleDragStart,
                  onHorizontalDragUpdate: (details) =>
                      _handleDragUpdate(details, trackWidth),
                  onHorizontalDragEnd: (_) => _handleDragEnd(trackWidth),
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isCompleting
                        ? Padding(
                            padding: const EdgeInsets.all(Spacing.xs_5),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            size: 32,
                            color: colorScheme.onPrimary,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
