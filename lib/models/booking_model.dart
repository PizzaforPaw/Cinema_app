class Showtime {
  final String id;
  final String movieId;
  final String cinemaName;
  final String hallName;
  final DateTime dateTime;
  final int price; // in VND
  final String screenType; // "2D", "3D", "IMAX"

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaName,
    required this.hallName,
    required this.dateTime,
    required this.price,
    this.screenType = '2D',
  });
}

enum SeatStatus { available, selected, booked }

class Seat {
  final String row;    // "A", "B", "C"...
  final int number;    // 1, 2, 3...
  SeatStatus status;
  final bool isVip;    // VIP seats cost more

  Seat({
    required this.row,
    required this.number,
    this.status = SeatStatus.available,
    this.isVip = false,
  });

  String get label => '$row$number';
}

class Booking {
  final String id;
  final String movieTitle;
  final String cinemaName;
  final String hallName;
  final DateTime showtime;
  final List<String> seatLabels;
  final int totalPrice;
  final String status; // "pending", "confirmed", "used", "cancelled"

  Booking({
    required this.id,
    required this.movieTitle,
    required this.cinemaName,
    required this.hallName,
    required this.showtime,
    required this.seatLabels,
    required this.totalPrice,
    this.status = 'pending',
  });
}