import 'models/movie_model.dart';
import 'models/booking_model.dart';

final List<Movie> mockMovies = [
  // ═══ NOW SHOWING ═══
  Movie(
    id: '1',
    title: 'DUNE: PART TWO',
    description:
        'Paul Atreides unites with the Fremen on a warpath of revenge against '
        'those who destroyed his family, facing a choice between the love of '
        'his life and the fate of the universe.',
    posterUrl: 'assets/images/posters/dune.jpg',
    bannerUrl: 'assets/images/posters/dune.jpg',
    duration: '2h 46m',
    releaseDate: '01 Mar, 2026',
    ageRating: '13',
    genre: ['Sci-Fi', 'Adventure', 'Action'],
    cast: ['Timothée Chalamet', 'Zendaya', 'Austin Butler'],
    director: 'Denis Villeneuve',
    rating: 8.8,
    status: 'now_showing',
  ),
  Movie(
    id: '2',
    title: 'INSIDE OUT 2',
    description:
        'Riley enters her teenage years and Headquarters undergoes a sudden '
        'demolition to make room for new emotions: Anxiety, Envy, Ennui and Embarrassment.',
    posterUrl: 'assets/images/posters/inside_out_2.jpg',
    bannerUrl: 'assets/images/posters/inside_out_2.jpg',
    duration: '1h 36m',
    releaseDate: '14 Jun, 2026',
    ageRating: 'P',
    genre: ['Animation', 'Comedy', 'Family'],
    cast: ['Amy Poehler', 'Maya Hawke', 'Ayo Edebiri'],
    director: 'Kelsey Mann',
    rating: 8.0,
    status: 'now_showing',
  ),
  Movie(
    id: '3',
    title: 'THE BATMAN',
    description:
        'When a sadistic serial killer begins murdering key political figures '
        'in Gotham, Batman is forced to investigate the city\'s hidden corruption '
        'and question his family\'s involvement.',
    posterUrl: 'assets/images/posters/the_batman.jpg',
    bannerUrl: 'assets/images/posters/the_batman.jpg',
    duration: '2h 56m',
    releaseDate: '04 Mar, 2026',
    ageRating: '13',
    genre: ['Action', 'Crime', 'Drama'],
    cast: ['Robert Pattinson', 'Zoë Kravitz', 'Paul Dano'],
    director: 'Matt Reeves',
    rating: 8.1,
    status: 'now_showing',
  ),
  Movie(
    id: '4',
    title: 'INTERSTELLAR',
    description:
        'When Earth becomes uninhabitable, a team of explorers travels through '
        'a wormhole in search of a new home for humanity. A father\'s love '
        'transcends time and space.',
    posterUrl: 'assets/images/posters/interstella.jpg',
    bannerUrl: 'assets/images/posters/interstella.jpg',
    duration: '2h 49m',
    releaseDate: 'Re-release',
    ageRating: '13',
    genre: ['Sci-Fi', 'Drama', 'Adventure'],
    cast: ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain'],
    director: 'Christopher Nolan',
    rating: 9.2,
    status: 'now_showing',
  ),
  Movie(
    id: '5',
    title: 'EVERYTHING EVERYWHERE ALL AT ONCE',
    description:
        'A middle-aged Chinese immigrant is swept up in an insane adventure '
        'where she alone can save existence by exploring other universes '
        'and connecting with the lives she could have led.',
    posterUrl: 'assets/images/posters/eeaao.jpg',
    bannerUrl: 'assets/images/posters/eeaao.jpg',
    duration: '2h 19m',
    releaseDate: '25 Mar, 2026',
    ageRating: '16',
    genre: ['Sci-Fi', 'Action', 'Comedy'],
    cast: ['Michelle Yeoh', 'Ke Huy Quan', 'Jamie Lee Curtis'],
    director: 'Daniel Kwan, Daniel Scheinert',
    rating: 8.9,
    status: 'now_showing',
  ),

  // ═══ COMING SOON ═══
  Movie(
    id: '6',
    title: 'OPPENHEIMER',
    description:
        'The story of J. Robert Oppenheimer, the American physicist who led '
        'the Manhattan Project to develop the atomic bomb during World War II.',
    posterUrl: 'assets/images/posters/oppenheimer.jpg',
    bannerUrl: 'assets/images/posters/oppenheimer.jpg',
    duration: '3h 00m',
    releaseDate: '15 Apr, 2026',
    ageRating: '18',
    genre: ['Biography', 'History', 'Drama'],
    cast: ['Cillian Murphy', 'Robert Downey Jr.', 'Emily Blunt'],
    director: 'Christopher Nolan',
    rating: 9.0,
    status: 'coming_soon',
  ),
];

// ──────────────────────────────────────────────────
// SHOWTIMES & SEATS
// ──────────────────────────────────────────────────

List<Showtime> generateMockShowtimes(String movieId) {
  final List<Showtime> showtimes = [];
  final now = DateTime.now();

  final cinemas = [
    {'name': 'CGV Vincom Center', 'halls': ['Hall 1', 'Hall 2', 'Hall 3']},
    {'name': 'CGV Landmark 81', 'halls': ['Hall A', 'Hall B']},
    {'name': 'CGV Crescent Mall', 'halls': ['Room 1', 'Room 2']},
  ];

  final times = [10, 13, 15, 18, 20, 22];

  int idCounter = 0;
  for (int day = 0; day < 7; day++) {
    final date = DateTime(now.year, now.month, now.day + day);
    for (var cinema in cinemas) {
      final halls = cinema['halls'] as List<String>;
      for (var time in times) {
        idCounter++;
        final hall = halls[idCounter % halls.length];
        final screenType = idCounter % 5 == 0 ? 'IMAX' : (idCounter % 3 == 0 ? '3D' : '2D');
        final basePrice = screenType == 'IMAX' ? 150000 : (screenType == '3D' ? 100000 : 75000);

        showtimes.add(Showtime(
          id: 'st_$idCounter',
          movieId: movieId,
          cinemaName: cinema['name'] as String,
          hallName: hall,
          dateTime: DateTime(date.year, date.month, date.day, time, 0),
          price: basePrice,
          screenType: screenType,
        ));
      }
    }
  }
  return showtimes;
}

List<List<Seat>> generateSeatMap() {
  final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final vipRows = {'E', 'F', 'G', 'H'};
  final seatsPerRow = 10;

  return rows.map((row) {
    return List.generate(seatsPerRow, (i) {
      final seat = Seat(
        row: row,
        number: i + 1,
        isVip: vipRows.contains(row),
      );
      if ((row.hashCode + i) % 7 == 0) {
        seat.status = SeatStatus.booked;
      }
      return seat;
    });
  }).toList();
}