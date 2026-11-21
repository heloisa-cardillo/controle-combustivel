import 'package:flutter/material.dart';

import 'package:controle_combustivel/features/combustivel/models/veiculo.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/icone.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';
import 'package:controle_combustivel/features/combustivel/utils/formatar.dart';

class CartaoVeiculo extends StatelessWidget {
  final Veiculo veiculo;
  final VoidCallback? aoExcluir;

  const CartaoVeiculo({super.key, required this.veiculo, this.aoExcluir});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: Cores.gradiente,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icone('car', branco: true, tamanho: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  veiculo.marca,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  veiculo.modelo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${veiculo.ano}  •  Motor ${formatarNumero(veiculo.cilindrada, casas: 1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Excluir veículo',
            onPressed: aoExcluir,
            icon: const Icone('trash_2', branco: true),
          ),
        ],
      ),
    );
  }
}
