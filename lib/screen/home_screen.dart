import 'package:game/screen/photo_upload_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _GameData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _GameData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static const Color primary = Color(0xFF5B4B8A);
  static const Color background = Color(0xFFF7F7F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF202020);
  static const Color secondaryText = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1100 : double.infinity,
                ),
                child: Column(
                  children: [
                    _buildTopBar(isDesktop),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 20,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(isDesktop),

                            const SizedBox(height: 28),

                            _buildCreateCard(isDesktop),

                            const SizedBox(height: 36),

                            _buildRecentGamesHeader(),

                            const SizedBox(height: 16),

                            _buildRecentGames(isDesktop),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),

                    if (!isDesktop) _buildBottomNavigation(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TOP BAR
  // ----------------------------------------------------------

  Widget _buildTopBar(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 20,
        vertical: 14,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          const Text(
            'imagica',
            style: TextStyle(
              color: textColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const Spacer(),

          if (isDesktop) ...[
            _topBarButton(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: true,
            ),
            _topBarButton(
              icon: Icons.sports_esports_outlined,
              label: 'My Games',
            ),
            _topBarButton(icon: Icons.settings_outlined, label: 'Settings'),
          ] else
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined, color: textColor),
            ),
        ],
      ),
    );
  }

  Widget _topBarButton({
    required IconData icon,
    required String label,
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18, color: selected ? primary : secondaryText),
        label: Text(
          label,
          style: TextStyle(
            color: selected ? primary : secondaryText,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // WELCOME
  // ----------------------------------------------------------

  Widget _buildWelcomeSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create something\nplayable.',
          style: TextStyle(
            color: textColor,
            fontSize: isDesktop ? 42 : 34,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Turn a photo into a small pixel-art game with Imagica.',
          style: TextStyle(color: secondaryText, fontSize: 15, height: 1.45),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // CREATE GAME CARD
  // ----------------------------------------------------------

  Widget _buildCreateCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _buildCreateContent()),
                const SizedBox(width: 40),
                _buildPreviewIllustration(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCreateContent(),
                const SizedBox(height: 25),
                _buildPreviewIllustration(),
              ],
            ),
    );
  }

  Widget _buildCreateContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0ECF8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.photo_camera_outlined,
            color: primary,
            size: 24,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Start with a photo',
          style: TextStyle(
            color: textColor,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Choose a photo from your gallery or take a new one. '
          'Imagica will turn the scene into a playable mini-game.',
          style: TextStyle(color: secondaryText, fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 22),

        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PhotoUploadScreen()),
              );
            },
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
            label: const Text(
              'Create Game',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // PREVIEW ILLUSTRATION
  // ----------------------------------------------------------

  Widget _buildPreviewIllustration() {
    return Container(
      width: 280,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          // Main illustration
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CustomPaint(painter: _ImagicaPreviewPainter()),
            ),
          ),

          // Top label
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 11,
                    color: Color(0xFF5B4B8A),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'PHOTO → GAME',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // RECENT GAMES
  // ----------------------------------------------------------

  Widget _buildRecentGamesHeader() {
    return Row(
      children: [
        const Text(
          'Your games',
          style: TextStyle(
            color: textColor,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: () {},
          child: const Text(
            'See all',
            style: TextStyle(color: primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentGames(bool isDesktop) {
    final games = [
      _GameData(
        title: 'Mystic Valley',
        subtitle: 'Adventure',
        icon: Icons.landscape_outlined,
      ),
      _GameData(
        title: 'Lost Temple',
        subtitle: 'Explorer',
        icon: Icons.account_balance_outlined,
      ),
      _GameData(
        title: 'Quiet Forest',
        subtitle: 'Adventure',
        icon: Icons.park_outlined,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: games.map((game) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _gameCard(game),
            ),
          );
        }).toList(),
      );
    }

    return SizedBox(
      height: 185,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return SizedBox(width: 210, child: _gameCard(games[index]));
        },
      ),
    );
  }

  Widget _gameCard(_GameData game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GAME PREVIEW
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDCEEFF), Color(0xFFEDE7F6)],
                    ),
                  ),
                ),

                // Decorative landscape
                Positioned(
                  left: -15,
                  bottom: -18,
                  child: Container(
                    width: 150,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8DBB82),
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
                ),

                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Container(
                    width: 140,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6FA66A),
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
                ),

                // Sun
                Positioned(
                  top: 18,
                  right: 22,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD978),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Game icon
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(game.icon, size: 28, color: primary),
                  ),
                ),

                // Adventure label
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      game.subtitle.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // GAME INFORMATION
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 13),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Created with Imagica',
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // OPEN BUTTON
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ----------------------------------------------------------
  // BOTTOM NAVIGATION
  // ----------------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomItem(icon: Icons.home_rounded, label: 'Home', index: 0),
          _bottomItem(
            icon: Icons.add_circle_outline_rounded,
            label: 'Create',
            index: 1,
          ),
          _bottomItem(
            icon: Icons.sports_esports_outlined,
            label: 'Games',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? primary : secondaryText, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? primary : secondaryText,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GAME PREVIEW PAINTER
// ============================================================

class _ImagicaPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ----------------------------------------------------------
    // BACKGROUND
    // ----------------------------------------------------------

    final backgroundPaint = Paint()..color = const Color(0xFFE7EBF2);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // ----------------------------------------------------------
    // LEFT PHOTO CARD
    // ----------------------------------------------------------

    final photoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 55, 82, 105),
      const Radius.circular(12),
    );

    final photoShadow = Paint()..color = Colors.black.withValues(alpha: 0.10);

    canvas.drawRRect(photoRect.shift(const Offset(0, 4)), photoShadow);

    final photoPaint = Paint()..color = Colors.white;

    canvas.drawRRect(photoRect, photoPaint);

    // Photo itself
    final photoScene = RRect.fromRectAndRadius(
      Rect.fromLTWH(25, 62, 68, 70),
      const Radius.circular(7),
    );

    final skyPaint = Paint()..color = const Color(0xFFAED0E8);

    canvas.drawRRect(photoScene, skyPaint);

    // Mountain
    final mountainPaint = Paint()..color = const Color(0xFF849C9A);

    final mountain = Path()
      ..moveTo(25, 115)
      ..lineTo(47, 87)
      ..lineTo(62, 105)
      ..lineTo(76, 92)
      ..lineTo(93, 116)
      ..close();

    canvas.drawPath(mountain, mountainPaint);

    // Ground
    final grassPaint = Paint()..color = const Color(0xFF7D9C68);

    canvas.drawRect(const Rect.fromLTWH(25, 115, 68, 17), grassPaint);

    // Sun
    final sunPaint = Paint()..color = const Color(0xFFF1C76B);

    canvas.drawCircle(const Offset(80, 76), 7, sunPaint);

    // Small photo frame icon
    final framePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(47, 137, 24, 14),
        const Radius.circular(3),
      ),
      framePaint,
    );

    // ----------------------------------------------------------
    // TRANSFORMATION ARROW
    // ----------------------------------------------------------

    final arrowPaint = Paint()
      ..color = const Color(0xFF5B4B8A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(108, 106), const Offset(143, 106), arrowPaint);

    final arrowHead = Path()
      ..moveTo(136, 99)
      ..lineTo(145, 106)
      ..lineTo(136, 113);

    canvas.drawPath(arrowHead, arrowPaint);

    // Small sparkle
    final sparklePaint = Paint()..color = const Color(0xFF8D7BB6);

    _drawSparkle(canvas, const Offset(126, 84), 5, sparklePaint);

    // ----------------------------------------------------------
    // RIGHT GAME SCREEN
    // ----------------------------------------------------------

    final gameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(150, 47, 112, 118),
      const Radius.circular(13),
    );

    // Shadow
    final gameShadow = Paint()..color = Colors.black.withValues(alpha: 0.12);

    canvas.drawRRect(gameRect.shift(const Offset(0, 5)), gameShadow);

    // Game screen
    final gamePaint = Paint()..color = const Color(0xFFCADDE6);

    canvas.drawRRect(gameRect, gamePaint);

    // ----------------------------------------------------------
    // GAME SKY
    // ----------------------------------------------------------

    final gameSky = Paint()..color = const Color(0xFF9DC8E2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(156, 53, 100, 106),
        const Radius.circular(9),
      ),
      gameSky,
    );

    // Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    canvas.drawCircle(const Offset(177, 76), 9, cloudPaint);

    canvas.drawCircle(const Offset(186, 74), 12, cloudPaint);

    canvas.drawCircle(const Offset(197, 77), 8, cloudPaint);

    // ----------------------------------------------------------
    // GAME MOUNTAINS
    // ----------------------------------------------------------

    final mountainGamePaint = Paint()..color = const Color(0xFF77959A);

    final gameMountain = Path()
      ..moveTo(156, 119)
      ..lineTo(177, 91)
      ..lineTo(193, 110)
      ..lineTo(211, 88)
      ..lineTo(234, 113)
      ..lineTo(256, 98)
      ..lineTo(256, 159)
      ..lineTo(156, 159)
      ..close();

    canvas.drawPath(gameMountain, mountainGamePaint);

    // ----------------------------------------------------------
    // PIXEL PLATFORM
    // ----------------------------------------------------------

    final platformPaint = Paint()..color = const Color(0xFF76513F);

    canvas.drawRect(const Rect.fromLTWH(160, 126, 48, 8), platformPaint);

    final grassTop = Paint()..color = const Color(0xFF70945A);

    canvas.drawRect(const Rect.fromLTWH(160, 122, 48, 6), grassTop);

    // Small floating platform
    canvas.drawRect(const Rect.fromLTWH(222, 109, 26, 6), grassTop);

    // ----------------------------------------------------------
    // PLAYER
    // ----------------------------------------------------------

    final playerBody = Paint()..color = const Color(0xFF5B4B8A);

    // Body
    canvas.drawRect(const Rect.fromLTWH(181, 104, 9, 14), playerBody);

    // Head
    final playerHead = Paint()..color = const Color(0xFFD19A6A);

    canvas.drawRect(const Rect.fromLTWH(181, 99, 9, 7), playerHead);

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF49372D);

    canvas.drawRect(const Rect.fromLTWH(181, 98, 9, 4), hairPaint);

    // Legs
    canvas.drawRect(const Rect.fromLTWH(182, 117, 3, 6), playerBody);

    canvas.drawRect(const Rect.fromLTWH(187, 117, 3, 6), playerBody);

    // ----------------------------------------------------------
    // COLLECTIBLE
    // ----------------------------------------------------------

    final collectiblePaint = Paint()..color = const Color(0xFFE7B84E);

    final diamond = Path()
      ..moveTo(226, 95)
      ..lineTo(231, 89)
      ..lineTo(236, 95)
      ..lineTo(231, 102)
      ..close();

    canvas.drawPath(diamond, collectiblePaint);

    // ----------------------------------------------------------
    // GOAL
    // ----------------------------------------------------------

    final goalPaint = Paint()..color = const Color(0xFF5B536B);

    canvas.drawRect(const Rect.fromLTWH(239, 122, 4, 26), goalPaint);

    final goalTop = Paint()..color = const Color(0xFF716A83);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(235, 118, 12, 11),
        const Radius.circular(3),
      ),
      goalTop,
    );

    // ----------------------------------------------------------
    // GAME UI
    // ----------------------------------------------------------

    final uiPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(162, 57, 28, 9),
        const Radius.circular(5),
      ),
      uiPaint,
    );

    // Tiny hearts
    final heartPaint = Paint()..color = const Color(0xFFD87878);

    canvas.drawCircle(const Offset(166, 61), 2, heartPaint);

    canvas.drawCircle(const Offset(172, 61), 2, heartPaint);

    // ----------------------------------------------------------
    // PIXEL CORNERS / DECORATION
    // ----------------------------------------------------------

    final pixelPaint = Paint()
      ..color = const Color(0xFF5B4B8A).withValues(alpha: 0.15);

    canvas.drawRect(const Rect.fromLTWH(153, 55, 4, 4), pixelPaint);

    canvas.drawRect(const Rect.fromLTWH(251, 151, 4, 4), pixelPaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.35, center.dy - size * 0.35)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx + size * 0.35, center.dy + size * 0.35)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.35, center.dy + size * 0.35)
      ..lineTo(center.dx - size, center.dy)
      ..lineTo(center.dx - size * 0.35, center.dy - size * 0.35)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
