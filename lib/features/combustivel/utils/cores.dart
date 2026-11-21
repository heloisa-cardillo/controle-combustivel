import 'package:flutter/material.dart';

class Cores {
  static const fundo = Color(0xFFF5F7FA);
  static const azul = Color(0xFF2A49EB);
  static const azulClaro = Color(0xFF3366F0);
  static const titulo = Color(0xFF1F2937);
  static const texto = Color(0xFF374151);
  static const cinza = Color(0xFF6B7280);
  static const borda = Color(0xFFE5E7EB);
  static const erro = Color(0xFFEF4444);
  static const verde = Color(0xFF10B981);

  static const gradiente = LinearGradient(
    colors: [azul, azulClaro],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
