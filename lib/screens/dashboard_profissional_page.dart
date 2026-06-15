// lib/screens/pages/dashboard_profissional_page.dart
import 'package:flutter/material.dart';
import '../../models/sessao_treino.dart';

class DashboardProfissionalPage extends StatelessWidget {
  final String tipoProfissional;
  final String codigoAtleta;
  final String nomeAtleta;
  final List<SessaoTreino> sessoes;

  const DashboardProfissionalPage({
    super.key,
    required this.tipoProfissional,
    required this.codigoAtleta,
    required this.nomeAtleta,
    required this.sessoes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$nomeAtleta - ${_getTitulo()}'),
        backgroundColor: _getCor(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close), // Troquei pra close pra indicar que fecha o dashboard
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _buildDashboard(),
    );
  }

  String _getTitulo() {
    switch (tipoProfissional) {
      case 'medico':
        return 'Visão Médica';
      case 'treinador': // <-- CORRIGIDO AQUI
        return 'Desempenho';
      case 'nutricionista':
        return 'Análise Nutricional';
      default:
        return 'Dashboard';
    }
  }

  Color _getCor() {
    switch (tipoProfissional) {
      case 'medico':
        return const Color(0xFFB30000);
      case 'treinador': // <-- CORRIGIDO AQUI
        return Colors.blue;
      case 'nutricionista':
        return Colors.green;
      default:
        return const Color(0xFFB30000);
    }
  }

