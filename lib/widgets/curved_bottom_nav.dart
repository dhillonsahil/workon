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
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _NavBarPainter(),
              child: const SizedBox(height: 70),
            ),
          ),

          // Center FAB
          Positioned(
            top: 0,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFF7E7C8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.black, size: 32),
                onPressed: onFabPressed,
              ),
            ),
          ),

          // Bottom Icons
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIcon(Icons.home_rounded, 0),
                _buildIcon(Icons.checklist_rounded, 1),
                const SizedBox(width: 60), // FAB space
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.grey.shade500,
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
      ..moveTo(0, 20)
      ..quadraticBezierTo(0, 0, 25, 0)
      ..lineTo(size.width * 0.33 - 35, 0)
      ..quadraticBezierTo(size.width * 0.33, 0, size.width * 0.33 + 10, 20)
      ..arcToPoint(
        Offset(size.width * 0.66 - 10, 20),
        radius: const Radius.circular(40),
        clockwise: false,
      )
      ..quadraticBezierTo(size.width * 0.66, 0, size.width * 0.66 + 35, 0)
      ..lineTo(size.width - 25, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(path, Colors.black, 8, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
