import 'package:flutter/material.dart';

// スタートボタンウィジェット
class StartButton extends StatefulWidget {
  final AnimationController floatController;
  final Size size;
  final VoidCallback onTap;

  const StartButton({
    super.key,
    required this.floatController,
    required this.size,
    required this.onTap,
  });

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -8 * widget.floatController.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(
            0,
            _isPressed ? 4 : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isPressed
                  ? [
                      const Color(0xFFE6D4A8),
                      const Color(0xFFD4C296),
                      const Color(0xFFC4B086),
                    ]
                  : [
                      const Color(0xFFFFF9E6),
                      const Color(0xFFF5E6C8),
                      const Color(0xFFE6D4A8),
                    ],
            ),
            border: Border.all(
              color: const Color(0xFF8B6F47),
              width: 4,
            ),
            boxShadow: _isPressed
                ? [
                    const BoxShadow(
                      color: Color(0xFF6B5A3D),
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0xFF6B5A3D),
                      offset: Offset(0, 6),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 10),
                      blurRadius: 20,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.size.width * 0.12,
              vertical: widget.size.height * 0.02,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TAP TO START',
                  style: TextStyle(
                    fontSize: widget.size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C4B3A),
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'はじめる',
                  style: TextStyle(
                    fontSize: widget.size.width * 0.03,
                    color: const Color(0xFF5C4B3A).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
