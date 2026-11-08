import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class GameGenerationScreen extends StatefulWidget {
  final File image;
  final String genre;

  const GameGenerationScreen({
    super.key,
    required this.image,
    required this.genre,
  });

  @override
  State<GameGenerationScreen> createState() =>
      _GameGenerationScreenState();
}

class _GameGenerationScreenState
    extends State<GameGenerationScreen> {
  int _currentStep = 0;

  final List<String> _steps = [
    'Analyzing your photo',
    'Building the world',
    'Creating gameplay',
    'Adding your genre',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _startGeneration();
  }

  void _startGeneration() {
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
        if (!mounted) return;

        if (_currentStep < _steps.length - 1) {
          setState(() {
            _currentStep++;
          });
        } else {
          timer.cancel();

          // AI generation will be connected here later.
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 25),

              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 230,
                  child: Image.file(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Creating your game.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 31,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Turning your photo into a ${widget.genre.toLowerCase()} world.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 22),

              // Progress steps
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: List.generate(
                    _steps.length,
                    (index) {
                      return _ProgressStep(
                        title: _steps[index],
                        status: index < _currentStep
                            ? StepStatus.completed
                            : index == _currentStep
                                ? StepStatus.active
                                : StepStatus.waiting,
                        isLast: index == _steps.length - 1,
                      );
                    },
                  ),
                ),
              ),

              const Spacer(),

              if (_currentStep == _steps.length - 1)
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      // Generated game screen will be connected here.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
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

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

enum StepStatus {
  completed,
  active,
  waiting,
}

class _ProgressStep extends StatelessWidget {
  final String title;
  final StepStatus status;
  final bool isLast;

  const _ProgressStep({
    required this.title,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = status == StepStatus.completed;
    final bool active = status == StepStatus.active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: completed || active
                    ? Colors.black
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed || active
                      ? Colors.black
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: completed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 19,
                    )
                  : active
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : null,
            ),

            if (!isLast)
              Container(
                width: 1.5,
                height: 38,
                color: completed
                    ? Colors.black
                    : Colors.grey.shade200,
              ),
          ],
        ),

        const SizedBox(width: 15),

        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  active || completed
                      ? FontWeight.w600
                      : FontWeight.w500,
              color: active || completed
                  ? Colors.black
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}