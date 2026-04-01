import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/movie_model.dart';
import '../models/news_model.dart';
import '../services/movie_service.dart';
import '../widgets/movie_image.dart';
import '../mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPosterIndex = 0;
  int _selectedTabIndex = 0;

  Timer? _bannerTimer;
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
    initialPage: 500, // Start in middle so user can scroll left too
  );
  final PageController _posterController = PageController(
    viewportFraction: 0.7,
    initialPage: 500,
  );

  final List<String> _tabs = ['Đang chiếu', 'Sắp chiếu', 'Đặc biệt'];
  final List<String> _tabStatus = ['now_showing', 'coming_soon', 'special'];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_bannerController.hasClients) {
        final currentPage = (_bannerController.page ?? 0).round();
        _bannerController.animateToPage(
          currentPage + 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _posterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.person_outline, color: textColor, size: 28),
          onPressed: () {
            // If logged in → profile, if not → login
            if (FirebaseAuth.instance.currentUser != null) {
              Navigator.pushNamed(context, '/profile');
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },
        ),
        title: Text(
          'CINEMA',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor, size: 24),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),

      body: StreamBuilder<List<Movie>>(
        stream: MovieService.streamAllMovies(),
        builder: (context, snapshot) {
          // Fall back to mock data if: Firestore errors, still loading, or empty
          List<Movie> allMovies;
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            allMovies = mockMovies;
          } else {
            allMovies = snapshot.data!;
          }

          final movies = allMovies
              .where((m) => m.status == _tabStatus[_selectedTabIndex])
              .toList();

          if (_currentPosterIndex >= movies.length) {
            _currentPosterIndex = 0;
          }

          return ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              _buildBannerCarousel(allMovies),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 20),
              if (movies.isNotEmpty) ...[
                _buildPosterCarousel(movies),
                const SizedBox(height: 20),
                _buildMovieInfo(movies),
              ] else
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Không có phim trong mục này.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // 4. NEWS SECTION
              _buildNewsSection(isDark),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  // ─── BANNER ───
  Widget _buildBannerCarousel(List<Movie> bannerMovies) {
    if (bannerMovies.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: bannerMovies.length * 1000, // large number for infinite loop
        itemBuilder: (context, index) {
          final movie = bannerMovies[index % bannerMovies.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/movie-detail', arguments: movie),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MovieImage(path: movie.bannerUrl),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                        child: Text(
                          movie.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── TABS ───
  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedTabIndex == index;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedTabIndex = index;
            _currentPosterIndex = 0;
          }),
          child: Column(
            children: [
              Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? activeColor : inactiveColor,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isSelected ? 40 : 0,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── POSTER CAROUSEL ───
  Widget _buildPosterCarousel(List<Movie> movies) {
    // Single movie — just show it centered, no carousel
    if (movies.length == 1) {
      return SizedBox(
        height: 360,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/movie-detail', arguments: movies[0]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MovieImage(path: movies[0].posterUrl),
              ),
            ),
          ),
        ),
      );
    }

    // Multiple movies — infinite loop carousel
    return SizedBox(
      height: 360,
      child: PageView.builder(
        controller: _posterController,
        itemCount: movies.length * 1000,
        onPageChanged: (index) => setState(() => _currentPosterIndex = index % movies.length),
        itemBuilder: (context, index) {
          final movie = movies[index % movies.length];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/movie-detail', arguments: movie),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MovieImage(path: movie.posterUrl),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── MOVIE INFO + BOOKING ───
  Widget _buildMovieInfo(List<Movie> movies) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white54 : Colors.black54;

    final movie = movies[_currentPosterIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (movie.rating > 0) ...[
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(movie.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.amber, fontSize: 14)),
                      const SizedBox(width: 12),
                    ],
                    Text(movie.duration,
                        style: TextStyle(color: subtextColor, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(movie.ageRating,
                          style: const TextStyle(color: Colors.amber, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pushNamed(context, '/movie-detail', arguments: movie),
            child: const Text('Đặt Vé',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // ─── NEWS SECTION ───
  Widget _buildNewsSection(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF16213E) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tin tức phim',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: subtextColor, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal news cards
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: mockNews.length,
            itemBuilder: (context, index) {
              final news = mockNews[index];
              return _buildNewsCard(news, isDark, textColor, subtextColor, cardColor, borderColor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(
    MovieNews news,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: MovieImage(path: news.imageUrl),
                ),
                // Tag badge
                if (news.tag.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _tagColor(news.tag),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        news.tag,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (news.source.isNotEmpty) ...[
                        Text(
                          news.source,
                          style: TextStyle(color: subtextColor, fontSize: 11),
                        ),
                        Text(' · ', style: TextStyle(color: subtextColor, fontSize: 11)),
                      ],
                      Text(
                        news.date,
                        style: TextStyle(color: subtextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Hot':
        return Colors.redAccent;
      case 'Upcoming':
        return Colors.blue;
      case 'Box Office':
        return Colors.green;
      case 'Awards':
        return Colors.amber.shade700;
      case 'Review':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}