import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _ingresos => _firestore.collection('ingresos');
  CollectionReference get _gastos => _firestore.collection('gastos');

  // ============ INGRESOS ============

  Future<void> addIngreso(Ingreso ingreso) async {
    try {
      await _ingresos.add(ingreso.toFirestore());
    } catch (e) {
      throw Exception('Error al guardar ingreso: $e');
    }
  }

  Future<void> updateIngreso(Ingreso ingreso) async {
    try {
      await _ingresos.doc(ingreso.id).update(ingreso.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar ingreso: $e');
    }
  }

  Future<void> deleteIngreso(String id) async {
    try {
      await _ingresos.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar ingreso: $e');
    }
  }

  Stream<List<Ingreso>> getIngresos(String userId) {
    return _ingresos
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Ingreso.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.fecha.compareTo(a.fecha));
          return list;
        });
  }

  Future<List<Ingreso>> getIngresosByMonth(String userId, int year, int month) async {
    try {
      final startOfMonth = DateTime.utc(year, month, 1);
      final endOfMonth = DateTime.utc(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _ingresos
          .where('userId', isEqualTo: userId)
          .get();

      final list = <Ingreso>[];
      for (final doc in snapshot.docs) {
        final ingreso = Ingreso.fromFirestore(doc);
        final fecha = ingreso.fecha.toUtc();
        if (!fecha.isBefore(startOfMonth) && !fecha.isAfter(endOfMonth)) {
          list.add(ingreso);
        }
      }
      list.sort((a, b) => b.fecha.compareTo(a.fecha));
      return list;
    } catch (e) {
      throw Exception('Error al obtener ingresos: $e');
    }
  }

  Future<double> getTotalIngresosByMonth(String userId, int year, int month) async {
    final ingresos = await getIngresosByMonth(userId, year, month);
    double total = 0.0;
    for (final i in ingresos) {
      total += i.monto;
    }
    return total;
  }

  // ============ GASTOS ============

  Future<void> addGasto(Gasto gasto) async {
    try {
      await _gastos.add(gasto.toFirestore());
    } catch (e) {
      throw Exception('Error al guardar gasto: $e');
    }
  }

  Future<void> updateGasto(Gasto gasto) async {
    try {
      await _gastos.doc(gasto.id).update(gasto.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar gasto: $e');
    }
  }

  Future<void> deleteGasto(String id) async {
    try {
      await _gastos.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar gasto: $e');
    }
  }

  Stream<List<Gasto>> getGastos(String userId) {
    return _gastos
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Gasto.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.fecha.compareTo(a.fecha));
          return list;
        });
  }

  Future<List<Gasto>> getGastosByMonth(String userId, int year, int month) async {
    try {
      final startOfMonth = DateTime.utc(year, month, 1);
      final endOfMonth = DateTime.utc(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _gastos
          .where('userId', isEqualTo: userId)
          .get();

      final list = <Gasto>[];
      for (final doc in snapshot.docs) {
        final gasto = Gasto.fromFirestore(doc);
        final fecha = gasto.fecha.toUtc();
        if (!fecha.isBefore(startOfMonth) && !fecha.isAfter(endOfMonth)) {
          list.add(gasto);
        }
      }
      list.sort((a, b) => b.fecha.compareTo(a.fecha));
      return list;
    } catch (e) {
      throw Exception('Error al obtener gastos: $e');
    }
  }

  Future<double> getTotalGastosByMonth(String userId, int year, int month) async {
    final gastos = await getGastosByMonth(userId, year, month);
    double total = 0.0;
    for (final g in gastos.where((g) => g.pagado)) {
      total += g.monto;
    }
    return total;
  }

  Future<Map<String, double>> getGastosByCategory(String userId, int year, int month) async {
    final gastos = await getGastosByMonth(userId, year, month);
    final Map<String, double> result = {};
    for (final gasto in gastos.where((g) => g.pagado)) {
      result[gasto.categoria] = (result[gasto.categoria] ?? 0) + gasto.monto;
    }
    return result;
  }
}
