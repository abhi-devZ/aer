import 'package:flutter/material.dart';
import 'dart:math' as math;

enum GradientShadowStyle { none, rotate, pulse, wave, bounce }

class AdvancedGradientShadowContainer extends StatefulWidget {
  final Widget child;
  final double width;
  final double? height;
  final List<Color> gradientColors;
  final Duration duration;
  final double shadowSpread;
  final double shadowBlur;
  final GradientShadowStyle style;
  final Curve curve;
  final bool pauseOnHover;
  final Color color;

  const AdvancedGradientShadowContainer(
      {super.key,
      required this.child,
      this.width = 200,
      this.height,
      this.gradientColors = const [
        Colors.blue,
        Colors.purple,
        Colors.green,
        Colors.orange,
      ],
      this.duration = const Duration(seconds: 3),
      this.shadowSpread = 20,
      this.shadowBlur = 30,
      this.style = GradientShadowStyle.none,
      this.curve = Curves.easeInOut,
      this.pauseOnHover = true,
      this.color = Colors.white});

  @override
  State<AdvancedGradientShadowContainer> createState() => _AdvancedGradientShadowContainerState();
}

class _AdvancedGradientShadowContainerState extends State<AdvancedGradientShadowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BoxShadow> _generateShadows(double animationValue) {
    switch (widget.style) {
      case GradientShadowStyle.none:
        return _noShadow;
      case GradientShadowStyle.rotate:
        return _rotatingGradientShadows(animationValue);
      case GradientShadowStyle.pulse:
        return _pulsingGradientShadows(animationValue);
      case GradientShadowStyle.wave:
        return _wavingGradientShadows(animationValue);
      case GradientShadowStyle.bounce:
        return _bouncingGradientShadows(animationValue);
    }
  }

  List<BoxShadow> get _noShadow => [
        const BoxShadow(
          color: Colors.white38,
          blurRadius: 1,
          spreadRadius: 1,
        ),
      ];

  List<BoxShadow> _rotatingGradientShadows(double animationValue) {
    return [
      for (final color in widget.gradientColors)
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: widget.shadowBlur,
          spreadRadius: widget.shadowSpread,
          offset: Offset(
            widget.shadowSpread *
                math.cos(animationValue * 2 * math.pi + widget.gradientColors.indexOf(color) * math.pi / 2),
            widget.shadowSpread *
                math.sin(animationValue * 2 * math.pi + widget.gradientColors.indexOf(color) * math.pi / 2),
          ),
        ),
    ];
  }

  List<BoxShadow> _pulsingGradientShadows(double animationValue) {
    final pulseScale = 0.5 + math.sin(animationValue * 2 * math.pi) * 0.5;
    return [
      for (final color in widget.gradientColors)
        BoxShadow(
          color: color.withOpacity(0.3 * pulseScale),
          blurRadius: widget.shadowBlur * pulseScale,
          spreadRadius: widget.shadowSpread * pulseScale,
          offset: Offset.zero,
        ),
    ];
  }

  List<BoxShadow> _wavingGradientShadows(double animationValue) {
    return [
      for (final color in widget.gradientColors)
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: widget.shadowBlur,
          spreadRadius: widget.shadowSpread *
              (0.8 +
                  math.sin(animationValue * 2 * math.pi + widget.gradientColors.indexOf(color) * math.pi / 2) * 0.2),
          offset: Offset.zero,
        ),
    ];
  }

  List<BoxShadow> _bouncingGradientShadows(double animationValue) {
    final bounce = math.sin(animationValue * 2 * math.pi) * widget.shadowSpread;
    return [
      for (final color in widget.gradientColors)
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: widget.shadowBlur,
          spreadRadius: widget.shadowSpread,
          offset: Offset(0, bounce),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.pauseOnHover) {
          setState(() {
            isHovered = true;
          });
          _controller.stop();
        }
      },
      onExit: (_) {
        if (widget.pauseOnHover) {
          setState(() {
            isHovered = false;
          });
          _controller.repeat();
        }
      },
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ),
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(50),
                boxShadow: _generateShadows(_controller.value)),
            child: widget.child,
          );
        },
      ),
    );
  }
}
