
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;



Future<Uint8List> trimTransparentPadding(Uint8List bytes) =>
    compute<_TrimInput, Uint8List>(
        _trimTransparentPaddingIsolate, _TrimInput(bytes));

class _TrimInput {
  final Uint8List bytes;
  const _TrimInput(this.bytes);
}

Uint8List _trimTransparentPaddingIsolate(_TrimInput input) {
  final src = img.decodeImage(input.bytes);
  if (src == null) return input.bytes;

  int top = 0, left = 0, right = src.width - 1, bottom = src.height - 1;

  bool rowTransparent(int y) {
    for (int x = 0; x < src.width; x++) {
      if (src.getPixel(x, y).a != 0) return false; // Pixel.a in v4
    }
    return true;
  }

  bool colTransparent(int x) {
    for (int y = 0; y < src.height; y++) {
      if (src.getPixel(x, y).a != 0) return false;
    }
    return true;
  }

  while (top <= bottom && rowTransparent(top)) top++;
  while (bottom >= top && rowTransparent(bottom)) bottom--;
  while (left <= right && colTransparent(left)) left++;
  while (right >= left && colTransparent(right)) right--;

  if (left > right || top > bottom) return input.bytes;

  final cropped = img.copyCrop(src,
      x: left, y: top, width: right - left + 1, height: bottom - top + 1);

  return Uint8List.fromList(img.encodePng(cropped));
}

/// ----- Widget: CategoryAvatar -----

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.url,
    required this.bgColor,
    this.size = 76.0,
    this.placeholder,
    this.error,
  });

  final String url;
  final Color bgColor;
  final double size;
  final Widget? placeholder;
  final Widget? error;

  Future<Uint8List> _loadTrimmed() async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Image load failed: ${resp.statusCode}');
    }
    return trimTransparentPadding(resp.bodyBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor.withOpacity(0.3),
      ),
      child: ClipOval(
        child: FutureBuilder<Uint8List>(
          future: _loadTrimmed(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return placeholder ?? const SizedBox.shrink();
            }
            if (snap.hasError || !snap.hasData) {
              return error ??
                  Center(
                    child: Icon(Icons.broken_image,
                        size: size * 0.45, color: Colors.black26),
                  );
            }
            return Image.memory(
              snap.data!,
              fit: BoxFit.contain, // show full icon without crop
              alignment: Alignment.center,
            );
          },
        ),
      ),
    );
  }
}
