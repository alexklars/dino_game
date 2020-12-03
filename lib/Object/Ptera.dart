import 'dart:ui';

import 'package:dino_game/constants.dart';
import 'package:flutter/widgets.dart';

import '../sprite.dart';
import 'GameObject.dart';

List<Sprite> pteraSprites = [
  Sprite()
    ..imagePath = "assets/images/ptera/ptera_1.png"
    ..imageHeight = 80
    ..imageWidth = 92,
  Sprite()
    ..imagePath = "assets/images/ptera/ptera_2.png"
    ..imageHeight = 80
    ..imageWidth = 92,
];

class Ptera extends GameObject {
  final Offset worldLocation;
  Sprite sprite = pteraSprites[0];

  Ptera({this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        (worldLocation.dx - runDistance) * WORLD_TO_PIXEL_RATIO,
        screenSize.height / 2 - sprite.imageHeight - worldLocation.dy,
        sprite.imageWidth.toDouble(),
        sprite.imageHeight.toDouble());
  }

  @override
  Widget render() {
    return Image.asset(
      sprite.imagePath,
      gaplessPlayback: true,
    );
  }

  @override
  void update(Duration lastUpdate, Duration elapsedTime) {
    sprite = pteraSprites[(elapsedTime.inMilliseconds / 200).floor() % 2];
  }
}
