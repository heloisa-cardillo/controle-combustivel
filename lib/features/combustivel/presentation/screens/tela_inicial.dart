import 'package:flutter/material.dart';

import 'package:controle_combustivel/features/combustivel/data/repositories/repositorio_combustivel.dart';
import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/models/indicador.dart';
import 'package:controle_combustivel/features/combustivel/models/veiculo.dart';
import 'package:controle_combustivel/features/combustivel/presentation/screens/tela_abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/presentation/screens/tela_cadastro_veiculo.dart';
import 'package:controle_combustivel/features/combustivel/presentation/screens/tela_dashboard.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/cartao_abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/cartao_veiculo.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/icone.dart';
import 'package:controle_combustivel/features/combustivel/utils/calcular_indicadores.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final _repositorio = RepositorioCombustivel();

  Veiculo? _veiculo;
  List<Abastecimento> _abastecimentos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final veiculo = await _repositorio.buscarVeiculo();
      final abastecimentos = veiculo == null
          ? <Abastecimento>[]
          : await _repositorio.listarAbastecimentos(veiculo.id!);
      if (!mounted) return;
      setState(() {
        _veiculo = veiculo;
        _abastecimentos = abastecimentos;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar os dados salvos.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirCadastroVeiculo() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TelaCadastroVeiculo()),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _abrirNovoAbastecimento() async {
    final veiculo = _veiculo;
    if (veiculo == null) return;

    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaAbastecimento(
          veiculo: veiculo,
          abastecimentos: _abastecimentos,
        ),
      ),
    );
    if (salvou == true) _carregar();
  }

  void _abrirDashboard() {
    final veiculo = _veiculo;
    if (veiculo == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaDashboard(
          veiculo: veiculo,
          abastecimentos: _abastecimentos,
        ),
      ),
    );
  }

  Future<void> _confirmarExclusaoVeiculo() async {
    final veiculo = _veiculo;
    if (veiculo == null) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Excluir veículo?'),
        content: Text(
          'O ${veiculo.modelo} e os ${_abastecimentos.length} abastecimento(s) registrados serão apagados. Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Cores.erro),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await _repositorio.excluirVeiculo(veiculo.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo e abastecimentos excluídos.')),
      );
      _carregar();
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o veículo.')),
      );
    }
  }

  Future<void> _confirmarExclusaoAbastecimento(Abastecimento abastecimento) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Excluir abastecimento?'),
        content: const Text('Os indicadores serão recalculados sem ele.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Cores.erro),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    await _repositorio.excluirAbastecimento(abastecimento.id!);
    if (!mounted) return;
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icons/logo.png', width: 30, height: 30),
            const SizedBox(width: 10),
            const Text('Combustível'),
          ],
        ),
        actions: [
          if (_veiculo != null)
            IconButton(
              tooltip: 'Dashboard',
              onPressed: _abrirDashboard,
              icon: const Icone('chart_line'),
            ),
        ],
      ),
      floatingActionButton: _veiculo == null
          ? null
          : Container(
              decoration: BoxDecoration(
                gradient: Cores.gradiente,
                borderRadius: BorderRadius.circular(16),
              ),
              child: FloatingActionButton.extended(
                onPressed: _abrirNovoAbastecimento,
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
                icon: const Icone('plus', branco: true, tamanho: 20),
                label: const Text(
                  'Abastecimento',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
      body: _montarCorpo(),
    );
  }

  Widget _montarCorpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return _Mensagem(
        icone: 'info',
        titulo: _erro!,
        textoBotao: 'Tentar de novo',
        aoPressionar: _carregar,
      );
    }

    final veiculo = _veiculo;
    if (veiculo == null) {
      return _Mensagem(
        icone: 'coelho',
        titulo: 'Nenhum veículo cadastrado',
        texto: 'Cadastre seu veículo para começar a registrar os abastecimentos.',
        textoBotao: 'Cadastrar veículo',
        aoPressionar: _abrirCadastroVeiculo,
      );
    }

    final indicadores = calcularIndicadores(_abastecimentos);
    final maisRecentesPrimeiro = indicadores.reversed.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        CartaoVeiculo(veiculo: veiculo, aoExcluir: _confirmarExclusaoVeiculo),
        const SizedBox(height: 20),
        Text(
          'Abastecimentos (${_abastecimentos.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Cores.titulo,
          ),
        ),
        const SizedBox(height: 10),
        if (_abastecimentos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icone('coelho', tamanho: 56),
                SizedBox(height: 10),
                Text(
                  'Nenhum abastecimento registrado ainda.',
                  style: TextStyle(color: Cores.cinza),
                ),
              ],
            ),
          )
        else
          ...maisRecentesPrimeiro.map(
            (Indicador indicador) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CartaoAbastecimento(
                indicador: indicador,
                aoExcluir: () =>
                    _confirmarExclusaoAbastecimento(indicador.abastecimento),
              ),
            ),
          ),
      ],
    );
  }
}

class _Mensagem extends StatelessWidget {
  final String icone;
  final String titulo;
  final String? texto;
  final String textoBotao;
  final VoidCallback aoPressionar;

  const _Mensagem({
    required this.icone,
    required this.titulo,
    this.texto,
    required this.textoBotao,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Cores.azul.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icone(icone, tamanho: 40),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Cores.titulo,
              ),
            ),
            if (texto != null) ...[
              const SizedBox(height: 6),
              Text(
                texto!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Cores.cinza),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(onPressed: aoPressionar, child: Text(textoBotao)),
          ],
        ),
      ),
    );
  }
}
