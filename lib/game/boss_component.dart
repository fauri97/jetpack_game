import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:jetpack_game/game/chair_component.dart';
import 'jetpack_game.dart';

class BossComponent extends SpriteComponent
    with HasGameReference<JetpackGame>, CollisionCallbacks {
  late Sprite frame1;
  late Sprite frame2;
  late Sprite frame3;

  late Timer attackTimer;
  late Timer frame3Timer;
  late Timer fadeTimer;

  bool hasAttacked = false;
  bool isFadingOut = false;
  double speed = 100;

  BossComponent() : super(size: Vector2(96, 96), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    frame1 = await Sprite.load('boss/boss0.png');
    frame2 = await Sprite.load('boss/boss1.png');
    frame3 = await Sprite.load('boss/boss2.png');
    sprite = frame2;

    scale.x = -1;
    position = Vector2(game.size.x + size.x, game.size.y / 2);

    // Troca para frame3, lança cadeira
    attackTimer = Timer(
      0.4,
      onTick: () {
        sprite = frame3;
        game.add(ChairComponent(position: position.clone()));
        FlameAudio.play('chair_throw.mp3');
        frame3Timer.start(); // inicia o timer que volta para frame2
      },
    );

    // Volta para frame2 e começa fade
    frame3Timer = Timer(
      0.4,
      onTick: () {
        sprite = frame2;
        isFadingOut = true;
      },
    );

    // Fade final (não é um timer, é só flag + lógica no update)
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isFadingOut) {
      opacity -= dt / 1.5; // fadeDuration = 1.5
      if (opacity <= 0) {
        game.bossIsActive = false;
        removeFromParent();
      }
      return;
    }

    if (!hasAttacked) {
      position.x -= speed * dt;

      if (position.x <= game.size.x - 120) {
        hasAttacked = true;
        sprite = frame1;
        attackTimer.start();
      }
    } else {
      attackTimer.update(dt);
      frame3Timer.update(dt);
    }
  }
}
