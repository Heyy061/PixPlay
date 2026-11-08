import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game/screen/game_customization_screen.dart';

class GenreSelectionScreen extends StatefulWidget {
  final File image;

  const GenreSelectionScreen({super.key, required this.image});

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  String? _selectedGenre;

  final List<_Genre> _genres = const [
    _Genre(name: 'Adventure', icon: Icons.explore_outlined),
    _Genre(name: 'RPG', icon: Icons.shield_outlined),
    _Genre(name: 'Horror', icon: Icons.nightlight_outlined),
    _Genre(name: 'Racing', icon: Icons.directions_car_outlined),
    _Genre(name: 'Puzzle', icon: Icons.extension_outlined),
    _Genre(name: 'Shooter', icon: Icons.gps_fixed_outlined),
    _Genre(name: 'Platformer', icon: Icons.sports_esports_outlined),
    _Genre(name: 'Strategy', icon: Icons.psychology_outlined),
  ];

  void _continue() {
    if (_selectedGenre == null) return;

    // Next screen will be connected here.
    debugPrint('Genre: $_selectedGenre');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 21,
                      ),
                    ),
                  ),
                  const Text(
                    'Choose a Genre',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What kind of game\nshould we make?',
                      style: TextStyle(
                        fontSize: 31,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Choose a genre and PixPlay will shape your photo into that type of game.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Photo preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: Image.file(widget.image, fit: BoxFit.cover),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Select a genre',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _genres.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.65,
                          ),
                      itemBuilder: (context, index) {
                        final genre = _genres[index];
                        final isSelected = _selectedGenre == genre.name;

                        return _GenreCard(
                          genre: genre,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedGenre = genre.name;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Surprise me
                    _SurpriseCard(
                      isSelected: _selectedGenre == 'Surprise Me',
                      onTap: () {
                        setState(() {
                          _selectedGenre = 'Surprise Me';
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _selectedGenre == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GameCustomizationScreen(
                                          image: widget.image,
                                          genre: _selectedGenre!,
                                        ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          _selectedGenre == null
                              ? 'Select a Genre'
                              : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final _Genre genre;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreCard({
    required this.genre,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(216, 0, 0, 0)
                : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              genre.icon,
              size: 23,
              color: isSelected
                  ? Colors.white
                  : const Color.fromARGB(198, 35, 34, 34),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                genre.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 19,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}

class _SurpriseCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _SurpriseCard({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(229, 28, 27, 27)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(216, 17, 17, 17)
                : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Surprise Me',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            Text(
              'Let PixPlay decide',
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.grey.shade300 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Genre {
  final String name;
  final IconData icon;

  const _Genre({required this.name, required this.icon});
}
