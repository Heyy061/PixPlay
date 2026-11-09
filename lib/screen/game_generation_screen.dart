import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game/game/game_screen.dart';
import 'package:game/services/groq_service.dart';

import '../models/game_spec.dart';

class GameGenerationScreen extends StatefulWidget {
  final File image;
  final String genre;
  final String mood;
  final String difficulty;
  final String? title;
  final String? description;

  const GameGenerationScreen({
    super.key,
    required this.image,
    required this.genre,
    required this.mood,
    required this.difficulty,
    this.title,
    this.description,
  });

  @override
  State<GameGenerationScreen> createState() => _GameGenerationScreenState();
}

class _GameGenerationScreenState extends State<GameGenerationScreen> {
  final GroqGameService _groqGameService = GroqGameService();

  GameSpec? _gameSpec;

  bool _isGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _generateGame();
  }

  Future<void> _generateGame() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final gameSpec = await _groqGameService.generateGame(
        image: widget.image,
        genre: widget.genre,
        mood: widget.mood,
        difficulty: widget.difficulty,
        title: widget.title,
        description: widget.description,
      );
      print('Game title: ${gameSpec.title}');
      print('Genre: ${gameSpec.genre}');
      print('Mood: ${gameSpec.mood}');
      print('Difficulty: ${gameSpec.difficulty}');

      print('World: ${gameSpec.world.theme}');
      print('Objective: ${gameSpec.objective.description}');

      for (final object in gameSpec.objects) {
        print(
          'Object: ${object.name}, '
          'Type: ${object.type}, '
          'Count: ${object.count}',
        );
      }
      if (!mounted) return;

      setState(() {
        _gameSpec = gameSpec;
        _isGenerating = false;
      });

      debugPrint('Game generated successfully!');
      debugPrint('Title: ${gameSpec.title}');
      debugPrint('Genre: ${gameSpec.genre}');
      debugPrint('Objective: ${gameSpec.objective.description}');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGenerating = false;
        _error = e.toString();
      });

      debugPrint('Game generation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Creating your game',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                widget.image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Creating your game.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Turning your ${widget.genre.toLowerCase()} idea '
              'into a playable world.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 35),

            if (_isGenerating)
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 18),
                  Text(
                    'Generating game specification...',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

            if (_gameSpec != null)
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 52,
                      color: Colors.black,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Game created!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _gameSpec!.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(gameSpec: _gameSpec!),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Play Game',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_error != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                      color: Colors.black,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 20),

                    OutlinedButton(
                      onPressed: _generateGame,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
