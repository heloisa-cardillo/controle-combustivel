import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:controle_combustivel/features/combustivel/models/marca.dart';

class ErroFipe implements Exception {
  final String mensagem;
  const ErroFipe(this.mensagem);

  @override
  String toString() => mensagem;
}

// Consulta marcas e modelos de carros na tabela FIPE pela BrasilAPI.
class ServicoFipe {
  static const _base = 'https://brasilapi.com.br/api/fipe';
  static const _tempoLimite = Duration(seconds: 15);

  Future<List<Marca>> buscarMarcas() async {
    final dados = await _get('$_base/marcas/v1/carros');
    final marcas = dados
        .whereType<Map<String, dynamic>>()
        .map(Marca.deJson)
        .where((marca) => marca.nome.isNotEmpty)
        .toList();
    marcas.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return marcas;
  }

  Future<List<String>> buscarModelos(String codigoMarca) async {
    final dados = await _get('$_base/veiculos/v1/carros/$codigoMarca');
    final modelos = dados
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['modelo'] ?? item['nome'] ?? '').toString().trim())
        .where((modelo) => modelo.isNotEmpty)
        .toSet()
        .toList();
    modelos.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return modelos;
  }

  Future<List<dynamic>> _get(String url) async {
    try {
      final resposta = await http.get(Uri.parse(url)).timeout(_tempoLimite);

      if (resposta.statusCode != 200) {
        throw const ErroFipe('A BrasilAPI está indisponível. Tente de novo.');
      }

      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (corpo is! List) {
        throw const ErroFipe('A BrasilAPI devolveu uma resposta inesperada.');
      }
      return corpo;
    } on ErroFipe {
      rethrow;
    } on SocketException {
      throw const ErroFipe('Sem conexão com a internet.');
    } on TimeoutException {
      throw const ErroFipe('A BrasilAPI demorou para responder. Tente de novo.');
    } on FormatException {
      throw const ErroFipe('A BrasilAPI devolveu uma resposta inválida.');
    } catch (_) {
      throw const ErroFipe('Não foi possível consultar a BrasilAPI.');
    }
  }
}
