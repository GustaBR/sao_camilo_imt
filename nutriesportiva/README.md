esse é um manual para ajudar vcs a se localizarem nesse projeto!

## Pastas Importantes
todo o nosso código Dart e a interface do aplicativo ficam dentro da pasta **`lib/`** (Library). O resto o Flutter gera sozinho

a pasta `lib/` está dividida assim:
*   **`lib/main.dart`**: É a porta de entrada do aplicativo. Ele apenas inicia o app e chama a primeira tela. Não coloque muita lógica aqui!
*   **`lib/screens/`**: Aqui ficam as telas inteiras do app (ex: `tela_protocolo.dart`, `tela_resultados.dart`). Cada arquivo é uma "página" diferente.
*   **`lib/widgets/`**: Pedaços visuais que repetimos em várias telas (ex: `botao_vermelho_padrao.dart`, `card_aviso_bexiga.dart`). 
*   **`lib/models/`**: Os moldes dos nossos dados (ex: uma classe `Sessao.dart` que guarda o peso, urina e tempo).
*   **`lib/utils/`**: O "Cérebro" do app. Aqui ficam as fórmulas matemáticas puras, a lógica de taxa de sudorese e a API do Clima.

### Painel de controle
*   **`pubspec.yaml`**: Quer instalar uma biblioteca nova? Adicionar a fonte da São Camilo ou colocar imagens? É tudo registrado neste arquivo. (Cuidado com a indentação, ele é sensível a espaços!).

## AVISO
* NÃO MEXA EM NADA ALÉM DISSO! O RESTO É GERADO AUTOMATICAMENTE PELO FLUTTER.