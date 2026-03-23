import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../widgets/movie_image.dart';
import '../services/auth_guard.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  void _handleBooking(BuildContext context) async {
    // Check if user is logged in before allowing booking
    final isAuthed = await AuthGuard.checkAuth(context);
    if (isAuthed && context.mounted) {
      Navigator.pushNamed(context, '/showtime', arguments: movie);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── COLLAPSIBLE BANNER ───
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  MovieImage(path: movie.bannerUrl),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF1A1A2E)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── BODY ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: MovieImage(
                          path: movie.posterUrl,
                          width: 100,
                          height: 150,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (movie.rating > 0)
                              Row(
                                children: [
                                  ...List.generate(5, (i) {
                                    final starValue = (i + 1) * 2;
                                    if (movie.rating >= starValue) {
                                      return const Icon(Icons.star, color: Colors.amber, size: 18);
                                    } else if (movie.rating >= starValue - 1) {
                                      return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                                    }
                                    return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    movie.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _metaChip(Icons.access_time, movie.duration),
                                _metaChip(Icons.calendar_today, movie.releaseDate),
                                _ageRatingChip(movie.ageRating),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Genre Tags
                  if (movie.genre.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.genre.map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(g, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  if (movie.description.isNotEmpty) ...[
                    const Text('Nội dung',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(movie.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
                    const SizedBox(height: 24),
                  ],

                  // Director
                  if (movie.director.isNotEmpty) ...[
                    const Text('Đạo diễn',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(movie.director,
                        style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 24),
                  ],

                  // Cast
                  if (movie.cast.isNotEmpty) ...[
                    const Text('Diễn viên',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: movie.cast.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.white12,
                                child: Text(
                                  movie.cast[index][0],
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  movie.cast[index],
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── BOOK BUTTON (with auth check) ───
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: () => _handleBooking(context),
              child: const Text(
                'Đặt Vé Ngay',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  Widget _ageRatingChip(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(rating,
          style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}