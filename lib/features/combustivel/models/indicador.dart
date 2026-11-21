import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';

class Indicador {
  final int numero;
  final Abastecimento abastecimento;
  final double? distancia;
  final double? kmPorLitro;
  final double? custoPorKm;

  const Indicador({
    required this.numero,
    required this.abastecimento,
    this.distancia,
    this.kmPorLitro,
    this.custoPorKm,
  });

  bool get temIndicadores => kmPorLitro != null && custoPorKm != null;
}
