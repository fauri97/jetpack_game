import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'jetpack_game.dart';
import 'player_component.dart';

class ChairComponent extends SpriteComponent
    with HasGameReference<JetpackGame>, CollisionCallbacks {
  ChairComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(48, 48),
        anchor: Anchor.center,
        priority: 5,
      );

  final double speed = 200;
  final double rotationSpeed = 5;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('boss/chair.png');
    add(CircleHitbox.relative(0.4, parentSize: size, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= speed * dt;

    angle += rotationSpeed * dt;

    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerComponent) {
      game.gameOver();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
