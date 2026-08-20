import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/colors.dart';

class ChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final bool isDark;
  final double size;

  const ChartWidget({
    super.key,
    required this.data,
    this.isDark = false,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            'Sin datos',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: size,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: size * 0.2,
                sections: _buildSections(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = data.values.fold(0.0, (sum, v) => sum + v);
    final entries = data.entries.toList();

    return List.generate(entries.length, (i) {
      final entry = entries[i];
      final percent = (entry.value / total * 100);
      final color = AppColors.chartColors[i % AppColors.chartColors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: size * 0.15,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend() {
    final entries = data.entries.toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(entries.length, (i) {
        final entry = entries[i];
        final color = AppColors.chartColors[i % AppColors.chartColors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${entry.value.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final double ingresos;
  final double gastos;
  final bool isDark;

  const BarChartWidget({
    super.key,
    required this.ingresos,
    required this.gastos,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = ingresos > gastos ? ingresos : gastos;
    final chartMax = maxY > 0 ? maxY * 1.2 : 100.0;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chartMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIdx, rod, rodIdx) {
                return BarTooltipItem(
                  '\$${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Ingresos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      );
                    case 1:
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Gastos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      );
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartMax / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder)
                  .withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: ingresos,
                  color: AppColors.success,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: chartMax,
                    color: AppColors.success.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: gastos,
                  color: AppColors.danger,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: chartMax,
                    color: AppColors.danger.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
