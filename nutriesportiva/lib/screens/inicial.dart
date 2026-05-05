import 'package:flutter/material.dart';
import 'dart:async';

class TelaLanding extends StatefulWidget {
  const TelaLanding({super.key});

  @override
  State<TelaLanding> createState() => _TelaLandingState();
}

class _TelaLandingState extends State<TelaLanding> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;
  Timer? _timer;

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
        _paginaAtual = 0;
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
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSlider(context),
            Container(
              height: 500,
              width: double.infinity,
              color: const Color(0xFFDCDCDC),
              child: const Center(),
            )
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Padding(
        padding: EdgeInsets.only(left: isDesktop ? 40.0 : 10.0),
        child: Row(
          children: [
            Image.asset('assets/images/logo.png', height: isDesktop ? 40 : 30),
            const SizedBox(width: 15),  
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isDesktop ? 40.0 : 10.0, top: 10, bottom: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB30000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 15),
            ),
            onPressed: () {},
            child: Text("Acessar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 14 : 12)),
          ),
        )
      ],
    );
  }

 Widget _buildHeroSlider(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      height: isDesktop ? 650 : 600,
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
              return _buildConteudoSlide(_slides[index], isDesktop);
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

  Widget _buildConteudoSlide(Map<String, String> slide, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.only(
        left: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 20.0,
        right: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 20.0,
        top: 40.0, 
        bottom: 0, 
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: _buildTextAndButton(slide, isDesktop),
                ),
                Expanded(
                  // MUDANÇA AQUI: Em vez de Center, usamos Align para colar a imagem no chão
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      slide["imagem"]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextAndButton(slide, isDesktop),
                ),
                const SizedBox(height: 20),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      slide["imagem"]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextAndButton(Map<String, String> slide, bool isDesktop) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          slide["titulo"]!,
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 54 : 32,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFB30000),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 30,
              vertical: isDesktop ? 20 : 15,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {},
          child: Text(
            slide["botao"]!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
        )
      ],
    );
  }
}