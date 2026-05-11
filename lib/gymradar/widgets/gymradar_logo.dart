import 'package:flutter/material.dart';
import 'dart:math' as math;

class GymRadarLogo extends StatelessWidget {
  final double size;
  final Color logoColor;
  final Color bgColor;
  final bool showBackground;

  const GymRadarLogo({
    super.key,
    this.size = 100,
    this.logoColor = const Color(0xFFADFF2F),
    this.bgColor = Colors.black,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(size * 0.22),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.all(size * 0.08),
        child: CustomPaint(
          painter: _LogoPainter(color: logoColor),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  const _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stroke weight base — todo consistente
    final sw = w * 0.082;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawMagnifyingGlass(canvas, w, h, paint, sw);
    _drawDumbbell(canvas, w, h, paint, sw);
  }

  void _drawMagnifyingGlass(
      Canvas canvas, double w, double h, Paint paint, double sw) {
    // Lupa: círculo derecho + mango diagonal
    final cx = w * 0.60;
    final cy = h * 0.42;
    final r = w * 0.265;

    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Mango 45°
    const a = math.pi / 4;
    canvas.drawLine(
      Offset(cx + r * math.cos(a), cy + r * math.sin(a)),
      Offset(cx + r * 1.72 * math.cos(a), cy + r * 1.72 * math.sin(a)),
      paint,
    );
  }

  void _drawDumbbell(
      Canvas canvas, double w, double h, Paint paint, double sw) {
    final cy = h * 0.445;

    // Dimensiones de placas — proporcionales y visibles
    final outerW = w * 0.148; // placa exterior: ancha
    final outerH = h * 0.420;
    final innerW = w * 0.104;
    final innerH = h * 0.300;
    final sep = w * 0.016; // separación entre placas
    final r = Radius.circular(w * 0.040);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw * 0.65
      ..strokeCap = StrokeCap.round;

    // ── Lado izquierdo ──────────────────────────────────
    // Placa exterior izquierda
    final loX = w * 0.075 + outerW / 2;
    _fillRect(canvas, fillPaint, loX, cy, outerW, outerH, r);

    // Placa interior izquierda
    final liX = loX + outerW / 2 + sep + innerW / 2;
    _fillRect(canvas, fillPaint, liX, cy, innerW, innerH, r);

    // ── Barra ────────────────────────────────────────────
    final barX1 = liX + innerW / 2;
    final barX2 = w * 0.720;
    canvas.drawLine(Offset(barX1, cy), Offset(barX2, cy), barPaint);

    // ── Lado derecho ─────────────────────────────────────
    // Placa interior derecha
    final riX = barX2 + innerW / 2;
    _fillRect(canvas, fillPaint, riX, cy, innerW, innerH, r);

    // Placa exterior derecha
    final roX = riX + innerW / 2 + sep + outerW / 2;
    _fillRect(canvas, fillPaint, roX, cy, outerW, outerH, r);
  }

  void _fillRect(Canvas canvas, Paint paint, double cx, double cy,
      double w, double h, Radius r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
        r,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) => old.color != color;
}
