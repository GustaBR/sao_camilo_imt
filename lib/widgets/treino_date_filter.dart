import 'package:flutter/material.dart';

import '../models/sessao_treino.dart';

List<SessaoTreino> filtrarTreinosPorPeriodo(
  List<SessaoTreino> treinos,
  DateTimeRange? periodo,
) {
  if (periodo == null) return treinos;

  final inicio = _somenteData(periodo.start);
  final fim = _somenteData(periodo.end);

  return treinos.where((treino) {
    final dataTreino = _somenteData(treino.data);
    return !dataTreino.isBefore(inicio) && !dataTreino.isAfter(fim);
  }).toList();
}

DateTime _somenteData(DateTime data) {
  return DateTime(data.year, data.month, data.day);
}

String _formatarData(DateTime data) {
  return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
}

class TreinoDateFilter extends StatelessWidget {
  final DateTimeRange? periodo;
  final ValueChanged<DateTimeRange?> onChanged;
  final Color cor;
  final int total;
  final int filtrados;

  const TreinoDateFilter({
    super.key,
    required this.periodo,
    required this.onChanged,
    required this.cor,
    required this.total,
    required this.filtrados,
  });

  @override
  Widget build(BuildContext context) {
    final temFiltro = periodo != null;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: cor),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Filtro por data',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (temFiltro)
                  TextButton(
                    onPressed: () => onChanged(null),
                    child: const Text('Limpar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarInicio(context),
                    icon: const Icon(Icons.event),
                    label: Text(periodo == null ? 'Inicio' : _formatarData(periodo!.start)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarFim(context),
                    icon: const Icon(Icons.event_available),
                    label: Text(periodo == null ? 'Fim' : _formatarData(periodo!.end)),
                  ),
                ),
              ],
            ),
            if (temFiltro) ...[
              const SizedBox(height: 8),
              Text(
                'Mostrando $filtrados de $total treinos',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarInicio(BuildContext context) async {
    final selecionada = await _abrirSeletor(
      context,
      periodo?.start ?? periodo?.end ?? DateTime.now(),
    );
    if (selecionada == null) return;

    var inicio = _somenteData(selecionada);
    var fim = _somenteData(periodo?.end ?? selecionada);
    if (inicio.isAfter(fim)) {
      fim = inicio;
    }

    onChanged(DateTimeRange(start: inicio, end: fim));
  }

  Future<void> _selecionarFim(BuildContext context) async {
    final selecionada = await _abrirSeletor(
      context,
      periodo?.end ?? periodo?.start ?? DateTime.now(),
    );
    if (selecionada == null) return;

    var inicio = _somenteData(periodo?.start ?? selecionada);
    var fim = _somenteData(selecionada);
    if (fim.isBefore(inicio)) {
      inicio = fim;
    }

    onChanged(DateTimeRange(start: inicio, end: fim));
  }

  Future<DateTime?> _abrirSeletor(BuildContext context, DateTime initialDate) {
    final hoje = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(hoje.year + 2, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: cor),
          ),
          child: child!,
        );
      },
    );
  }
}
