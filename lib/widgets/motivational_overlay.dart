import 'dart:math';
import 'package:flutter/material.dart';

class MotivationalOverlay {
  static void show(BuildContext context, {required bool isIngreso}) {
    final messages = isIngreso
        ? [
            {'emoji': '🎉', 'text': '¡Genial, sigue así!', 'sub': 'Cada peso cuenta para tu futuro'},
            {'emoji': '🔥', 'text': '¡Dinero entrando!', 'sub': 'Así se construye la libertad financiera'},
            {'emoji': '💪', 'text': '¡Sigue así, campeón!', 'sub': 'Tu bolsillo te lo va a agradecer'},
            {'emoji': '🚀', 'text': '¡A volar!', 'sub': 'Cada ingreso es un paso hacia tus metas'},
            {'emoji': '✨', 'text': '¡Excelente movimiento!', 'sub': 'El dinero trabaja para ti'},
            {'emoji': '💰', 'text': '¡Ahhh el sonido del éxito!', 'sub': 'Dinero nuevo, posibilidades nuevas'},
            {'emoji': '🏆', 'text': '¡Eres un crack financiero!', 'sub': 'Sigues sumando como campeón'},
          ]
        : [
            {'emoji': '😎', 'text': '¡Pagado y tranquilo!', 'sub': 'Debes menos, respiras mejor'},
            {'emoji': '💪', 'text': 'Menos deuda, más libertad', 'sub': 'En la próxima te queda más dinero'},
            {'emoji': '🎉', 'text': '¡Ya casi te puedes dar los lujitos!', 'sub': 'Sigue pagando y llega el premio'},
            {'emoji': '🧠', 'text': '¡Muy inteligente pagar a tiempo!', 'sub': 'Tu futuro yo te lo agradece'},
            {'emoji': '🌟', 'text': '¡Otro gasto conquistado!', 'sub': 'Debes menos, vives más tranquilo'},
            {'emoji': '⚡', 'text': '¡Listo, saldo a tu favor!', 'sub': 'Ese dinero ya no te pesa'},
            {'emoji': '🎯', 'text': '¡Directo al blanco!', 'sub': 'Pagaste, ahora el dinero es tuyo libre'},
          ];

    final msg = messages[Random().nextInt(messages.length)];

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _MotivationalWidget(
        emoji: msg['emoji']!,
        text: msg['text']!,
        sub: msg['sub']!,
        isIngreso: isIngreso,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _MotivationalWidget extends StatefulWidget {
  final String emoji;
  final String text;
  final String sub;
  final bool isIngreso;
  final VoidCallback onDismiss;

  const _MotivationalWidget({
    required this.emoji,
    required this.text,
    required this.sub,
    required this.isIngreso,
    required this.onDismiss,
  });

  @override
  State<_MotivationalWidget> createState() => _MotivationalWidgetState();
}

class _MotivationalWidgetState extends State<_MotivationalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 15),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.15)),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack)));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isIngreso ? const Color(0xFF34C759) : const Color(0xFF007AFF);

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.35,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: child,
              ),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.sub,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
