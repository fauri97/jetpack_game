import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:jetpack_game/game/ceiling_component.dart';
import 'package:jetpack_game/game/ground_component.dart';
import 'package:jetpack_game/game/obstacle_component.dart';
import 'jetpack_game.dart';
import 'coin_component.dart';

class PlayerComponent extends SpriteAnimationComponent
    with HasGameReference<JetpackGame>, CollisionCallbacks {
  PlayerComponent() : super(size: Vector2(96, 96));

  double speedY = 0;
  final double gravity = 500;
  final double jetForce = -300;
  bool isOnGround = false;

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('player/player.png');

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(image.width / 3, image.height.toDouble()),
      ),
    );

    anchor = Anchor.center;
    position = Vector2(100, game.size.y / 2);
    size = Vector2(64, 64);

    add(
      RectangleHitbox.relative(
        Vector2(1, 1),
        parentSize: size,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Aplica gravidade se não estiver no chão
    if (!isOnGround) {
      speedY += gravity * dt;
    }

    position.y += speedY * dt;

    // Evita atravessar o chão se não houver colisão
    final bottomLimit = game.size.y - size.y / 2;
    if (position.y > bottomLimit) {
      position.y = bottomLimit;
      speedY = 0;
      isOnGround = true;
    }

    game.children.whereType<ObstacleComponent>().forEach((obstacle) {
    if (obstacle.toRect().overlaps(toRect())) {
      game.gameOver();
    }
  });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundComponent) {
      isOnGround = true;
      speedY = 0;
    }

    if (other is CeilingComponent) {
      speedY = 0;
    }

    if (other is CoinComponent) {
      other.removeFromParent();
      FlameAudio.play('coin.mp3');
      game.incrementCoins();
    }

    if (other is ObstacleComponent) {
      FlameAudio.play('gameover.mp3', volume: 2);
      game.gameOver();
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is GroundComponent) {
      isOnGround = false;
    }

    super.onCollisionEnd(other);
  }
}
