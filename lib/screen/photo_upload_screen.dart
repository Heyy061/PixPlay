import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game/screen/genre_selection_screen.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  // Pick image from gallery
  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  // Take photo using camera
  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────
            // TOP BAR
            // ─────────────────────────────
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 21,
                      ),
                    ),
                  ),

                  const Text(
                    'Create a Game',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ─────────────────────────────
            // MAIN CONTENT
            // ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ─────────────────────────
                    // HEADING
                    // ─────────────────────────
                    const Text(
                      'Turn a photo into\na playable world.',
                      style: TextStyle(
                        fontSize: 31,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ─────────────────────────
                    // IMAGE UPLOAD AREA
                    // ─────────────────────────
                    GestureDetector(
                      onTap: _pickFromGallery,
                      child: Container(
                        width: double.infinity,
                        height: 390,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.2,
                          ),
                        ),
                        child: _selectedImage == null
                            ? const _EmptyUploadArea()
                            : _SelectedImage(
                                image: _selectedImage!,
                                onRemove: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─────────────────────────
                    // GALLERY + CAMERA
                    // ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.photo_library_outlined,
                            text: 'Gallery',
                            onPressed: _pickFromGallery,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _ActionButton(
                            icon: Icons.camera_alt_outlined,
                            text: 'Camera',
                            onPressed: _takePhoto,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─────────────────────────
                    // CONTINUE BUTTON
                    // ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed: _selectedImage == null
                            ? null
                            : () {
                                // Genre selection will be connected here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GenreSelectionScreen(
                                      image: _selectedImage!,
                                    ),
                                  ),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _selectedImage == null
                              ? Colors.white
                              : Colors.blue,
                          foregroundColor: _selectedImage == null
                              ? Colors.grey.shade400
                              : Colors.white,
                          side: BorderSide(
                            color: _selectedImage == null
                                ? Colors.grey.shade200
                                : Colors.blue,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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

// ─────────────────────────────────────
// EMPTY UPLOAD AREA
// ─────────────────────────────────────

class _EmptyUploadArea extends StatelessWidget {
  const _EmptyUploadArea();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 28,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Drop your photo here',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'or choose an image from your device',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// SELECTED IMAGE
// ─────────────────────────────────────

class _SelectedImage extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _SelectedImage({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.file(image, fit: BoxFit.cover),

          // Cross button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade200, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
