import 'package:flutter/material.dart';
import '../../../../core/constants/orbit_theme.dart';

class QuotaBadge extends StatelessWidget {
  final int remaining;
  final int total;
  final VoidCallback? onTap;

  const QuotaBadge({
    super.key,
    required this.remaining,
    this.total = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = remaining < 10;
    final badgeColor = isLow ? OrbitTheme.marsCrimson : OrbitTheme.earthCyan;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: badgeColor.withAlpha(120), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: badgeColor, size: 14),
            const SizedBox(width: 4),
            Text(
              '$remaining/$total',
              style: TextStyle(
                color: badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
