import 'package:flutter/material.dart';
import 'package:jetpack_game/game/jetpack_game.dart';
import 'package:jetpack_game/persistence/database_service.dart';

class MainMenu extends StatefulWidget {
  final JetpackGame game;

  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<int> topScores = [];

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  Future<void> loadScores() async {
    final scores = await DatabaseService.getTopScores();
    setState(() {
      topScores = scores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem de fundo
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/main_menu_background.png',
            fit: BoxFit.fill,
          ),
        ),
        // Conteúdo sobreposto (JOGAR à esquerda, RANKING à direita)
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Botão JOGAR à esquerda
                ElevatedButton(
                  onPressed: () {
                    widget.game.startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    backgroundColor: const Color.fromARGB(255, 7, 5, 105),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "JOGAR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                // Ranking à direita
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Top 5 Pontuações:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...topScores.map(
                      (score) => Text(
                        "$score pontos",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
