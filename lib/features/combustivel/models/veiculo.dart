class Veiculo {
  final int? id;
  final String marca;
  final String codigoMarca;
  final String modelo;
  final int ano;
  final double cilindrada;

  const Veiculo({
    this.id,
    required this.marca,
    required this.codigoMarca,
    required this.modelo,
    required this.ano,
    required this.cilindrada,
  });

  Map<String, Object?> paraMapa() {
    return {
      'id': id,
      'marca': marca,
      'codigo_marca': codigoMarca,
      'modelo': modelo,
      'ano': ano,
      'cilindrada': cilindrada,
    };
  }

  factory Veiculo.deMapa(Map<String, Object?> mapa) {
    return Veiculo(
      id: mapa['id'] as int?,
      marca: mapa['marca'] as String,
      codigoMarca: mapa['codigo_marca'] as String,
      modelo: mapa['modelo'] as String,
      ano: mapa['ano'] as int,
      cilindrada: (mapa['cilindrada'] as num).toDouble(),
    );
  }
}
