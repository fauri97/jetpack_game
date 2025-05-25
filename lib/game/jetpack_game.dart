import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart'; // necessário para TapDetector
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'ceiling_component.dart';
import 'coin_component.dart';
import 'ground_component.dart';
import 'obstacle_component.dart';
import 'player_component.dart';

class JetpackGame extends FlameGame with HasCollisionDetection, TapDetector {
  late final ParallaxComponent parallax;
  late final PlayerComponent player;
  late TextComponent coinText;

  int coinsCollected = 0;
  bool isGameOver = false;
  final _random = Random();

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play('bg.mp3', volume: 0.5);

    parallax = await loadParallaxComponent(
      [ParallaxImageData('background/layer1.png')],
      baseVelocity: Vector2(60, 0),
      velocityMultiplierDelta: Vector2(1.5, 0),
    );
    add(parallax);

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

    player = PlayerComponent();
    add(player);

    setup();
  }

  void setup() {
    coinsCollected = 0;
    coinText.text = 'Moedas: 0';

    player.position = Vector2(100, size.y / 2);
    player.speedY = 0;

    add(
      GroundComponent(
        position: Vector2(0, size.y - 70),
        size: Vector2(size.x, 64),
      ),
    );
    add(CeilingComponent(position: Vector2(0, 0), size: Vector2(size.x, 10)));

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

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    FlameAudio.play('gameover.mp3');
    FlameAudio.bgm.stop();
    pauseEngine();
    overlays.add('GameOver');
  }

  void restart() {
    overlays.remove('GameOver');
    isGameOver = false;

    children
        .where((c) => c != parallax && c != coinText && c != player)
        .toList()
        .forEach((c) => c.removeFromParent());

    setup();
    FlameAudio.bgm.play('bg.mp3', volume: 0.5);

    resumeEngine();
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!isGameOver) {
      player.speedY = player.jetForce;
    }
  }
}
