import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Theme(
        data: ThemeData(
          brightness: Brightness.light,
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(50),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 818/266,
                child: Container(  
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Color.fromRGBO(195, 0, 10, 1.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.only(
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: Column(
                  children: [
                    Text(
                      "Bem-vindo!",
                      style: TextStyle(
                        decorationColor: Color.fromRGBO(64, 64, 64, 1.0),
                        color: Color.fromRGBO(64, 64, 64, 1.0),
                        fontSize: 24,
                        fontFamily: "IstokWeb",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Complete seus dados para continuar",
                      style: TextStyle(
                        decorationColor: Color.fromRGBO(64, 64, 64, 1.0),
                        decoration: TextDecoration.underline,
                        color: Color.fromRGBO(64, 64, 64, 0.8),
                        fontSize: 12,
                        fontFamily: "IstokWeb",
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                spacing: 10.0,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(234, 234, 234, 1.0),
                      hint: Text(
                        "Nome Completo",
                        style: TextStyle(
                          color: Color.fromRGBO(64, 64, 64, 1.0),
                        ),
                      ),
                    ),
                    onChanged: (valor) {
                      setState(() {});
                    },
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(234, 234, 234, 1.0),
                      hint: Text(
                        "E-mail institucional",
                        style: TextStyle(
                          color: Color.fromRGBO(64, 64, 64, 1.0),
                        ),
                      ),
                    ),
                    onChanged: (valor) {
                      setState(() {});
                    },
                  ),
                  Text(nomeController.text),
                  Text(emailController.text),
                ],
              ),
            ],
          ),
        ),
      ), 
    );
  }
}
