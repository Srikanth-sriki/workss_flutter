// import 'package:flutter/material.dart';
//
// void showModernImagePreview(BuildContext context, String url, {required Object heroTag}) {
//   Navigator.of(context).push(
//     PageRouteBuilder(
//       opaque: false,
//       pageBuilder: (_, __, ___) => _ModernImageViewer(url: url, heroTag: heroTag),
//       transitionsBuilder: (_, anim, __, child) =>
//           FadeTransition(opacity: anim, child: child),
//     ),
//   );
// }
//
// class _ModernImageViewer extends StatefulWidget {
//   final String url;
//   final Object heroTag;
//
//   const _ModernImageViewer({required this.url, required this.heroTag});
//
//   @override
//   State<_ModernImageViewer> createState() => _ModernImageViewerState();
// }
//
// class _ModernImageViewerState extends State<_ModernImageViewer> with SingleTickerProviderStateMixin {
//   double _dragDy = 0.0;
//   double _scale = 1.0;
//
//   @override
//   Widget build(BuildContext context) {
//     final dismissThreshold = MediaQuery.of(context).size.height * 0.18;
//     final t = (_dragDy.abs() / dismissThreshold).clamp(0.0, 1.0);
//     final backdropOpacity = (0.9 * (1.0 - t)).clamp(0.0, 0.9);
//
//     return GestureDetector(
//       onTap: () => Navigator.of(context).pop(),
//       onDoubleTap: () {
//         setState(() => _scale = _scale == 1.0 ? 2.0 : 1.0); // double tap zoom
//       },
//       onVerticalDragUpdate: (d) => setState(() => _dragDy += d.delta.dy),
//       onVerticalDragEnd: (_) {
//         if (_dragDy > dismissThreshold) {
//           Navigator.of(context).pop();
//         } else {
//           setState(() => _dragDy = 0.0);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black.withOpacity(backdropOpacity),
//         body: Stack(
//           children: [
//             Center(
//               child: Hero(
//                 tag: widget.heroTag,
//                 child: Transform.translate(
//                   offset: Offset(0, _dragDy),
//                   child: InteractiveViewer(
//                     maxScale: 4.0,
//                     minScale: 0.8,
//                     child: AnimatedScale(
//                       duration: const Duration(milliseconds: 250),
//                       scale: _scale,
//                       child: Image.network(
//                         widget.url,
//                         fit: BoxFit.contain,
//                         loadingBuilder: (c, child, p) =>
//                         p == null ? child : const CircularProgressIndicator(),
//                         errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 60, color: Colors.white70),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // gradient background at top
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               height: 100,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.black54, Colors.transparent],
//                   ),
//                 ),
//               ),
//             ),
//
//             // close button
//             Positioned(
//               top: 24,
//               left: 12,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 28),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

/// Open a simple WhatsApp-style image preview (semi-transparent background,
/// image centered at ~89% screen width).
void showSimpleImagePreview(BuildContext context, String url) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.9), // WhatsApp-like dark overlay
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => _SimpleImageViewer(url: url),
      transitionsBuilder: (_, __, ___, child) => child,
    ),
  );
}

class _SimpleImageViewer extends StatefulWidget {
  const _SimpleImageViewer({required this.url});
  final String url;

  @override
  State<_SimpleImageViewer> createState() => _SimpleImageViewerState();
}

class _SimpleImageViewerState extends State<_SimpleImageViewer> {
  final _controller = TransformationController();
  final _doubleTapZoom = 2.0;

  void _handleDoubleTapDown(TapDownDetails d) {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
      return;
    }
    final tapPos = d.localPosition;
    final zoom = _doubleTapZoom;
    final x = -tapPos.dx * (zoom - 1);
    final y = -tapPos.dy * (zoom - 1);
    _controller.value = Matrix4.identity()
      ..translate(x, y)
      ..scale(zoom);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetWidth = screenWidth * 0.9;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTapDown: _handleDoubleTapDown,
                  onDoubleTap: () {},
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: targetWidth,
                      ),
                      child: Image.network(
                        widget.url,
                        fit: BoxFit.contain,
                        loadingBuilder: (c, child, progress) =>
                        progress == null
                            ? child
                            : const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        ),
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
