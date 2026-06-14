import 'package:flutter/material.dart';
import '../notifiers.dart';
import '../screens/tela_inicial.dart';
import 'paginas/tela_perfil.dart';
import 'widgets/navbar_widget.dart';

List<Widget> paginas = [TelaInicial(), TelaPerfil()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nutri Esportiva"),
        actions: [
          IconButton(
            onPressed: () => modoEscuroSelecionadoNotifier.value = !modoEscuroSelecionadoNotifier.value,
            icon: ValueListenableBuilder(
              valueListenable: modoEscuroSelecionadoNotifier,
              builder: (context, modoEscuroSelecionado, child) {
                return (modoEscuroSelecionado
                  ? Icon(Icons.light_mode)
                  : Icon(Icons.dark_mode)
                );
              },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: paginaSelecionadaNotifier,
        builder: (context, paginaSelecionada, child) {
          return paginas[paginaSelecionada];
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
