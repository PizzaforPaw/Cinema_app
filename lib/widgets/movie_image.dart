import 'package:flutter/material.dart';
import '../models/movie_model.dart';

/// Smart image widget that handles:
/// - Asset images (paths starting with "assets/")
/// - Network images (URLs starting with "http")
/// - Error fallback with movie icon placeholder
class MovieImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  const MovieImage({
    Key? key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _placeholder();

    if (Movie.isAsset(path)) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.white10,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withOpacity(0.05),
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white24, size: 40),
      ),
    );
  }
}