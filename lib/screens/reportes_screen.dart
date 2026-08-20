import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/date_service.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import '../widgets/chart_widget.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';

class ReportesScreen extends StatefulWidget {
  final bool isDark;

  const ReportesScreen({super.key, required this.isDark});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateService.currentMonth;
    _selectedYear = DateService.currentYear;
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Inicia sesión')));
    }

    final startOfMonth = DateTime.utc(_selectedYear, _selectedMonth, 1);
    final endOfMonth = DateTime.utc(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: StreamBuilder<List<Ingreso>>(
        stream: _firestoreService.getIngresos(user.uid),
        builder: (context, ingresosSnap) {
          final allIngresos = ingresosSnap.data ?? [];
          final ingresosMes = allIngresos.where((i) {
            final f = i.fecha.toUtc();
            return !f.isBefore(startOfMonth) && !f.isAfter(endOfMonth);
          }).toList();
          final totalIngresos = ingresosMes.fold<double>(0, (s, i) => s + i.monto);

          return StreamBuilder<List<Gasto>>(
            stream: _firestoreService.getGastos(user.uid),
            builder: (context, gastosSnap) {
              final allGastos = gastosSnap.data ?? [];
              final gastosMes = allGastos.where((g) {
                final f = g.fecha.toUtc();
                return !f.isBefore(startOfMonth) && !f.isAfter(endOfMonth);
              }).toList();
              final gastosPagados = gastosMes.where((g) => g.pagado).toList();
              final totalGastos = gastosPagados.fold<double>(0, (s, g) => s + g.monto);
              final gastosByCategory = <String, double>{};
              for (final g in gastosPagados) {
                gastosByCategory[g.categoria] = (gastosByCategory[g.categoria] ?? 0) + g.monto;
              }

              final remaining = totalIngresos - totalGastos;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMonthSelector().animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    _buildSummaryCards(totalIngresos, totalGastos, remaining)
                        .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    _buildBarChart(totalIngresos, totalGastos)
                        .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    _buildPieChart(gastosByCategory)
                        .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return GlassCard(
      isDark: widget.isDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Column(
            children: [
              Text(
                DateService.formatMonth(_selectedMonth),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                _selectedYear.toString(),
                style: TextStyle(fontSize: 14, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double totalIngresos, double totalGastos, double remaining) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GlassCard(
                isDark: widget.isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.arrow_downward_rounded, color: AppColors.success, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text('Ingresos', style: TextStyle(fontSize: 13, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(Formatters.currency(totalIngresos), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                isDark: widget.isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.arrow_upward_rounded, color: AppColors.danger, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text('Gastos', style: TextStyle(fontSize: 13, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(Formatters.currency(totalGastos), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          isDark: widget.isDark,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (remaining >= 0 ? AppColors.primary : AppColors.danger).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(remaining >= 0 ? Icons.savings_rounded : Icons.warning_rounded, color: remaining >= 0 ? AppColors.primary : AppColors.danger, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balance del mes', style: TextStyle(fontSize: 13, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    Text(Formatters.currency(remaining), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: remaining >= 0 ? AppColors.success : AppColors.danger)),
                  ],
                ),
              ),
              if (totalIngresos > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${((remaining / totalIngresos) * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(double totalIngresos, double totalGastos) {
    return GlassCard(
      isDark: widget.isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ingresos vs Gastos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          const SizedBox(height: 16),
          BarChartWidget(ingresos: totalIngresos, gastos: totalGastos, isDark: widget.isDark),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    return GlassCard(
      isDark: widget.isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribución de Gastos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          const SizedBox(height: 16),
          ChartWidget(data: data, isDark: widget.isDark, size: 220),
        ],
      ),
    );
  }
}
