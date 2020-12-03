import 'package:flutter/widgets.dart';

import '../Sprite.dart';
import '../constants.dart';
import 'GameObject.dart';

List<Sprite> dinoSprites = [
  Sprite()
    ..imagePath = "assets/images/dino/dino_1.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_2.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_3.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_4.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_5.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_6.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_crawl_1.png"
    ..imageWidth = 118
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_crawl_2.png"
    ..imageWidth = 118
    ..imageHeight = 94,
];

enum DinoState {
  jumping,
  running,
  crawl,
  dead,
}

class Dino extends GameObject {
  Sprite sprite;
  double dispY = 0;
  double velY = 0;
  DinoState state;

  Dino() {
    start();
  }

  @override
  Widget render() {
    return Image.asset(
      sprite.imagePath,
      gaplessPlayback: true,
    );
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        screenSize.width / 10,
        screenSize.height / 3 * 2 - sprite.imageHeight - dispY,
        sprite.imageWidth.toDouble(),
        sprite.imageHeight.toDouble());
  }

  @override
  void update(Duration lastTime, Duration elapsedTime) {
    if (state == DinoState.jumping) {
      sprite = dinoSprites[0];
    } else if (state == DinoState.running) {
      sprite = dinoSprites[(elapsedTime.inMilliseconds / 100).floor() % 2 + 2];
    } else if (state == DinoState.dead) {
      sprite = dinoSprites[4];
    } else if (state == DinoState.crawl) {
      sprite = dinoSprites[(elapsedTime.inMilliseconds / 100).floor() % 2 + 6];
    }

    double elapsedSeconds = ((elapsedTime - lastTime).inMilliseconds / 1000);

    dispY += velY * elapsedSeconds;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
      state = DinoState.running;
    } else {
      velY -= GRAVITY_PPSPS * elapsedSeconds;
    }
  }

  void start() {
    sprite = dinoSprites[0];
    state = DinoState.running;
  }

  void jump() {
    if (state != DinoState.jumping && state != DinoState.crawl) {
      state = DinoState.jumping;
      velY = 850;
    }
  }

  void crawl() {
    if (state != DinoState.crawl && state != DinoState.jumping) {
      state = DinoState.crawl;
      // velY = 850;
    }
  }

  void superJump() {
    state = DinoState.jumping;
    velY = 850;
  }

  void die() {
    sprite = dinoSprites[5];
    state = DinoState.dead;
  }
}
