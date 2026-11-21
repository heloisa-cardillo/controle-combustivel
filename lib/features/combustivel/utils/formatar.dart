String formatarReais(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

String formatarReaisPorKm(double valor) {
  return 'R\$ ${valor.toStringAsFixed(3).replaceAll('.', ',')}/km';
}

String formatarNumero(double valor, {int casas = 2}) {
  return valor.toStringAsFixed(casas).replaceAll('.', ',');
}

String formatarQuilometragem(double valor) {
  final inteiro = valor.round().toString();
  final partes = <String>[];
  for (var i = inteiro.length; i > 0; i -= 3) {
    final inicio = i - 3 < 0 ? 0 : i - 3;
    partes.insert(0, inteiro.substring(inicio, i));
  }
  return '${partes.join('.')} km';
}

String formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

String formatarHora(DateTime data) {
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

String formatarDataHora(DateTime data) {
  return '${formatarData(data)} às ${formatarHora(data)}';
}

// Aceita vírgula ou ponto como separador decimal.
double? lerNumero(String texto) {
  final limpo = texto.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (limpo.isEmpty) return null;
  return double.tryParse(limpo);
}
