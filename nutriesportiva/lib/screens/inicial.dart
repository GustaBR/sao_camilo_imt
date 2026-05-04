import 'package:flutter/material.dart';
import 'dart:async'; // <-- Importante para o slide passar sozinho!

class TelaLanding extends StatefulWidget {
  const TelaLanding({super.key});

  @override
  State<TelaLanding> createState() => _TelaLandingState();
}

class _TelaLandingState extends State<TelaLanding> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;
  Timer? _timer; // Nosso cronômetro

  final List<Map<String, String>> _slides = [
    {
      "titulo": "NutriEsportiva\nSão Camilo",
      "botao": "ACESSE AQUI",
      "imagem": "assets/images/correndo.png" 
    },
    {
      "titulo": "Alta Performance\ne Hidratação",
      "botao": "SAIBA MAIS",
      "imagem": "assets/images/bebendo.png" 
    },
    {
      "titulo": "Acompanhamento\nProfissional",
      "botao": "CONHEÇA",
      "imagem": "assets/images/analise.png" 
    }
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_paginaAtual < _slides.length - 1) {
        _paginaAtual++;
      } else {
        _paginaAtual = 0; // Volta pro começo
      }
      
      
      _pageController.animateToPage(
        _paginaAtual,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSlider(),
            
            Container(
              height: 500,
              width: double.infinity,
              color: const Color(0xFFDCDCDC),
              child: const Center(
              ),
            )
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40), 
            const SizedBox(width: 10),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 50.0, top: 10, bottom: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB30000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 30),
            ),
            onPressed: () {},
            child: const Text("Acessar", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _buildHeroSlider() {
    return Container(
      height: 500,
      width: double.infinity,
      color: const Color(0xFFB30000),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _paginaAtual = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _buildConteudoSlide(_slides[index]);
            },
          ),
          
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
            
                return MouseRegion(
                  cursor: SystemMouseCursors.click, 
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: _paginaAtual == index ? 12 : 8,
                      height: _paginaAtual == index ? 12 : 8,
                      decoration: BoxDecoration(
                        color: _paginaAtual == index ? Colors.white : Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConteudoSlide(Map<String, String> slide) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide["titulo"]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFB30000),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {},
                  child: Text(
                    slide["botao"]!, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                slide["imagem"]!,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }
}