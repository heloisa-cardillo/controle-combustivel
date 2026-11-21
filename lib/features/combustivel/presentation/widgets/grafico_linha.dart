import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:controle_combustivel/features/combustivel/utils/cores.dart';

class PontoGrafico {
  final int numero;
  final double valor;

  const PontoGrafico({required this.numero, required this.valor});
}

// Gráfico de linha da evolução de um indicador, abastecimento a abastecimento.
class GraficoLinha extends StatelessWidget {
  final List<PontoGrafico> pontos;
  final Color cor;
  final String Function(double valor) formatarValor;

  const GraficoLinha({
    super.key,
    required this.pontos,
    required this.formatarValor,
    this.cor = Cores.azul,
  });

  @override
  Widget build(BuildContext context) {
    final valores = pontos.map((ponto) => ponto.valor).toList();
    final menor = valores.reduce((a, b) => a < b ? a : b);
    final maior = valores.reduce((a, b) => a > b ? a : b);
    final folga = (maior - menor).abs() < 0.0001 ? (maior.abs() * 0.2 + 0.1) : (maior - menor) * 0.2;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: (menor - folga) < 0 ? 0 : menor - folga,
          maxY: maior + folga,
          minX: pontos.first.numero.toDouble() - 0.3,
          maxX: pontos.last.numero.toDouble() + 0.3,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Cores.borda, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (valor, meta) {
                  if (valor == meta.min || valor == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    formatarValor(valor),
                    style: const TextStyle(fontSize: 10, color: Cores.cinza),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (valor, meta) {
                  final ehInteiro = valor == valor.roundToDouble();
                  final existe = pontos.any((p) => p.numero == valor.round());
                  if (!ehInteiro || !existe) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${valor.round()}º',
                      style: const TextStyle(fontSize: 11, color: Cores.cinza),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Cores.titulo,
              getTooltipItems: (itens) => itens
                  .map(
                    (item) => LineTooltipItem(
                      '${item.x.round()}º abastecimento\n${formatarValor(item.y)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: pontos
                  .map((ponto) => FlSpot(ponto.numero.toDouble(), ponto.valor))
                  .toList(),
              isCurved: pontos.length > 2,
              preventCurveOverShooting: true,
              color: cor,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: cor.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
