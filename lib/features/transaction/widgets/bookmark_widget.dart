import 'package:flutter/material.dart';
import 'painters.dart';

class BookmarkWidget extends StatelessWidget {
  final bool isToday;

  const BookmarkWidget({
    super.key,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 60,
      child: AnimatedOpacity(
        opacity: isToday ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 30,
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF69B4),
                Color(0xFFFF1493),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // リボンの光沢
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // リボンの切れ込み
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(30, 20),
                  painter: RibbonCutPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
