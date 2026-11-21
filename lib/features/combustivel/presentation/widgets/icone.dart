import 'package:flutter/material.dart';

// Ícones Lucide em PNG que ficam em assets/icons/.
class Icone extends StatelessWidget {
  final String nome;
  final double tamanho;
  final bool branco;

  const Icone(this.nome, {super.key, this.tamanho = 22, this.branco = false});

  @override
  Widget build(BuildContext context) {
    final arquivo = branco ? '${nome}_branco' : nome;
    return Image.asset(
      'assets/icons/$arquivo.png',
      width: tamanho,
      height: tamanho,
      filterQuality: FilterQuality.medium,
    );
  }
}
