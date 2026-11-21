import 'package:flutter/material.dart';

import 'package:controle_combustivel/features/combustivel/presentation/widgets/icone.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';

// Abre uma lista com campo de busca e devolve a opção escolhida.
Future<String?> mostrarListaSelecao(
  BuildContext context, {
  required String titulo,
  required List<String> opcoes,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ListaSelecao(titulo: titulo, opcoes: opcoes),
  );
}

class _ListaSelecao extends StatefulWidget {
  final String titulo;
  final List<String> opcoes;

  const _ListaSelecao({required this.titulo, required this.opcoes});

  @override
  State<_ListaSelecao> createState() => _ListaSelecaoState();
}

class _ListaSelecaoState extends State<_ListaSelecao> {
  final _controladorBusca = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = widget.opcoes
        .where((opcao) => opcao.toLowerCase().contains(_filtro.toLowerCase()))
        .toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Cores.titulo,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icone('x'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorBusca,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Buscar',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: Icone('search', tamanho: 20),
                ),
              ),
              onChanged: (texto) => setState(() => _filtro = texto),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtradas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada encontrado.',
                        style: TextStyle(color: Cores.cinza),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtradas.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Cores.borda),
                      itemBuilder: (context, indice) {
                        final opcao = filtradas[indice];
                        return ListTile(
                          title: Text(opcao),
                          onTap: () => Navigator.pop(context, opcao),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
