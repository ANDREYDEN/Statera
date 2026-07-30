import 'package:flutter/material.dart';

// Named `SlideButton` (not `Slider`) to avoid clashing with material's Slider.
class SlideButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onSlideComplete;
  final Key? knobKey;

  const SlideButton({
    super.key,
    required this.text,
    required this.onSlideComplete,
    this.knobKey,
  });

  @override
  State<SlideButton> createState() => _SlideButtonState();
}

class _SlideButtonState extends State<SlideButton> {
  static const _knobSize = 48.0;
  static const _completionThreshold = 0.9;

  double _dragExtent = 0;
  bool _isDragging = false;
  bool _isCompleting = false;

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

  void _handleDragEnd(DragEndDetails details, double trackWidth) {
    if (_isCompleting) return;

    final reachedThreshold =
        _dragExtent >= _maxDragExtent(trackWidth) * _completionThreshold;

    setState(() => _isDragging = false);

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
        final trackWidth = constraints.maxWidth;

        return Container(
          height: _knobSize,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(_knobSize / 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                widget.text,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: _dragExtent,
                child: GestureDetector(
                  key: widget.knobKey,
                  onHorizontalDragStart: _handleDragStart,
                  onHorizontalDragUpdate: (details) =>
                      _handleDragUpdate(details, trackWidth),
                  onHorizontalDragEnd: (details) =>
                      _handleDragEnd(details, trackWidth),
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isCompleting
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Icon(Icons.check, color: colorScheme.onPrimary),
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
