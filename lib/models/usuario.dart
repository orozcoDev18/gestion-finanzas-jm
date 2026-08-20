import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String email;
  final String nombre;
  final DateTime createdAt;

  Usuario({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.createdAt,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
