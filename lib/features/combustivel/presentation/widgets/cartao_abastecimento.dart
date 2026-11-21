import 'package:flutter/material.dart';

import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/models/indicador.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/icone.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';
import 'package:controle_combustivel/features/combustivel/utils/formatar.dart';

class CartaoAbastecimento extends StatelessWidget {
  final Indicador indicador;
  final VoidCallback? aoExcluir;

  const CartaoAbastecimento({super.key, required this.indicador, this.aoExcluir});

  @override
  Widget build(BuildContext context) {
    final abastecimento = indicador.abastecimento;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icone('fuel'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${abastecimento.combustivel.nome}  •  ${formatarDataHora(abastecimento.data)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Cores.titulo,
                    ),
                  ),
                ),
                InkWell(
                  onTap: aoExcluir,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icone('trash_2', tamanho: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              formatarReais(abastecimento.valorTotal),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Cores.azul,
              ),
            ),
            Text(
              '${formatarNumero(abastecimento.litros)} L × ${formatarReais(abastecimento.precoLitro)}  •  ${formatarQuilometragem(abastecimento.quilometragem)}',
              style: const TextStyle(color: Cores.cinza, fontSize: 13),
            ),
            const SizedBox(height: 10),
            if (indicador.temIndicadores)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Selo(texto: '${formatarNumero(indicador.distancia!, casas: 0)} km rodados'),
                  _Selo(texto: '${formatarNumero(indicador.kmPorLitro!)} km/L'),
                  _Selo(texto: formatarReaisPorKm(indicador.custoPorKm!)),
                ],
              )
            else
              const _Selo(texto: 'Primeiro abastecimento: referência inicial'),
          ],
        ),
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  final String texto;

  const _Selo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Cores.azul.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Cores.azul,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
