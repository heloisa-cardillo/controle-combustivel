import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/models/indicador.dart';

// Recebe os abastecimentos em ordem de data (do mais antigo para o mais novo).
// O primeiro é só referência; a partir do segundo, calcula distância, km/L e R$/km.
List<Indicador> calcularIndicadores(List<Abastecimento> abastecimentos) {
  final indicadores = <Indicador>[];

  for (var i = 0; i < abastecimentos.length; i++) {
    final atual = abastecimentos[i];

    if (i == 0) {
      indicadores.add(Indicador(numero: 1, abastecimento: atual));
      continue;
    }

    final anterior = abastecimentos[i - 1];
    final distancia = atual.quilometragem - anterior.quilometragem;

    if (distancia <= 0 || atual.litros <= 0) {
      indicadores.add(Indicador(numero: i + 1, abastecimento: atual));
      continue;
    }

    indicadores.add(
      Indicador(
        numero: i + 1,
        abastecimento: atual,
        distancia: distancia,
        kmPorLitro: distancia / atual.litros,
        custoPorKm: atual.valorTotal / distancia,
      ),
    );
  }

  return indicadores;
}
