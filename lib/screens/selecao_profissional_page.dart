// lib/screens/pages/selecao_profissional_page.dart
import 'package:flutter/material.dart';
import 'login_profissional_page.dart';

class SelecaoProfissionalPage extends StatelessWidget {
  const SelecaoProfissionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFB30000),
              const Color(0xFFB30000).withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const Column(
                  children: [
                    Icon(Icons.fitness_center, size: 80, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'NUTRIESPORTIVA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'SÃO CAMILO',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Acessar como:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB30000),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        _buildOptionCard(
                          context: context,
                          title: 'ATLETA',
                          subtitle: 'Registrar treinos e acompanhar seu desempenho',
                          icon: Icons.person,
                          color: const Color(0xFFB30000),
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildOptionCard(
                          context: context,
                          title: 'MÉDICO',
                          subtitle: 'Acompanhar alertas clínicos e sintomas',
                          icon: Icons.medical_services,
                          color: const Color(0xFFB30000),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginProfissionalPage(tipo: 'medico'),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildOptionCard(
                          context: context,
                          title: 'INSTRUTOR',
                          subtitle: 'Acompanhar desempenho e evolução',
                          icon: Icons.fitness_center,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginProfissionalPage(tipo: 'instrutor'),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildOptionCard(
                          context: context,
                          title: 'NUTRICIONISTA',
                          subtitle: 'Acompanhar hidratação e nutrição',
                          icon: Icons.restaurant,
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginProfissionalPage(tipo: 'nutricionista'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: color),
            ],
          ),
        ),
      ),
    );
  }
}