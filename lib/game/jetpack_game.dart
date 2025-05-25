import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'ceiling_component.dart';
import 'coin_component.dart';
import 'ground_component.dart';
import 'obstacle_component.dart';
import 'player_component.dart';

class JetpackGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late final ParallaxComponent parallax;
  late final PlayerComponent player;

  late TextComponent coinText;
  int coinsCollected = 0;
  bool isGameOver = false;

  final _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fundo paralaxe
    parallax = await loadParallaxComponent(
      [ParallaxImageData('background/layer1.png')],
      baseVelocity: Vector2(60, 0),
      velocityMultiplierDelta: Vector2(1.5, 0),
    );
    add(parallax);

    // HUD de moedas
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

    // Cria o player apenas uma vez
    player = PlayerComponent();
    add(player);

    setup(); // Adiciona os demais elementos
  }

  void setup() {
    // Reset do HUD
    coinsCollected = 0;
    coinText.text = 'Moedas: 0';

    // Reseta o estado do player
    player.position = Vector2(100, size.y / 2);
    player.speedY = 0;

    // Chão
    add(
      GroundComponent(
        position: Vector2(0, size.y - 70),
        size: Vector2(size.x, 64),
      ),
    );

    // Teto
    add(CeilingComponent(position: Vector2(0, 0), size: Vector2(size.x, 10)));

    // Timer de moedas
    add(TimerComponent(period: 2, repeat: true, onTick: spawnCoin));

    // Timer de obstáculos
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
    pauseEngine();
    overlays.add('GameOver');
  }

  void restart() {
    overlays.remove('GameOver');
    isGameOver = false;

    // Remove tudo, menos fundo, HUD e player
    children
        .where((c) => c != parallax && c != coinText && c != player)
        .toList()
        .forEach((c) => c.removeFromParent());

    // Reseta o jogo
    setup();

    // Retoma o jogo
    resumeEngine();
  }

  void handleTapDown() {
    if (!isGameOver) {
      player.speedY = player.jetForce;
      print('Tap manual disparado');
    }
  }
}
