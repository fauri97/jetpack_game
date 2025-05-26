import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetpack_game/ui/main_menu.dart';
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
        'MainMenu': (context, _) => MainMenu(game: jetpackGame),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
