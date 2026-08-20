import 'package:cloud_firestore/cloud_firestore.dart';

class Gasto {
  final String id;
  final String userId;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final bool pagado;
  final DateTime createdAt;

  Gasto({
    required this.id,
    required this.userId,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.categoria,
    this.pagado = true,
    required this.createdAt,
  });

  factory Gasto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gasto(
      id: doc.id,
      userId: data['userId'] ?? '',
      descripcion: data['descripcion'] ?? '',
      monto: (data['monto'] ?? 0).toDouble(),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoria: data['categoria'] ?? 'General',
      pagado: data['pagado'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
      'categoria': categoria,
      'pagado': pagado,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static List<String> categorias = [
    'Alimentación',
    'Transporte',
    'Vivienda',
    'Servicios',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Ropa',
    'Otros',
  ];
}
