import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MovieService {
  static final _moviesRef = FirebaseFirestore.instance.collection('movies');

  /// Stream all movies (real-time updates)
  static Stream<List<Movie>> streamAllMovies() {
    return _moviesRef
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  /// Stream movies by status
  static Stream<List<Movie>> streamMoviesByStatus(String status) {
    return _moviesRef
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  /// Add a new movie
  static Future<String?> addMovie(Movie movie) async {
    try {
      await _moviesRef.add(movie.toFirestore());
      return null;
    } catch (e) {
      return 'Lỗi thêm phim: $e';
    }
  }

  /// Update an existing movie
  static Future<String?> updateMovie(String movieId, Movie movie) async {
    try {
      await _moviesRef.doc(movieId).update(movie.toFirestore());
      return null;
    } catch (e) {
      return 'Lỗi cập nhật: $e';
    }
  }

  /// Delete a movie
  static Future<String?> deleteMovie(String movieId) async {
    try {
      await _moviesRef.doc(movieId).delete();
      return null;
    } catch (e) {
      return 'Lỗi xoá phim: $e';
    }
  }
}