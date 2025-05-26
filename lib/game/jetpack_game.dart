import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:jetpack_game/game/boss_component.dart';
import 'package:jetpack_game/persistence/database_service.dart';
import 'dart:math';

import 'ceiling_component.dart';
import 'coin_component.dart';
import 'ground_component.dart';
import 'obstacle_component.dart';
import 'player_component.dart';

class JetpackGame extends FlameGame with HasCollisionDetection, TapDetector {
  late final ParallaxComponent parallax;
  late PlayerComponent player;
  late TextComponent coinText;

  bool bossIsActive = false;

  int coinsCollected = 0;
  int highscore = 0;
  bool isGameOver = false;
  final _random = Random();

  @override
  bool get debugMode => false;

  void scheduleBossAppearance() {
    final delay = Duration(seconds: 10 + Random().nextInt(28));

    Future.delayed(delay, () {
      spawnBoss(); // ✅ só aparece se bossIsActive == false
      scheduleBossAppearance(); // agendar próxima tentativa
    });
  }

  void spawnBoss() {
    if (bossIsActive) return; // evita duplicatas

    bossIsActive = true;
    add(BossComponent());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    pauseEngine();

    FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play('bg.mp3', volume: 0.5);

    highscore = await DatabaseService.getHighscore();

    // Fundo parallax
    parallax = await loadParallaxComponent(
      [ParallaxImageData('background/layer1.png')],
      baseVelocity: Vector2(60, 0),
      velocityMultiplierDelta: Vector2(1.5, 0),
    );
    add(parallax);

    // HUD
    coinText = TextComponent(
      text: 'Moedas: 0',
      position: Vector2(200, 10),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
    add(coinText);
  }

  void startGame() {
    isGameOver = false;
    overlays.remove('MainMenu');
    resetGame();
    resumeEngine();
  }

  void resetGame() {
    // Remove tudo exceto o fundo e o texto do HUD
    children
        .where((c) => c != parallax && c != coinText)
        .toList()
        .forEach((c) => c.removeFromParent());

    // Recria o player
    player = PlayerComponent();
    add(player);

    // Reset HUD
    coinsCollected = 0;
    coinText.text = 'Moedas: 0';

    // Solo e teto
    add(
      GroundComponent(
        position: Vector2(0, size.y - 70),
        size: Vector2(size.x, 64),
      ),
    );
    add(CeilingComponent(position: Vector2(0, 0), size: Vector2(size.x, 10)));

    bossIsActive = false;

    //Spawna o boss
    scheduleBossAppearance();

    // Timers
    add(TimerComponent(period: 2, repeat: true, onTick: spawnCoin));
    add(
      TimerComponent(
        period: 3,
        repeat: true,
        onTick: () {
          final y = 80 + _random.nextDouble() * (size.y - 160);
          final x = size.x + 100;
          add(ObstacleComponent(position: Vector2(x, y)));
        },
      ),
    );

    FlameAudio.bgm.play('bg.mp3', volume: 0.5);
  }

  void spawnCoin() {
    final minY = 80.0;
    final maxY = size.y - 150;
    final coinY = minY + _random.nextDouble() * (maxY - minY);
    final coinX = size.x + 50;

    add(CoinComponent(position: Vector2(coinX, coinY)));
  }

  void incrementCoins() {
    coinsCollected++;
    coinText.text = 'Moedas: $coinsCollected';
  }

  void gameOver() async {
    if (isGameOver) return;
    isGameOver = true;

    await FlameAudio.bgm.stop();

    FlameAudio.play('gameover.mp3');

    Future.delayed(const Duration(seconds: 4), () {
      FlameAudio.bgm.play('bg.mp3', volume: 0.5);
    });

    await DatabaseService.addScore(coinsCollected);
    overlays.add('MainMenu');
    pauseEngine();
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!isGameOver) {
      player.speedY = player.jetForce;
    }
  }
}
