import 'package:flutter_test/flutter_test.dart';

import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/utils/calcular_indicadores.dart';

void main() {
  test('primeiro abastecimento não tem indicadores e o segundo calcula km/L e R\$/km', () {
    final abastecimentos = [
      Abastecimento(
        veiculoId: 1,
        combustivel: TipoCombustivel.gasolina,
        precoLitro: 6,
        quilometragem: 1000,
        litros: 40,
        data: DateTime(2026, 11, 1),
      ),
      Abastecimento(
        veiculoId: 1,
        combustivel: TipoCombustivel.gasolina,
        precoLitro: 5,
        quilometragem: 1400,
        litros: 40,
        data: DateTime(2026, 11, 10),
      ),
    ];

    final indicadores = calcularIndicadores(abastecimentos);

    expect(indicadores.first.temIndicadores, isFalse);
    expect(indicadores.last.distancia, 400);
    expect(indicadores.last.kmPorLitro, 10);
    expect(indicadores.last.custoPorKm, 0.5);
  });
}
