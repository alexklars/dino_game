import 'dart:math';

import 'package:dino_game/GameState.dart';
import 'package:dino_game/Object/Dino.dart';
import 'package:dino_game/Object/Ptera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Object/Cactus.dart';
import 'Object/Cloud.dart';
import 'Object/GameObject.dart';
import 'Object/Ground.dart';
import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  GameState gameState = GameState.firstLoad;
  AnimationController worldController;
  Duration lastUpdateCall;
  double runDistance;
  double runVelocity;
  Dino dino = Dino();
  List<Cactus> cacti;
  List<Ptera> pteras;
  List<Ground> ground = [
    Ground(worldLocation: Offset(0, 0)),
    Ground(
        worldLocation:
            Offset(groundSprite.imageWidth / WORLD_TO_PIXEL_RATIO, 0))
  ];
  List<Cloud> clouds;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Color.fromARGB(255, 65, 65, 65),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light));

    worldController =
        AnimationController(vsync: this, duration: Duration(days: 99));
    worldController.addListener(_update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    List<Widget> children = [];
    if (gameState == GameState.playing || gameState == GameState.gameOver) {
      for (GameObject object in [
        ...ground,
        ...clouds,
        ...cacti,
        ...pteras,
        dino
      ]) {
        children.add(
          AnimatedBuilder(
              animation: worldController,
              builder: (context, child) => Positioned.fromRect(
                  rect: object.getRect(screenSize, runDistance),
                  child: object.render())),
        );
      }

      children.add(AnimatedBuilder(
          animation: worldController,
          builder: (context, child) => Positioned(
              top: screenSize.height / 3,
              right: 20,
              child: Text(
                runDistance.floor().toString(),
                style: GoogleFonts.vt323(
                  fontSize: 40,
                  color: Color.fromARGB(255, 65, 65, 65),
                ),
              ))));
    }

    if (gameState == GameState.gameOver) {
      children.add(Positioned(
          width: screenSize.width / 3,
          child: Image.asset("assets/images/game_over.png")));
      children.add(Positioned(
          top: screenSize.height / 2 + 20,
          width: screenSize.width / 10,
          child: Image.asset("assets/images/restart.png")));
    }

    if (gameState == GameState.firstLoad) {
      children.add(Positioned.fromRect(
          rect: dino.getRect(screenSize, 0), child: dino.render()));
      children.add(Positioned.fromRect(
          rect: ground[0].getRect(screenSize, 0), child: ground[0].render()));
    }

    Widget child = Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
    if (kIsWeb) {
      return Scaffold(
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (RawKeyEvent event) {
            if (event.runtimeType.toString() == 'RawKeyDownEvent') {
              if (event.isKeyPressed(LogicalKeyboardKey.space))
                _startOrJump();
              else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown))
                _crawl();
              else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp))
                _startOrJump();
            }
          },
          child: child,
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    } else {
      return Scaffold(
        body: GestureDetector(
          onTap: () => _startOrJump(),
          onTapDown: (d) => _crawl(),
          onPanUpdate: (details) {
            if (details.delta.dy > 0) {
              _crawl();
            } else
              _startOrJump();
          },
          child: child,
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
  }

  _startOrJump() {
    switch (gameState) {
      case GameState.playing:
        dino.jump();
        break;
      case GameState.firstLoad:
      case GameState.gameOver:
        _startGame();
        break;
    }
  }

  _crawl() {
    switch (gameState) {
      case GameState.playing:
        dino.crawl();
        break;
      case GameState.firstLoad:
      case GameState.gameOver:
        _startGame();
        break;
    }
  }

  _startGame() {
    setState(() {
      gameState = GameState.playing;
      runDistance = 0;
      runVelocity = START_VELOCITY;
      lastUpdateCall = Duration();
      dino = Dino();
      cacti = [
        Cactus(worldLocation: Offset(40, 0)),
        Cactus(worldLocation: Offset(80, 0))
      ];
      pteras = [
        Ptera(worldLocation: Offset(200, 10)),
        Ptera(worldLocation: Offset(300, 0))
      ];
      clouds = [
        Cloud(worldLocation: Offset(25, 20)),
        Cloud(worldLocation: Offset(50, 10)),
        Cloud(worldLocation: Offset(150, -10)),
      ];
      ground = [
        Ground(worldLocation: Offset(0, 0)),
        Ground(
            worldLocation:
                Offset(groundSprite.imageWidth / WORLD_TO_PIXEL_RATIO, 0))
      ];

      worldController.forward();
    });
  }

  void _die() {
    setState(() {
      gameState = GameState.gameOver;
      worldController.stop();
      worldController.reset();
      dino.die();
    });
  }

  void _update() {
    double elapsedSeconds =
        (worldController.lastElapsedDuration - lastUpdateCall).inMilliseconds /
            1000;
    runDistance = max(runDistance + runVelocity * elapsedSeconds, 0);

    if (runVelocity < MAX_VELOCITY)
      runVelocity += ACCELERATION * elapsedSeconds;

    dino.update(lastUpdateCall, worldController.lastElapsedDuration);
    lastUpdateCall = worldController.lastElapsedDuration;

    Size screenSize = MediaQuery.of(context).size;
    double screenDistance = screenSize.width / WORLD_TO_PIXEL_RATIO;
    Rect dinoRect = dino.getRect(screenSize, runDistance).deflate(15);
    for (Cactus cactus in cacti) {
      Rect cactusRect = cactus.getRect(screenSize, runDistance);
      if (dinoRect.overlaps(cactusRect.deflate(15))) {
        _die();
      }
      if (cactusRect.right < 0) {
        setState(() {
          cacti.remove(cactus);
          cacti.add(Cactus(
              worldLocation: Offset(
                  cacti.last.worldLocation.dx +
                      Random().nextInt(screenDistance.floor()) +
                      screenDistance,
                  0)));
        });
      }
    }

    for (Ptera ptera in pteras) {
      ptera.update(lastUpdateCall, worldController.lastElapsedDuration);
      Rect pteraRect = ptera.getRect(screenSize, runDistance);
      if (dinoRect.overlaps(pteraRect.deflate(15))) {
        _die();
      }
      if (pteraRect.right < 0) {
        setState(() {
          pteras.remove(ptera);
          pteras.add(Ptera(
              worldLocation: Offset(
                  pteras.last.worldLocation.dx +
                      Random().nextInt(screenDistance.floor()) +
                      screenDistance,
                  Random().nextInt(40) - 20.0)));
        });
      }
    }

    for (Ground groundlet in ground) {
      if (groundlet.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          ground.remove(groundlet);
          ground.add(Ground(
              worldLocation: Offset(
                  ground.last.worldLocation.dx +
                      groundSprite.imageWidth / WORLD_TO_PIXEL_RATIO,
                  0)));
        });
      }
    }

    for (Cloud cloud in clouds) {
      if (cloud.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          clouds.remove(cloud);

          clouds.add(Cloud(
              worldLocation: Offset(
                  clouds.last.worldLocation.dx +
                      (Random().nextInt(screenDistance.floor()) * 5 +
                          screenDistance),
                  Random().nextInt(40) - 20.0)));
        });
      }
    }
  }
}
