import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/colors.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'services/avatar_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ingresos_screen.dart';
import 'screens/gastos_screen.dart';
import 'screens/reportes_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ChangeNotifierProvider(
        create: (_) => AvatarService()..load(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: 'Gestión de Finanzas JM',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
              home: const AuthWrapper(),
            );
          },
        ),
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _showSplash = true;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onComplete: () => setState(() => _showSplash = false),
      );
    }

    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainNavigation();
        }

        if (_showRegister) {
          return RegisterScreen(
            onRegister: () => setState(() => _showRegister = false),
            onLogin: () => setState(() => _showRegister = false),
          );
        }

        return LoginScreen(
          onLogin: () {},
          onRegister: () => setState(() => _showRegister = true),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            isDark: isDark,
            onToggleTheme: themeProvider.toggleTheme,
            onLogout: _showLogoutDialog,
            onNavigate: (index) => setState(() => _currentIndex = index),
          ),
          IngresosScreen(isDark: isDark),
          GastosScreen(isDark: isDark),
          ReportesScreen(isDark: isDark),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withValues(alpha: 0.95)
                : AppColors.lightCard.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? AppColors.darkCardBorder.withValues(alpha: 0.5)
                  : AppColors.lightCardBorder.withValues(alpha: 0.8),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, isDark),
              _buildNavItem(1, Icons.arrow_downward_rounded, Icons.arrow_downward_outlined, isDark),
              _buildNavItem(2, Icons.arrow_upward_rounded, Icons.arrow_upward_outlined, isDark),
              _buildNavItem(3, Icons.pie_chart_rounded, Icons.pie_chart_outline_rounded, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, bool isDark) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey('$index-$isSelected'),
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 24,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        '',
                        style: TextStyle(fontSize: 0),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
