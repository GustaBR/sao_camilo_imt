import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  TextEditingController usuarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Theme(
        data: ThemeData(
          brightness: Brightness.light,
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(20.0),
          child: Column(
            children: [
              Image.asset('assets/logo.png'),
              Material(
                child: TextField(
                  controller: usuarioController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (valor) {
                    setState(() {});
                  },
                ),
              ),
              Center(child: Text(usuarioController.text)),
            ],
          ),
        ),
      ), 
    );
  }
}
