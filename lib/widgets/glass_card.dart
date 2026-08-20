import 'package:flutter/material.dart';
import '../config/colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final bool isDark;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.8)
        : AppColors.lightCard.withValues(alpha: 0.8);
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: margin ?? EdgeInsets.zero,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
