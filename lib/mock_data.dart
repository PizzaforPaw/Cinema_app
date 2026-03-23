import 'models/movie_model.dart';
import 'models/booking_model.dart';

// ──────────────────────────────────────────────────
// IMAGES: Put your poster/banner files in:
//   assets/images/posters/    (portrait, ~400x600)
//   assets/images/banners/    (landscape, ~800x400)
//
// Then register them in pubspec.yaml:
//   flutter:
//     assets:
//       - assets/images/posters/
//       - assets/images/banners/
// ──────────────────────────────────────────────────

final List<Movie> mockMovies = [
  Movie(
    id: '1',
    title: 'TIỂU YÊU QUÁI NÚI LÃNG LÃNG',
    description:
        'Câu chuyện về một tiểu yêu quái đáng yêu sống trên ngọn núi huyền bí, '
        'phải đối mặt với những thử thách để bảo vệ ngôi làng nhỏ bé.',
    posterUrl: 'assets/images/posters/tieu_yeu_quai.jpg',
    bannerUrl: 'assets/images/banners/tieu_yeu_quai.jpg',
    duration: '1 giờ 58 phút',
    releaseDate: '23 Thg 1, 2026',
    ageRating: 'P',
    genre: ['Hoạt hình', 'Phiêu lưu', 'Gia đình'],
    cast: ['Ngô Thanh Vân', 'Trấn Thành'],
    director: 'Phan Gia Nhật Linh',
    rating: 8.2,
    status: 'now_showing',
  ),
  Movie(
    id: '2',
    title: 'MAI',
    description:
        'Mai - một người phụ nữ đẹp nhưng lạnh lùng, mang trong mình nỗi đau '
        'quá khứ. Liệu tình yêu có đủ sức chữa lành mọi vết thương?',
    posterUrl: 'assets/images/posters/mai.jpg',
    bannerUrl: 'assets/images/banners/mai.jpg',
    duration: '2 giờ 11 phút',
    releaseDate: '10 Thg 2, 2026',
    ageRating: '18',
    genre: ['Tình cảm', 'Tâm lý'],
    cast: ['Phương Anh Đào', 'Tuấn Trần', 'Hồng Đào'],
    director: 'Trấn Thành',
    rating: 7.8,
    status: 'now_showing',
  ),
  Movie(
    id: '3',
    title: 'LẬT MẶT 7',
    description:
        'Phần tiếp theo của loạt phim hành động ăn khách nhất Việt Nam. '
        'Những bí mật động trời dần được hé lộ trong cuộc chiến công lý.',
    posterUrl: 'assets/images/posters/lat_mat_7.jpg',
    bannerUrl: 'assets/images/banners/lat_mat_7.jpg',
    duration: '2 giờ 18 phút',
    releaseDate: '26 Thg 4, 2026',
    ageRating: '13',
    genre: ['Hành động', 'Hình sự'],
    cast: ['Lý Hải', 'Trương Thế Vinh'],
    director: 'Lý Hải',
    rating: 0.0,
    status: 'coming_soon',
  ),
  Movie(
    id: '4',
    title: 'DEADPOOL & WOLVERINE',
    description:
        'Deadpool và Wolverine hợp tác trong một cuộc phiêu lưu xuyên đa vũ trụ '
        'đầy hài hước và hành động mãn nhãn.',
    posterUrl: 'assets/images/posters/deadpool.jpg',
    bannerUrl: 'assets/images/banners/deadpool.jpg',
    duration: '2 giờ 08 phút',
    releaseDate: '15 Thg 3, 2026',
    ageRating: '18',
    genre: ['Hành động', 'Hài hước', 'Siêu anh hùng'],
    cast: ['Ryan Reynolds', 'Hugh Jackman'],
    director: 'Shawn Levy',
    rating: 9.0,
    status: 'special',
  ),
];

// Generate showtimes for the next 7 days
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

// Generate a seat map (8 rows x 10 seats, rows E-H are VIP)
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