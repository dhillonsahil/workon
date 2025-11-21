// lib/widgets/curved_bottom_nav.dart
import 'package:flutter/material.dart';

class CurvedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFabPressed;

  const CurvedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    // This makes the nav bar respect the gesture/home bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 90 + bottomPadding, // Extra space for gesture bar
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Curved background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _NavBarPainter(),
              child: SizedBox(
                height: 80 + bottomPadding,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // FAB — Raised higher & safe
          Positioned(
            top: 0,
            child: Transform.translate(
              offset: const Offset(0, -12), // Pulls it up more
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E7C8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.black87, size: 36),
                  onPressed: onFabPressed,
                ),
              ),
            ),
          ),

          // Bottom Icons Row
          Positioned(
            bottom: 22 + bottomPadding / 2, // Perfectly above gesture bar
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIcon(Icons.home_rounded, 0),
                _buildIcon(Icons.checklist_rounded, 1),
                const SizedBox(width: 80), // FAB space
                _buildIcon(Icons.bar_chart_rounded, 2),
                _buildIcon(Icons.settings_rounded, 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.4), width: 2)
              : null,
        ),
        child: Icon(
          icon,
          size: 30,
          color: isSelected ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D1D1D)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 25)
      ..quadraticBezierTo(0, 0, 30, 0)
      ..lineTo(size.width * 0.35 - 40, 0)
      ..cubicTo(
        size.width * 0.35 - 10,
        0,
        size.width * 0.35 + 10,
        20,
        size.width * 0.5,
        20,
      )
      ..cubicTo(
        size.width * 0.65 - 10,
        20,
        size.width * 0.65 + 10,
        0,
        size.width * 0.65 + 40,
        0,
      )
      ..lineTo(size.width - 30, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 25)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.6), 12, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
