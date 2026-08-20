import 'package:flutter/material.dart';
import '../config/colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final bool isPositive;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.isDark = false,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.8)
        : AppColors.lightCard.withValues(alpha: 0.8);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder)
              .withValues(alpha: 0.5),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.success : AppColors.danger,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
