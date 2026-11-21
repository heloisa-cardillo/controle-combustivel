import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:controle_combustivel/features/combustivel/data/repositories/repositorio_combustivel.dart';
import 'package:controle_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:controle_combustivel/features/combustivel/models/veiculo.dart';
import 'package:controle_combustivel/features/combustivel/presentation/widgets/icone.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';
import 'package:controle_combustivel/features/combustivel/utils/formatar.dart';

class TelaAbastecimento extends StatefulWidget {
  final Veiculo veiculo;
  final List<Abastecimento> abastecimentos;

  const TelaAbastecimento({
    super.key,
    required this.veiculo,
    required this.abastecimentos,
  });

  @override
  State<TelaAbastecimento> createState() => _TelaAbastecimentoState();
}

class _TelaAbastecimentoState extends State<TelaAbastecimento> {
  final _formKey = GlobalKey<FormState>();
  final _repositorio = RepositorioCombustivel();
  final _controladorPreco = TextEditingController();
  final _controladorQuilometragem = TextEditingController();
  final _controladorLitros = TextEditingController();

  TipoCombustivel _combustivel = TipoCombustivel.gasolina;
  DateTime _data = DateTime.now();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _controladorPreco.addListener(_atualizarTotal);
    _controladorLitros.addListener(_atualizarTotal);
  }

  @override
  void dispose() {
    _controladorPreco.dispose();
    _controladorQuilometragem.dispose();
    _controladorLitros.dispose();
    super.dispose();
  }

  void _atualizarTotal() => setState(() {});

  double? get _total {
    final preco = lerNumero(_controladorPreco.text);
    final litros = lerNumero(_controladorLitros.text);
    if (preco == null || litros == null) return null;
    return preco * litros;
  }

  // Abastecimento registrado logo antes da data escolhida.
  Abastecimento? get _anterior {
    final antes = widget.abastecimentos.where((a) => !a.data.isAfter(_data)).toList();
    return antes.isEmpty ? null : antes.last;
  }

  // Abastecimento registrado logo depois da data escolhida.
  Abastecimento? get _posterior {
    final depois = widget.abastecimentos.where((a) => a.data.isAfter(_data)).toList();
    return depois.isEmpty ? null : depois.first;
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data == null || !mounted) return;
    setState(() {
      _data = DateTime(data.year, data.month, data.day, _data.hour, _data.minute);
    });
  }

  Future<void> _escolherHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_data),
    );
    if (hora == null || !mounted) return;
    setState(() {
      _data = DateTime(_data.year, _data.month, _data.day, hora.hour, hora.minute);
    });
  }

  String? _validarPreco(String? valor) {
    final preco = lerNumero(valor ?? '');
    if (preco == null) return 'Informe o preço por litro';
    if (preco <= 0 || preco > 50) return 'Preço inválido';
    return null;
  }

  String? _validarLitros(String? valor) {
    final litros = lerNumero(valor ?? '');
    if (litros == null) return 'Informe a quantidade de litros';
    if (litros <= 0 || litros > 500) return 'Quantidade inválida';
    return null;
  }

  String? _validarQuilometragem(String? valor) {
    final km = lerNumero(valor ?? '');
    if (km == null) return 'Informe a quilometragem';
    if (km < 0) return 'Quilometragem inválida';

    final anterior = _anterior;
    if (anterior != null && km <= anterior.quilometragem) {
      return 'Precisa ser maior que ${formatarQuilometragem(anterior.quilometragem)} (abastecimento anterior)';
    }

    final posterior = _posterior;
    if (posterior != null && km >= posterior.quilometragem) {
      return 'Precisa ser menor que ${formatarQuilometragem(posterior.quilometragem)} (abastecimento seguinte)';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    FocusScope.of(context).unfocus();

    if (_data.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data e o horário não podem estar no futuro.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      await _repositorio.salvarAbastecimento(
        Abastecimento(
          veiculoId: widget.veiculo.id!,
          combustivel: _combustivel,
          precoLitro: lerNumero(_controladorPreco.text)!,
          quilometragem: lerNumero(_controladorQuilometragem.text)!,
          litros: lerNumero(_controladorLitros.text)!,
          data: _data,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abastecimento registrado.')),
      );
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o abastecimento.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final anterior = _anterior;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo abastecimento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.veiculo.marca} ${widget.veiculo.modelo}',
                style: const TextStyle(color: Cores.cinza),
              ),
              const SizedBox(height: 16),
              const Text(
                'Combustível',
                style: TextStyle(fontWeight: FontWeight.w600, color: Cores.titulo),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TipoCombustivel>(
                showSelectedIcon: false,
                segments: TipoCombustivel.values
                    .map(
                      (tipo) => ButtonSegment(value: tipo, label: Text(tipo.nome)),
                    )
                    .toList(),
                selected: {_combustivel},
                onSelectionChanged: (selecao) =>
                    setState(() => _combustivel = selecao.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (estados) => estados.contains(WidgetState.selected)
                        ? Cores.azul
                        : Colors.white,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (estados) => estados.contains(WidgetState.selected)
                        ? Colors.white
                        : Cores.texto,
                  ),
                  side: const WidgetStatePropertyAll(BorderSide(color: Cores.borda)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _escolherData,
                      icon: const Icone('calendar', tamanho: 18),
                      label: Text(formatarData(_data)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _escolherHora,
                      icon: const Icone('clock', tamanho: 18),
                      label: Text(formatarHora(_data)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorPreco,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Preço por litro (R\$)',
                  hintText: 'Ex.: 5,89',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icone('wallet', tamanho: 20),
                  ),
                ),
                validator: _validarPreco,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _controladorLitros,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Litros abastecidos',
                  hintText: 'Ex.: 40,5',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icone('droplet', tamanho: 20),
                  ),
                ),
                validator: _validarLitros,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _controladorQuilometragem,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _salvar(),
                decoration: InputDecoration(
                  labelText: 'Quilometragem do veículo',
                  hintText: 'Ex.: 45230',
                  helperText: anterior == null
                      ? 'Primeiro abastecimento: será a referência inicial'
                      : 'Anterior: ${formatarQuilometragem(anterior.quilometragem)}',
                  helperMaxLines: 2,
                  errorMaxLines: 2,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icone('route', tamanho: 20),
                  ),
                ),
                validator: _validarQuilometragem,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Cores.borda),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Valor total',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Cores.titulo),
                    ),
                    const Spacer(),
                    Text(
                      total == null ? 'R\$ --' : formatarReais(total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Cores.azul,
                      ),
                    ),
                  ],
                ),
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
                    : const Text('Salvar abastecimento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
