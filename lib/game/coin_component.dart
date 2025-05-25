import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'jetpack_game.dart';

class CoinComponent extends SpriteComponent
    with HasGameReference<JetpackGame>, CollisionCallbacks {
  CoinComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(48),
          priority: 5,
          anchor: Anchor.center, // Centraliza para rotação suave
        );

  final double speed = 120;
  double time = 0;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('others/coin.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move a moeda para a esquerda
    position.x -= speed * dt;

    // Roda no próprio eixo (horizontal)
    time += dt;
    scale.x = cos(time * 3); // gira suavemente

    // Aplica flutuação vertical
    position.y += sin(time * 2) * 0.3;

    // Remove da tela se sair
    if (position.x < -size.x) {
      removeFromParent();
    }
  }
}
