enum TipoCombustivel { etanol, gasolina, diesel }

extension NomeCombustivel on TipoCombustivel {
  String get nome {
    switch (this) {
      case TipoCombustivel.etanol:
        return 'Etanol';
      case TipoCombustivel.gasolina:
        return 'Gasolina';
      case TipoCombustivel.diesel:
        return 'Diesel';
    }
  }
}

class Abastecimento {
  final int? id;
  final int veiculoId;
  final TipoCombustivel combustivel;
  final double precoLitro;
  final double quilometragem;
  final double litros;
  final DateTime data;

  const Abastecimento({
    this.id,
    required this.veiculoId,
    required this.combustivel,
    required this.precoLitro,
    required this.quilometragem,
    required this.litros,
    required this.data,
  });

  double get valorTotal => precoLitro * litros;

  Map<String, Object?> paraMapa() {
    return {
      'id': id,
      'veiculo_id': veiculoId,
      'combustivel': combustivel.name,
      'preco_litro': precoLitro,
      'quilometragem': quilometragem,
      'litros': litros,
      'data': data.toUtc().toIso8601String(),
    };
  }

  factory Abastecimento.deMapa(Map<String, Object?> mapa) {
    return Abastecimento(
      id: mapa['id'] as int?,
      veiculoId: mapa['veiculo_id'] as int,
      combustivel: TipoCombustivel.values.byName(mapa['combustivel'] as String),
      precoLitro: (mapa['preco_litro'] as num).toDouble(),
      quilometragem: (mapa['quilometragem'] as num).toDouble(),
      litros: (mapa['litros'] as num).toDouble(),
      data: DateTime.parse(mapa['data'] as String).toLocal(),
    );
  }
}
