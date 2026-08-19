import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackt/theme/app_theme.dart';
import 'package:trackt/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String appVersion = 'v4.2.0';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    _navigationTimer = Timer(const Duration(seconds: 2), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final bool isSmallScreen = size.height < 650;
    final bool isTablet = size.width >= 600;

    final double logoSize = isTablet
        ? 170
        : isSmallScreen
        ? 110
        : 140;

    final double titleSize = isTablet
        ? 42
        : isSmallScreen
        ? 30
        : 36;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Logo
                    SizedBox(
                      width: logoSize,
                      height: logoSize,
                      child: CustomPaint(painter: _TracktLogoPainter()),
                    ),

                    SizedBox(height: isSmallScreen ? 8 : 12),

                    // App name
                    Text(
                      'Trackt',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Tagline
                    const Text(
                      'TRACK. MANAGE. GROW.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: AppColors.accentGreen,
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Loading dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.tealPrimary,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 8),

                    // Version
                    const Text(
                      SplashScreen.appVersion,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Trackt logo painter
class _TracktLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 6);

    // Green growth arc
    final arcPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.043
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.34),
      0.35,
      2.5,
      false,
      arcPaint,
    );

    // Growth arrow
    final arrowPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.036
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.36)
      ..lineTo(size.width * 0.44, size.height * 0.50)
      ..lineTo(size.width * 0.56, size.height * 0.40)
      ..lineTo(size.width * 0.76, size.height * 0.20);

    canvas.drawPath(path, arrowPaint);

    final arrowHead = Path()
      ..moveTo(size.width * 0.62, size.height * 0.18)
      ..lineTo(size.width * 0.78, size.height * 0.18)
      ..lineTo(size.width * 0.78, size.height * 0.32);

    canvas.drawPath(arrowHead, arrowPaint);

    // Person
    final bodyPaint = Paint()..color = AppColors.textPrimary;

    canvas.drawCircle(Offset(center.dx, center.dy - 14), 9, bodyPaint);

    final torso = Path()
      ..moveTo(center.dx - 14, center.dy + 26)
      ..quadraticBezierTo(
        center.dx - 16,
        center.dy - 4,
        center.dx,
        center.dy - 2,
      )
      ..quadraticBezierTo(
        center.dx + 16,
        center.dy - 4,
        center.dx + 14,
        center.dy + 26,
      )
      ..close();

    canvas.drawPath(torso, bodyPaint);

    // Barbell
    final barPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = size.width * 0.029
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - size.width * 0.21, center.dy - size.height * 0.043),
      Offset(center.dx + size.width * 0.21, center.dy - size.height * 0.043),
      barPaint,
    );

    for (final dx in [-0.21, 0.21]) {
      final weightPaint = Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = size.width * 0.043
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(center.dx + size.width * dx, center.dy - size.height * 0.114),
        Offset(center.dx + size.width * dx, center.dy + size.height * 0.029),
        weightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
