import "package:flutter/material.dart";
import "treino/treino_pre_sessao.dart";

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const TreinoPreSessao();
              }
            ),
          );
        },
        child: Text("Novo treino"),
      ),
    );
  }
}
