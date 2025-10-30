import 'dart:math' as math;
import 'package:flutter/material.dart';

// 紙のテクスチャを描画するCustomPainter
class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF9F0)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 紙の質感を表現する微細なノイズ
    final random = math.Random(42);
    final noisePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = random.nextDouble() * 0.03;

      noisePaint.color = const Color(0xFFD2B48C).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5, noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 罫線背景を描画するCustomPainter
class NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 横罫線
    final linePaint = Paint()
      ..color = const Color(0xFFE8DCC8).withOpacity(0.5)
      ..strokeWidth = 1.5;

    const lineSpacing = 28.0;

    for (double y = 60; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // 左マージン線（より目立つように）
    final marginPaint = Paint()
      ..color = const Color(0xFFFFB6C1).withOpacity(0.5)
      ..strokeWidth = 2.5;

    canvas.drawLine(
      const Offset(40, 0),
      Offset(40, size.height),
      marginPaint,
    );

    // マージン線に沿った装飾的なステッチ風のライン
    final stitchPaint = Paint()
      ..color = const Color(0xFFFFB6C1).withOpacity(0.3)
      ..strokeWidth = 1;

    for (double y = 10; y < size.height; y += 15) {
      canvas.drawLine(
        const Offset(38, 0).translate(0, y),
        const Offset(38, 0).translate(0, y + 8),
        stitchPaint,
      );
      canvas.drawLine(
        const Offset(42, 0).translate(0, y),
        const Offset(42, 0).translate(0, y + 8),
        stitchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// リボンの切れ込みを描画するCustomPainter
class RibbonCutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF1493)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
