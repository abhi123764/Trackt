import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/trackt_logo_painter.dart';

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

    _navigationTimer = Timer(
      const Duration(seconds: 2),
      _checkSessionAndNavigate,
    );
  }

  Future<void> _checkSessionAndNavigate() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.restoreSession();

    if (!mounted) return;

    final Widget targetScreen = isLoggedIn
        ? const DashboardScreen()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => targetScreen,
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
                      child: const CustomPaint(painter: TracktLogoPainter()),
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
