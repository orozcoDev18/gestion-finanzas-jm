import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/ingreso.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/date_service.dart';
import '../widgets/motivational_overlay.dart';

class IngresosScreen extends StatefulWidget {
  final bool isDark;

  const IngresosScreen({super.key, required this.isDark});

  @override
  State<IngresosScreen> createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  String _selectedCategoria = 'Todos';

  bool get _isDark => widget.isDark;

  Color _bg() => _isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color _text() => _isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color _textSec() => _isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color _card() => _isDark ? AppColors.darkCard : AppColors.lightCard;
  Color _border() => _isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: _bg(),
      appBar: AppBar(
        backgroundColor: _bg(),
        title: Text('Ingresos', style: TextStyle(color: _text())),
        iconTheme: IconThemeData(color: _text()),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: user == null
                ? Center(child: Text('Inicia sesión', style: TextStyle(color: _textSec())))
                : _buildList(user.uid),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildList(String userId) {
    return StreamBuilder<List<Ingreso>>(
      stream: _firestoreService.getIngresos(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text('Error al cargar ingresos', style: TextStyle(color: _text(), fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', style: TextStyle(color: _textSec(), fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var ingresos = snapshot.data ?? [];
        if (_selectedCategoria != 'Todos') {
          ingresos = ingresos.where((i) => i.categoria == _selectedCategoria).toList();
        }

        if (ingresos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 64, color: _textSec()),
                const SizedBox(height: 16),
                Text('Sin ingresos registrados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textSec())),
                const SizedBox(height: 8),
                Text('Toca el botón + para agregar uno', style: TextStyle(fontSize: 13, color: _textSec())),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: ingresos.length,
          itemBuilder: (context, index) => _buildItem(ingresos[index]),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['Todos', ...Ingreso.categorias].map((cat) {
          final sel = _selectedCategoria == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat, style: TextStyle(fontSize: 12, color: sel ? AppColors.primary : _textSec())),
              selected: sel,
              onSelected: (_) => setState(() => _selectedCategoria = cat),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              side: BorderSide(color: sel ? AppColors.primary.withValues(alpha: 0.3) : _border()),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItem(Ingreso ingreso) {
    return Card(
      color: _card(),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _border(), width: 0.5)),
      child: ListTile(
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_downward_rounded, color: AppColors.success, size: 20),
        ),
        title: Text(ingreso.descripcion, style: TextStyle(fontWeight: FontWeight.w600, color: _text())),
        subtitle: Text(
          '${ingreso.categoria} · ${DateService.formatDateShort(ingreso.fecha)}',
          style: TextStyle(fontSize: 12, color: _textSec()),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+${_formatMonto(ingreso.monto)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 20, color: _textSec()),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.danger), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppColors.danger))])),
              ],
              onSelected: (v) {
                if (v == 'edit') _abrirFormulario(context, ingreso: ingreso);
                if (v == 'delete') _eliminar(ingreso);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonto(double monto) {
    return '\$${monto.toStringAsFixed(2)}';
  }

  void _abrirFormulario(BuildContext context, {Ingreso? ingreso}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FormularioIngreso(isDark: _isDark, ingreso: ingreso),
      ),
    );
    if (result == true && mounted) {
      MotivationalOverlay.show(context, isIngreso: true);
    }
  }

  void _eliminar(Ingreso ingreso) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Ingreso'),
        content: Text('¿Eliminar "${ingreso.descripcion}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _firestoreService.deleteIngreso(ingreso.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingreso eliminado'), backgroundColor: AppColors.danger),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
        }
      }
    }
  }
}

class _FormularioIngreso extends StatefulWidget {
  final bool isDark;
  final Ingreso? ingreso;

  const _FormularioIngreso({required this.isDark, this.ingreso});

  @override
  State<_FormularioIngreso> createState() => _FormularioIngresoState();
}

class _FormularioIngresoState extends State<_FormularioIngreso> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  String _categoria = Ingreso.categorias.first;
  DateTime _fecha = DateTime.now();
  bool _saving = false;

  bool get _editing => widget.ingreso != null;

  @override
  void initState() {
    super.initState();
    if (_editing) {
      _categoria = widget.ingreso!.categoria;
      _fecha = widget.ingreso!.fecha.toLocal();
      _descCtrl.text = widget.ingreso!.descripcion;
      _montoCtrl.text = widget.ingreso!.monto.toString();
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final txt = widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(icon: Icon(Icons.close, color: txt), onPressed: () => Navigator.pop(context)),
        title: Text(_editing ? 'Editar Ingreso' : 'Nuevo Ingreso', style: TextStyle(color: txt)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Descripción', hintText: 'Ej: Salario mensual', prefixIcon: Icon(Icons.description_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto', hintText: '0.00', prefixIcon: Icon(Icons.attach_money_rounded)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa un monto';
                  final m = double.tryParse(v);
                  if (m == null || m <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category_outlined)),
                items: Ingreso.categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) { if (v != null) setState(() => _categoria = v); },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: widget.isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                ),
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Fecha'),
                subtitle: Text(DateService.formatDate(_fecha)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) setState(() => _fecha = picked);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _guardar,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_editing ? 'Actualizar' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes iniciar sesión'), backgroundColor: AppColors.danger),
          );
          setState(() => _saving = false);
        }
        return;
      }

      final monto = double.parse(_montoCtrl.text);
      final desc = _descCtrl.text.trim();

      if (_editing) {
        await _firestoreService.updateIngreso(Ingreso(
          id: widget.ingreso!.id, userId: user.uid,
          descripcion: desc, monto: monto, fecha: _fecha.toUtc(),
          categoria: _categoria, createdAt: widget.ingreso!.createdAt,
        ));
      } else {
        await _firestoreService.addIngreso(Ingreso(
          id: '', userId: user.uid,
          descripcion: desc, monto: monto, fecha: _fecha.toUtc(),
          categoria: _categoria, createdAt: DateTime.now().toUtc(),
        ));
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger, duration: const Duration(seconds: 4)),
        );
        setState(() => _saving = false);
      }
    }
  }
}
