import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A beautiful full-screen image viewer with:
/// - Pinch-to-zoom and pan
/// - Double-tap to zoom in/out
/// - Hero animation support
/// - Animated bars that hide on tap
class FullScreenImageViewer extends StatefulWidget {
  final String imagePath;
  final String title;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
    this.heroTag,
  });

  static void show(
    BuildContext context, {
    required String imagePath,
    required String title,
    String? heroTag,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenImageViewer(
          imagePath: imagePath,
          title: title,
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformController;
  late final AnimationController _animController;
  Animation<Matrix4>? _animReset;

  bool _showBars = true;
  final double _minScale = 1.0;
  final double _maxScale = 5.0;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_animReset != null) {
          _transformController.value = _animReset!.value;
        }
      });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_transformController.value != Matrix4.identity()) {
      _animReset = Matrix4Tween(
        begin: _transformController.value,
        end: Matrix4.identity(),
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      _animController.forward(from: 0);
    } else {
      final position = details.localPosition;
      const double scale = 2.5;
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);
      final Matrix4 zoomed = Matrix4.identity()
        ..translateByDouble(x, y, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
      _animReset = Matrix4Tween(
        begin: _transformController.value,
        end: zoomed,
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      _animController.forward(from: 0);
    }
  }

  void _toggleBars() => setState(() => _showBars = !_showBars);

  @override
  Widget build(BuildContext context) {
    final image = Image.file(
      File(widget.imagePath),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    final imageWidget = widget.heroTag != null
        ? Hero(tag: widget.heroTag!, child: image)
        : image;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleBars,
            onDoubleTapDown: _handleDoubleTap,
            onDoubleTap: () {},
            child: InteractiveViewer(
              transformationController: _transformController,
              clipBehavior: Clip.none,
              minScale: _minScale,
              maxScale: _maxScale,
              child: Center(child: imageWidget),
            ),
          ),
          AnimatedSlide(
            offset: _showBars ? Offset.zero : const Offset(0, -1),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _showBars ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AnimatedSlide(
              offset: _showBars ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _showBars ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_outlined, color: Colors.white54, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Pinch to zoom  •  Double-tap to toggle zoom  •  Tap to hide UI',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
