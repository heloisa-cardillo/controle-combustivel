import 'package:controle_combustivel/features/combustivel/data/database/banco_combustivel.dart';
import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/models/veiculo.dart';

class RepositorioCombustivel {
  final _bancoCombustivel = BancoCombustivel.instancia;

  Future<Veiculo?> buscarVeiculo() async {
    final db = await _bancoCombustivel.banco;
    final linhas = await db.query('veiculos', limit: 1);
    if (linhas.isEmpty) return null;
    return Veiculo.deMapa(linhas.first);
  }

  Future<Veiculo> salvarVeiculo(Veiculo veiculo) async {
    final db = await _bancoCombustivel.banco;

    final existente = await db.query('veiculos', limit: 1);
    if (existente.isNotEmpty) {
      throw Exception('Já existe um veículo cadastrado.');
    }

    final mapa = veiculo.paraMapa()..remove('id');
    final id = await db.insert('veiculos', mapa);
    return Veiculo.deMapa({...mapa, 'id': id});
  }

  // Apaga os abastecimentos do veículo e depois o veículo, tudo junto.
  Future<void> excluirVeiculo(int veiculoId) async {
    final db = await _bancoCombustivel.banco;
    await db.transaction((txn) async {
      await txn.delete(
        'abastecimentos',
        where: 'veiculo_id = ?',
        whereArgs: [veiculoId],
      );
      await txn.delete('veiculos', where: 'id = ?', whereArgs: [veiculoId]);
    });
  }

  Future<List<Abastecimento>> listarAbastecimentos(int veiculoId) async {
    final db = await _bancoCombustivel.banco;
    final linhas = await db.query(
      'abastecimentos',
      where: 'veiculo_id = ?',
      whereArgs: [veiculoId],
      orderBy: 'data ASC, quilometragem ASC',
    );
    return linhas.map(Abastecimento.deMapa).toList();
  }

  Future<void> salvarAbastecimento(Abastecimento abastecimento) async {
    final db = await _bancoCombustivel.banco;
    final mapa = abastecimento.paraMapa()..remove('id');
    await db.insert('abastecimentos', mapa);
  }

  Future<void> excluirAbastecimento(int id) async {
    final db = await _bancoCombustivel.banco;
    await db.delete('abastecimentos', where: 'id = ?', whereArgs: [id]);
  }
}
