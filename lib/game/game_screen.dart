import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/game_spec.dart';
import 'generated_game.dart';

class GameScreen extends StatefulWidget {
  final GameSpec gameSpec;

  const GameScreen({
    super.key,
    required this.gameSpec,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GeneratedGame game;

  @override
  void initState() {
    super.initState();
    _createGame();
  }

  void _createGame() {
    game = GeneratedGame(
      gameSpec: widget.gameSpec,
      onGameWon: () {
        setState(() {});
      },
      onGameOver: () {
        setState(() {});
      },
    );
  }

  void _restartGame() {
    setState(() {
      _createGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
  children: [
    GameWidget(game: game),

    Positioned(
      top: 40,
      left: 16,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 30,
        ),
      ),
    ),

    // Win overlay
    if (game.gameWon)
      _buildResultOverlay(
        title: 'YOU WIN!',
        subtitle: 'Congratulations 🎉',
        isWin: true,
      ),

    // Game over overlay
    if (game.gameOver)
      _buildResultOverlay(
        title: 'GAME OVER',
        subtitle: 'Better luck next time!',
        isWin: false,
      ),
  ],
)
    );
  }

  Widget _buildResultOverlay({
    required String title,
    required String subtitle,
    required bool isWin,
  }) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isWin ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                'Score: ${game.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: _restartGame,
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}