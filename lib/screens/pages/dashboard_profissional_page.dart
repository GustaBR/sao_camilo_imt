// pages/dashboard_profissional_page.dart
import 'package:flutter/material.dart';
import '../models/sessao_treino.dart';
// No topo do seu dashboard_page.dart
import '../services/atleta_data_manager.dart';
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
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
      case 'instrutor':
        return 'Visão do Instrutor';
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
      case 'instrutor':
        return Colors.blue;
      case 'nutricionista':
        return Colors.green;
      default:
        return const Color(0xFFB30000);
    }
  }

  Widget _buildDashboard() {
    switch (tipoProfissional) {
      case 'medico':
        return _buildMedicoDashboard();
      case 'instrutor':
        return _buildInstrutorDashboard();
      case 'nutricionista':
        return _buildNutricionistaDashboard();
      default:
        return const Center(child: Text('Tipo profissional inválido'));
    }
  }

  // ==================== DASHBOARD MÉDICO ====================
  Widget _buildMedicoDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Acompanhamento Médico",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("${sessoes.length} sessões registradas"),
          const SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Text("Alertas Clínicos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  ...sessoes.where((s) => s.teveSintomasGastro || s.escalaBorg >= 15).map((sessao) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📅 ${sessao.data.substring(0, 10)} - ${sessao.modalidade}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (sessao.teveSintomasGastro) const Text("⚠️ Sintomas gastrointestinais"),
                          if (sessao.escalaBorg >= 15) Text("⚠️ Esforço muito intenso (Borg ${sessao.escalaBorg})"),
                          if (sessao.teveFadiga) Text("⚠️ Fadiga reportada: ${sessao.fadigaDescricao}"),
                          const Divider(),
                        ],
                      ),
                    );
                  }),
                  if (sessoes.where((s) => s.teveSintomasGastro || s.escalaBorg >= 15).isEmpty)
                    const Text("Nenhum alerta médico nas últimas sessões.", style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DASHBOARD INSTRUTOR ====================
  Widget _buildInstrutorDashboard() {
    SessaoTreino? ultima = sessoes.isNotEmpty ? sessoes.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Desempenho do Atleta",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          if (ultima != null) ...[
            _buildMetricCard("Última sessão", ultima.modalidade, Icons.directions_run, Colors.blue),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard("Duração real", _formatDuration(ultima.duracaoRealSegundos), Icons.timer, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard("Intensidade (Borg)", ultima.escalaBorg.toString(), Icons.speed, Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard("Perda de massa", "${ultima.percentualPerdaMassa.toStringAsFixed(1)}%", Icons.monitor_weight, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard("Taxa sudorese", "${ultima.taxaSudorese.toStringAsFixed(1)} L/h", Icons.water_drop, Colors.blue)),
              ],
            ),
          ],

          const SizedBox(height: 24),
          const Text("Histórico de sessões", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessoes.length,
            itemBuilder: (context, index) {
              final s = sessoes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.blue),
                  title: Text("${s.modalidade} - ${s.data.substring(0, 10)}"),
                  subtitle: Text("Duração: ${_formatDuration(s.duracaoRealSegundos)} | Borg: ${s.escalaBorg}"),
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
          const Text(
            "Análise Nutricional",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  Text("Média de ingestão: ${mediaFluidos.toStringAsFixed(0)} mL",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Total de fluidos: $totalFluidos mL"),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: mediaFluidos / 1000,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(mediaFluidos >= 700 ? "✅ Hidratação adequada" : "⚠️ Ingestão abaixo do recomendado"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text("Detalhamento por sessão", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessoes.length,
            itemBuilder: (context, index) {
              final s = sessoes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s.fluidosIngeridosMl >= 700 ? Colors.green : Colors.orange,
                    child: Text("${s.fluidosIngeridosMl ~/ 100}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text("${s.modalidade} - ${s.data.substring(0, 10)}"),
                  subtitle: Text("Ingestão: ${s.fluidosIngeridosMl} mL | ${s.nivelHidratacao}"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String titulo, String valor, IconData icone, Color cor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icone, color: cor),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
            Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int segundos) {
    int minutos = segundos ~/ 60;
    if (minutos < 60) return "$minutos min";
    int horas = minutos ~/ 60;
    minutos = minutos % 60;
    return "$horas h ${minutos} min";
  }
}