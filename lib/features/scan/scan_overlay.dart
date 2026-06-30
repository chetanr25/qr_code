import 'package:flutter/material.dart';

/// Dimmed surround + rounded cutout window + sweeping laser line.
class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final window = size.width * 0.68;
    return LayoutBuilder(
      builder: (context, constraints) {
        final rect = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
          width: window,
          height: window,
        );
        return IgnorePointer(
          child: Stack(
            children: [
              // dim mask with cut-out
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _MaskPainter(rect),
              ),
              // corner brackets
              Positioned.fromRect(
                rect: rect,
                child: CustomPaint(painter: _CornerPainter()),
              ),
              // laser
              Positioned.fromRect(
                rect: rect,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment(0, _ctrl.value * 2 - 1),
                      child: Container(
                        height: 2.5,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0x006366F1),
                            Color(0xFF8B5CF6),
                            Color(0x006366F1),
                          ]),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.7),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaskPainter extends CustomPainter {
  _MaskPainter(this.window);
  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(window, const Radius.circular(28)));
    final mask = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(mask, Paint()..color = Colors.black.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(covariant _MaskPainter old) => old.window != window;
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 28.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    // TL
    canvas.drawLine(const Offset(0, len), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    // TR
    canvas.drawLine(Offset(w - len, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);
    // BL
    canvas.drawLine(Offset(0, h - len), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    // BR
    canvas.drawLine(Offset(w - len, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
