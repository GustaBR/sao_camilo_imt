import 'package:flutter/material.dart';
import 'package:sao_camilo_imt/data/notifiers.dart';
import 'package:sao_camilo_imt/ui/paginas/tela_login.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: modoEscuroSelecionadoNotifier,
      builder: (context, modoEscuroSelecionado, child) {
        ScreenScaler.init(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: TelaLogin(),
          theme: ThemeData(
            brightness: modoEscuroSelecionado
              ? Brightness.dark
              : Brightness.light
          ),
        );
      },
    );
  }
}