  Widget _buildDashboard() {
    if (sessoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum treino registrado ainda',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'O atleta $nomeAtleta ainda não finalizou nenhum treino.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    switch (tipoProfissional) {
      case 'medico':
        return _buildMedicoDashboard();
      case 'treinador': // <-- CORRIGIDO AQUI
        return _buildTreinadorDashboard();
      case 'nutricionista':
        return _buildNutricionistaDashboard();
      default:
        return const Center(child: Text('Tipo profissional inválido'));
    }
  }

  // ==================== DASHBOARD MÉDICO ====================
  Widget _buildMedicoDashboard() {
    final alertas = sessoes.where((s) => 
      s.teveSintomasGastro || 
      s.escalaBorg >= 15 || 
      s.teveFadiga ||
      s.percentualPerdaMassa > 2
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            titulo: 'Total de sessões',
            valor: sessoes.length.toString(),
            icone: Icons.calendar_today,
            cor: const Color(0xFFB30000),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Alertas Clínicos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getCor()),
          ),
          const SizedBox(height: 8),
          
          if (alertas.isEmpty)
            Card(
              color: Colors.green[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Nenhum alerta clínico nas últimas sessões'),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alertas.length,
              itemBuilder: (context, index) {
                final s = alertas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ ${s.dataFormatada} - ${s.modalidade}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (s.teveSintomasGastro) 
                          const Text('• Sintomas gastrointestinais'),
                        if (s.escalaBorg >= 15) 
                          Text('• Esforço muito intenso (Borg ${s.escalaBorg})'),
                        if (s.teveFadiga) 
                          Text('• Fadiga: ${s.fadigaDescricao}'),
                        if (s.percentualPerdaMassa > 2)
                          Text('• Perda de massa >2% (${s.percentualPerdaMassa.toStringAsFixed(1)}%)'),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 16),
          Text(
            'Histórico Completo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getCor()),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessoes.length,
            itemBuilder: (context, index) {
              final s = sessoes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: Icon(Icons.medical_information, color: _getCor()),
                  title: Text('${s.dataFormatada} - ${s.modalidade}'),
                  subtitle: Text('Borg: ${s.escalaBorg} | Perda: ${s.percentualPerdaMassa.toStringAsFixed(1)}%'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Massa pré', '${s.massaCorporalPreKg} kg'),
                          _buildDetailRow('Massa pós', '${s.massaCorporalPosKg} kg'),
                          _buildDetailRow('Perda de massa', '${s.percentualPerdaMassa.toStringAsFixed(1)}%'),
                          _buildDetailRow('Escala de Borg', s.escalaBorg.toString()),
                          _buildDetailRow('Sintomas gastro', s.teveSintomasGastro ? 'Sim' : 'Não'),
                          if (s.teveSintomasGastro)
                            _buildDetailRow('Descrição gastro', s.sintomasGastroDescricao ?? ''),
                          _buildDetailRow('Fadiga', s.teveFadiga ? 'Sim' : 'Não'),
                          if (s.teveFadiga) _buildDetailRow('Descrição fadiga', s.fadigaDescricao ?? ''),
                          _buildDetailRow('Roupas encharcadas', s.roupasEncharcadas ? 'Sim' : 'Não'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== DASHBOARD TREINADOR ====================
  Widget _buildTreinadorDashboard() { // <-- CORRIGIDO NOME DO MÉTODO
    SessaoTreino? ultima = sessoes.isNotEmpty ? sessoes.first : null;
    
    double mediaDuracao = sessoes.fold(0, (sum, s) => sum + s.duracaoRealSegundos) / sessoes.length / 60;
    double mediaBorg = sessoes.fold(0, (sum, s) => sum + s.escalaBorg) / sessoes.length;
    double mediaPerda = sessoes.fold(0.0, (sum, s) => sum + s.percentualPerdaMassa) / sessoes.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Atleta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getCor()),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildMetricCard('Sessões', sessoes.length.toString(), Icons.history, Colors.blue)),
              Expanded(child: _buildMetricCard('Média Duração', '${mediaDuracao.toStringAsFixed(0)} min', Icons.timer, Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Média Borg', mediaBorg.toStringAsFixed(1), Icons.speed, Colors.blue)),
              Expanded(child: _buildMetricCard('Média Perda', '${mediaPerda.toStringAsFixed(1)}%', Icons.monitor_weight, Colors.blue)),
            ],
          ),
          
          const SizedBox(height: 24),
          Text(
            'Última Sessão',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getCor()),
          ),
          const SizedBox(height: 8),
          
          if (ultima != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Data', ultima.dataFormatada),
                    _buildDetailRow('Modalidade', ultima.modalidade),
                    _buildDetailRow('Duração', '${ultima.duracaoRealSegundos ~/ 60} min'),
                    _buildDetailRow('Borg', ultima.escalaBorg.toString()),
                    _buildDetailRow('Perda de massa', '${ultima.percentualPerdaMassa.toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          Text(
            'Histórico de Sessões',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getCor()),
          ),
          const SizedBox(height: 8),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessoes.length,
            itemBuilder: (context, index) {
              final s = sessoes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.blue),
                  title: Text('${s.dataFormatada} - ${s.modalidade}'),
                  subtitle: Text('Duração: ${s.duracaoRealSegundos ~/ 60} min | Borg: ${s.escalaBorg}'),
                  trailing: Text('${s.percentualPerdaMassa.toStringAsFixed(1)}%'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== DASHBOARD NUTRICIONISTA ====================
  Widget _buildNutricionistaDashboard() {
    int totalFluidos = sessoes.fold(0, (sum, s) => sum + s.fluidosIngeridosMl);
    double mediaFluidos = sessoes.isEmpty ? 0 : totalFluidos / sessoes.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análise Nutricional',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getCor()),
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.local_drink, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    'Média de ingestão: ${mediaFluidos.toStringAsFixed(0)} mL',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Total de fluidos: $totalFluidos mL'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: mediaFluidos / 1000,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mediaFluidos >= 700 ? '✅ Hidratação adequada' : '⚠️ Ingestão abaixo do recomendado',
                    style: TextStyle(
                      color: mediaFluidos >= 700 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Detalhamento por sessão',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getCor()),
          ),
          const SizedBox(height: 8),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessoes.length,
            itemBuilder: (context, index) {
              final s = sessoes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s.fluidosIngeridosMl >= 700 ? Colors.green : Colors.orange,
                    child: Text(
                      '${s.fluidosIngeridosMl ~/ 100}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text('${s.dataFormatada} - ${s.modalidade}'),
                  subtitle: Text('Ingestão: ${s.fluidosIngeridosMl} mL | ${s.nivelHidratacao}'),
                  trailing: Text('${s.taxaSudorese.toStringAsFixed(1)} L/h'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES ====================
  Widget _buildInfoCard({
    required String titulo, 
    required String valor, 
    required IconData icone, 
    required Color cor
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icone, size: 32, color: cor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.black54)),
                Text(valor, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String titulo, String valor, IconData icone, Color cor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 28),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
            Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}