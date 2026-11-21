import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:controle_combustivel/features/combustivel/data/repositories/repositorio_combustivel.dart';
import 'package:controle_combustivel/features/combustivel/models/marca.dart';
import 'package:controle_combustivel/features/combustivel/models/veiculo.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/icone.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/lista_selecao.dart';
import 'package:controle_combustivel/features/combustivel/services/servico_fipe.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';
import 'package:controle_combustivel/features/combustivel/utils/formatar.dart';

class TelaCadastroVeiculo extends StatefulWidget {
  const TelaCadastroVeiculo({super.key});

  @override
  State<TelaCadastroVeiculo> createState() => _TelaCadastroVeiculoState();
}

class _TelaCadastroVeiculoState extends State<TelaCadastroVeiculo> {
  final _formKey = GlobalKey<FormState>();
  final _servico = ServicoFipe();
  final _repositorio = RepositorioCombustivel();
  final _controladorAno = TextEditingController();
  final _controladorCilindrada = TextEditingController();

  List<Marca> _marcas = [];
  List<String> _modelos = [];
  Marca? _marcaEscolhida;
  String? _modeloEscolhido;

  bool _carregandoMarcas = false;
  bool _carregandoModelos = false;
  bool _salvando = false;
  String? _erroMarcas;
  String? _erroModelos;
  bool _tentouSalvar = false;

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
  }

  @override
  void dispose() {
    _controladorAno.dispose();
    _controladorCilindrada.dispose();
    super.dispose();
  }

  Future<void> _carregarMarcas() async {
    if (_carregandoMarcas) return;
    setState(() {
      _carregandoMarcas = true;
      _erroMarcas = null;
    });

    try {
      final marcas = await _servico.buscarMarcas();
      if (!mounted) return;
      setState(() {
        _marcas = marcas;
        if (marcas.isEmpty) _erroMarcas = 'Nenhuma marca encontrada.';
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erroMarcas = erro.toString());
    } finally {
      if (mounted) setState(() => _carregandoMarcas = false);
    }
  }

  Future<void> _carregarModelos(Marca marca) async {
    setState(() {
      _carregandoModelos = true;
      _erroModelos = null;
      _modelos = [];
      _modeloEscolhido = null;
    });

    try {
      final modelos = await _servico.buscarModelos(marca.codigo);
      if (!mounted || _marcaEscolhida != marca) return;
      setState(() {
        _modelos = modelos;
        if (modelos.isEmpty) _erroModelos = 'Nenhum modelo encontrado para essa marca.';
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erroModelos = erro.toString());
    } finally {
      if (mounted) setState(() => _carregandoModelos = false);
    }
  }

  Future<void> _escolherMarca() async {
    final nome = await mostrarListaSelecao(
      context,
      titulo: 'Marca',
      opcoes: _marcas.map((marca) => marca.nome).toList(),
    );
    if (nome == null || !mounted) return;

    final marca = _marcas.firstWhere((m) => m.nome == nome);
    if (marca == _marcaEscolhida) return;
    setState(() => _marcaEscolhida = marca);
    _carregarModelos(marca);
  }

  Future<void> _escolherModelo() async {
    final modelo = await mostrarListaSelecao(
      context,
      titulo: 'Modelo',
      opcoes: _modelos,
    );
    if (modelo == null || !mounted) return;
    setState(() => _modeloEscolhido = modelo);
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    FocusScope.of(context).unfocus();
    setState(() => _tentouSalvar = true);

    final formularioValido = _formKey.currentState!.validate();
    if (!formularioValido || _marcaEscolhida == null || _modeloEscolhido == null) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await _repositorio.salvarVeiculo(
        Veiculo(
          marca: _marcaEscolhida!.nome,
          codigoMarca: _marcaEscolhida!.codigo,
          modelo: _modeloEscolhido!,
          ano: int.parse(_controladorAno.text.trim()),
          cilindrada: lerNumero(_controladorCilindrada.text)!,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o veículo.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _validarAno(String? valor) {
    final ano = int.tryParse((valor ?? '').trim());
    final limite = DateTime.now().year + 1;
    if (ano == null) return 'Informe o ano';
    if (ano < 1950 || ano > limite) return 'Ano entre 1950 e $limite';
    return null;
  }

  String? _validarCilindrada(String? valor) {
    final cilindrada = lerNumero(valor ?? '');
    if (cilindrada == null) return 'Informe a cilindrada (ex.: 1.0)';
    if (cilindrada < 0.5 || cilindrada > 8.0) return 'Use litros, entre 0,5 e 8,0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar veículo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Marca e modelo vêm da tabela FIPE (BrasilAPI).',
                style: TextStyle(color: Cores.cinza),
              ),
              const SizedBox(height: 16),
              _CampoSelecao(
                rotulo: 'Marca',
                valor: _marcaEscolhida?.nome,
                carregando: _carregandoMarcas,
                erro: _erroMarcas ??
                    (_tentouSalvar && _marcaEscolhida == null ? 'Escolha a marca' : null),
                aoTocar: _marcas.isEmpty ? null : _escolherMarca,
                aoTentarDeNovo: _erroMarcas != null ? _carregarMarcas : null,
              ),
              const SizedBox(height: 14),
              _CampoSelecao(
                rotulo: 'Modelo',
                valor: _modeloEscolhido,
                dica: _marcaEscolhida == null ? 'Escolha a marca primeiro' : null,
                carregando: _carregandoModelos,
                erro: _erroModelos ??
                    (_tentouSalvar && _marcaEscolhida != null && _modeloEscolhido == null
                        ? 'Escolha o modelo'
                        : null),
                aoTocar: _modelos.isEmpty ? null : _escolherModelo,
                aoTentarDeNovo: _erroModelos != null && _marcaEscolhida != null
                    ? () => _carregarModelos(_marcaEscolhida!)
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _controladorAno,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  hintText: 'Ex.: 2020',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icone('calendar', tamanho: 20),
                  ),
                ),
                validator: _validarAno,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _controladorCilindrada,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _salvar(),
                decoration: const InputDecoration(
                  labelText: 'Cilindrada do motor (litros)',
                  hintText: 'Ex.: 1.0',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icone('gauge', tamanho: 20),
                  ),
                ),
                validator: _validarCilindrada,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Salvar veículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoSelecao extends StatelessWidget {
  final String rotulo;
  final String? valor;
  final String? dica;
  final bool carregando;
  final String? erro;
  final VoidCallback? aoTocar;
  final VoidCallback? aoTentarDeNovo;

  const _CampoSelecao({
    required this.rotulo,
    required this.valor,
    this.dica,
    required this.carregando,
    this.erro,
    this.aoTocar,
    this.aoTentarDeNovo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: carregando ? null : aoTocar,
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            isEmpty: valor == null,
            decoration: InputDecoration(
              labelText: rotulo,
              hintText: dica,
              errorText: erro,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icone(rotulo == 'Marca' ? 'car' : 'search', tamanho: 20),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icone('chevron_down', tamanho: 20),
              ),
            ),
            child: valor == null
                ? null
                : Text(
                    valor!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: Cores.titulo),
                  ),
          ),
        ),
        if (aoTentarDeNovo != null)
          TextButton(onPressed: aoTentarDeNovo, child: const Text('Tentar de novo')),
      ],
    );
  }
}
