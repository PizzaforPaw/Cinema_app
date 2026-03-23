import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;  // Can be asset path (assets/...) or network URL (https://...)
  final String bannerUrl;  // Can be asset path (assets/...) or network URL (https://...)
  final String trailerUrl;
  final String duration;
  final String releaseDate;
  final String ageRating;
  final List<String> genre;
  final List<String> cast;
  final String director;
  final double rating;
  final String status;

  Movie({
    required this.id,
    required this.title,
    this.description = '',
    required this.posterUrl,
    required this.bannerUrl,
    this.trailerUrl = '',
    required this.duration,
    required this.releaseDate,
    required this.ageRating,
    this.genre = const [],
    this.cast = const [],
    this.director = '',
    this.rating = 0.0,
    this.status = 'now_showing',
  });

  /// Check if an image path is a local asset
  static bool isAsset(String path) => path.startsWith('assets/');

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '',
      duration: data['duration'] ?? '',
      releaseDate: data['releaseDate'] ?? '',
      ageRating: data['ageRating'] ?? '',
      genre: List<String>.from(data['genre'] ?? []),
      cast: List<String>.from(data['cast'] ?? []),
      director: data['director'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      status: data['status'] ?? 'now_showing',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'bannerUrl': bannerUrl,
      'trailerUrl': trailerUrl,
      'duration': duration,
      'releaseDate': releaseDate,
      'ageRating': ageRating,
      'genre': genre,
      'cast': cast,
      'director': director,
      'rating': rating,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}