import 'package:flutter/material.dart';

import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/models/indicador.dart';
import 'package:controle_combustivel/features/combustivel/models/veiculo.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/grafico_linha.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/icone.dart';
import 'package:controle_combustivel/features/combustivel/utils/calcular_indicadores.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';
import 'package:controle_combustivel/features/combustivel/utils/formatar.dart';

class TelaDashboard extends StatelessWidget {
  final Veiculo veiculo;
  final List<Abastecimento> abastecimentos;

  const TelaDashboard({
    super.key,
    required this.veiculo,
    required this.abastecimentos,
  });

  @override
  Widget build(BuildContext context) {
    final indicadores = calcularIndicadores(abastecimentos);
    final comIndicadores = indicadores.where((i) => i.temIndicadores).toList();

    final totalGasto = abastecimentos.fold<double>(0, (soma, a) => soma + a.valorTotal);
    final mediaKmL = comIndicadores.isEmpty
        ? null
        : comIndicadores.fold<double>(0, (s, i) => s + i.kmPorLitro!) / comIndicadores.length;
    final mediaCusto = comIndicadores.isEmpty
        ? null
        : comIndicadores.fold<double>(0, (s, i) => s + i.custoPorKm!) / comIndicadores.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: abastecimentos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icone('coelho', tamanho: 64),
                    SizedBox(height: 12),
                    Text(
                      'Registre abastecimentos para ver os indicadores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Cores.cinza),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${veiculo.marca} ${veiculo.modelo}',
                  style: const TextStyle(color: Cores.cinza),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Resumo(
                        icone: 'wallet',
                        titulo: 'Total gasto',
                        valor: formatarReais(totalGasto),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Resumo(
                        icone: 'fuel',
                        titulo: 'Abastecimentos',
                        valor: '${abastecimentos.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Resumo(
                        icone: 'gauge',
                        titulo: 'Média km/L',
                        valor: mediaKmL == null ? '--' : formatarNumero(mediaKmL),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Resumo(
                        icone: 'route',
                        titulo: 'Média R\$/km',
                        valor: mediaCusto == null ? '--' : formatarReaisPorKm(mediaCusto),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Secao(
                  titulo: 'Consumo (km/L)',
                  child: comIndicadores.isEmpty
                      ? const _AvisoPoucosDados()
                      : GraficoLinha(
                          pontos: comIndicadores
                              .map((i) => PontoGrafico(numero: i.numero, valor: i.kmPorLitro!))
                              .toList(),
                          formatarValor: (v) => formatarNumero(v, casas: 1),
                        ),
                ),
                const SizedBox(height: 16),
                _Secao(
                  titulo: 'Custo por quilômetro (R\$/km)',
                  child: comIndicadores.isEmpty
                      ? const _AvisoPoucosDados()
                      : GraficoLinha(
                          cor: Cores.verde,
                          pontos: comIndicadores
                              .map((i) => PontoGrafico(numero: i.numero, valor: i.custoPorKm!))
                              .toList(),
                          formatarValor: (v) => formatarNumero(v, casas: 2),
                        ),
                ),
                const SizedBox(height: 16),
                _Secao(
                  titulo: 'Abastecimento por abastecimento',
                  child: _TabelaIndicadores(indicadores: indicadores),
                ),
              ],
            ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final String icone;
  final String titulo;
  final String valor;

  const _Resumo({required this.icone, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icone(icone, tamanho: 22),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(color: Cores.cinza, fontSize: 13)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Cores.titulo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final Widget child;

  const _Secao({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Cores.titulo,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _AvisoPoucosDados extends StatelessWidget {
  const _AvisoPoucosDados();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'O gráfico aparece a partir do 2º abastecimento.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Cores.cinza),
        ),
      ),
    );
  }
}

class _TabelaIndicadores extends StatelessWidget {
  final List<Indicador> indicadores;

  const _TabelaIndicadores({required this.indicadores});

  @override
  Widget build(BuildContext context) {
    const estiloCabecalho = TextStyle(
      fontWeight: FontWeight.w700,
      color: Cores.titulo,
      fontSize: 12,
    );
    const estiloCelula = TextStyle(fontSize: 12, color: Cores.texto);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 44,
        columnSpacing: 18,
        horizontalMargin: 0,
        columns: const [
          DataColumn(label: Text('#', style: estiloCabecalho)),
          DataColumn(label: Text('Data', style: estiloCabecalho)),
          DataColumn(label: Text('Valor', style: estiloCabecalho)),
          DataColumn(label: Text('km/L', style: estiloCabecalho)),
          DataColumn(label: Text('R\$/km', style: estiloCabecalho)),
        ],
        rows: indicadores
            .map(
              (i) => DataRow(
                cells: [
                  DataCell(Text('${i.numero}º', style: estiloCelula)),
                  DataCell(Text(formatarData(i.abastecimento.data), style: estiloCelula)),
                  DataCell(Text(formatarReais(i.abastecimento.valorTotal), style: estiloCelula)),
                  DataCell(Text(
                    i.kmPorLitro == null ? '--' : formatarNumero(i.kmPorLitro!),
                    style: estiloCelula,
                  )),
                  DataCell(Text(
                    i.custoPorKm == null ? '--' : formatarNumero(i.custoPorKm!, casas: 3),
                    style: estiloCelula,
                  )),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
