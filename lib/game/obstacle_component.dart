import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'jetpack_game.dart';

class ObstacleComponent extends SpriteComponent
    with HasGameReference<JetpackGame>, CollisionCallbacks {
  ObstacleComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(48, 20),
        anchor: Anchor.center,
        priority: 5,
      );

  final double speed = 150;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('others/missile.png');

    angle = 3.1416;
    add(
      RectangleHitbox.relative(
        Vector2(0.7, 0.7), // 50% maior que o sprite
        parentSize: size,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;

    if (position.x < -size.x) {
      removeFromParent();
    }
  }
}
