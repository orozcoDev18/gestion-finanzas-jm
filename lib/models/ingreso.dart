import 'package:cloud_firestore/cloud_firestore.dart';

class Ingreso {
  final String id;
  final String userId;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final DateTime createdAt;

  Ingreso({
    required this.id,
    required this.userId,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.categoria,
    required this.createdAt,
  });

  factory Ingreso.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ingreso(
      id: doc.id,
      userId: data['userId'] ?? '',
      descripcion: data['descripcion'] ?? '',
      monto: (data['monto'] ?? 0).toDouble(),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoria: data['categoria'] ?? 'General',
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static List<String> categorias = [
    'Salario',
    'Freelance',
    'Inversiones',
    'Ventas',
    'Otros',
  ];
}
