import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/game_spec.dart';
import 'generated_game.dart';

class GameScreen extends StatelessWidget {
  final GameSpec gameSpec;

  const GameScreen({
    super.key,
    required this.gameSpec,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: GeneratedGame(
          gameSpec: gameSpec,
        ),
      ),
    );
  }
}