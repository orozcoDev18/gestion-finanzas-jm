import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/date_service.dart';
import '../services/avatar_service.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import '../widgets/avatar_picker.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  String _greetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '🌅';
    if (h < 18) return '☀️';
    return '🌙';
  }

  String _greetingText() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Color _headerStart() => widget.isDark ? const Color(0xFF1A237E) : const Color(0xFF007AFF);
  Color _headerEnd() => widget.isDark ? const Color(0xFF0D47A1) : const Color(0xFF5856D6);

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Inicia sesión')));
    }

    final year = DateService.currentYear;
    final month = DateService.currentMonth;
    final startOfMonth = DateTime.utc(year, month, 1);
    final endOfMonth = DateTime.utc(year, month + 1, 0, 23, 59, 59);

    return Scaffold(
      backgroundColor: widget.isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: StreamBuilder<List<Ingreso>>(
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
                final remaining = totalIngresos - totalGastos;

                final recentMoves = <Map<String, dynamic>>[];
                for (final i in allIngresos.take(3)) {
                  recentMoves.add({'tipo': 'ingreso', 'desc': i.descripcion, 'monto': i.monto, 'fecha': i.fecha});
                }
                for (final g in allGastos.take(3)) {
                  recentMoves.add({'tipo': 'gasto', 'desc': g.descripcion, 'monto': g.monto, 'fecha': g.fecha});
                }
                recentMoves.sort((a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
                final topMoves = recentMoves.take(5).toList();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(user, remaining, totalIngresos, totalGastos, year, month)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      sliver: SliverToBoxAdapter(child: _buildStatCards(totalIngresos, totalGastos)),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      sliver: SliverToBoxAdapter(child: _buildQuickActions()),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Movimientos recientes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                            GestureDetector(
                              onTap: () => widget.onNavigate(3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Ver todo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms),
                      ),
                    ),
                    if (topMoves.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                        sliver: SliverToBoxAdapter(child: _buildEmptyState()),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildMovementItem(topMoves[index], index),
                            childCount: topMoves.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user, double remaining, double totalIngresos, double totalGastos, int year, int month) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_headerStart(), _headerEnd()],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _headerStart().withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: GestureDetector(
                        onTap: () => AvatarPickerSheet.show(context),
                        child: Consumer<AvatarService>(
                          builder: (context, avatarService, _) {
                            return avatarService.buildAvatar(radius: 22, isDark: widget.isDark);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(_greetingEmoji(), style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                _greetingText(),
                                style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.displayName ?? user.email?.split('@')[0] ?? 'Usuario',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onToggleTheme,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onLogout,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Balance del mes',
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Formatters.currency(remaining),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateService.formatMonthYear(year, month),
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, curve: Curves.easeOut);
  }

  Widget _buildStatCards(double totalIngresos, double totalGastos) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Ingresos',
              value: Formatters.currency(totalIngresos),
              icon: Icons.arrow_downward_rounded,
              color: AppColors.success,
              isPositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Gastos',
              value: Formatters.currency(totalGastos),
              icon: Icons.arrow_upward_rounded,
              color: AppColors.danger,
              isPositive: false,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
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
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: isPositive ? AppColors.success : AppColors.danger,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildAction(
          icon: Icons.add_rounded,
          label: 'Ingreso',
          color: AppColors.success,
          onTap: () => widget.onNavigate(1),
        ),
        const SizedBox(width: 10),
        _buildAction(
          icon: Icons.remove_rounded,
          label: 'Gasto',
          color: AppColors.danger,
          onTap: () => widget.onNavigate(2),
        ),
        const SizedBox(width: 10),
        _buildAction(
          icon: Icons.pie_chart_rounded,
          label: 'Reportes',
          color: AppColors.purple,
          onTap: () => widget.onNavigate(3),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      isDark: widget.isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_rounded, size: 40, color: AppColors.primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin movimientos aún',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Agrega tu primer ingreso o gasto',
              style: TextStyle(fontSize: 13, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05);
  }

  Widget _buildMovementItem(Map<String, dynamic> move, int index) {
    final isIngreso = move['tipo'] == 'ingreso';
    final color = isIngreso ? AppColors.success : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark ? AppColors.darkCardBorder.withValues(alpha: 0.5) : AppColors.lightCardBorder.withValues(alpha: 0.5),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIngreso ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    move['desc'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateService.formatDateShort(move['fecha']),
                    style: TextStyle(fontSize: 12, color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isIngreso ? '+' : '-'}${Formatters.currency(move['monto'])}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: 0.03),
    );
  }
}
