import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/jetpack_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final jetpackGame = JetpackGame();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    GameWidget(
      game: jetpackGame,
      overlayBuilderMap: {
        'GameOver': (context, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Game Over',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      jetpackGame.restart();
                    },
                    child: Text('Reiniciar'),
                  ),
                ],
              ),
            ),
      },
    ),
  );
}
