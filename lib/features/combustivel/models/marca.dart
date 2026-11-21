class Marca {
  final String nome;
  final String codigo;

  const Marca({required this.nome, required this.codigo});

  factory Marca.deJson(Map<String, dynamic> json) {
    return Marca(
      nome: json['nome'].toString(),
      codigo: json['valor'].toString(),
    );
  }
}
