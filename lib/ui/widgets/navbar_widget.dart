import 'package:flutter/material.dart';
import '../../notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: paginaSelecionadaNotifier,
      builder: (context, paginaSelecionada, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Início"),
            NavigationDestination(icon: Icon(Icons.person), label: "Perfil"),
          ],
          onDestinationSelected: (valor) {
            paginaSelecionadaNotifier.value = valor;
          },
          selectedIndex: paginaSelecionada,
        );
      },
    );
  }
}
