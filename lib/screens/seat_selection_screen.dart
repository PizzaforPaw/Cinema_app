import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../models/booking_model.dart';
import '../mock_data.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;

  const SeatSelectionScreen({
    Key? key,
    required this.movie,
    required this.showtime,
  }) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late List<List<Seat>> _seatMap;
  final List<Seat> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _seatMap = generateSeatMap();
  }

  int get _totalPrice {
    int total = 0;
    for (var seat in _selectedSeats) {
      if (seat.isVip) {
        total += (widget.showtime.price * 1.3).round(); // VIP = +30%
      } else {
        total += widget.showtime.price;
      }
    }
    return total;
  }

  String _formatPrice(int price) {
    // Format as 75.000đ
    final str = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return '${buffer.toString().split('').reversed.join()}đ';
  }

  void _toggleSeat(Seat seat) {
    if (seat.status == SeatStatus.booked) return;

    setState(() {
      if (seat.status == SeatStatus.selected) {
        seat.status = SeatStatus.available;
        _selectedSeats.remove(seat);
      } else {
        seat.status = SeatStatus.selected;
        _selectedSeats.add(seat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${widget.showtime.dateTime.hour.toString().padLeft(2, '0')}:${widget.showtime.dateTime.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${widget.showtime.dateTime.day}/${widget.showtime.dateTime.month}';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.showtime.hallName} · $timeStr · $dateStr',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ─── SCREEN INDICATOR ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'MÀN HÌNH',
                  style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── SEAT MAP ───
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 2.0,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: _seatMap.map((row) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Row label
                            SizedBox(
                              width: 24,
                              child: Text(
                                row.first.row,
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Seats
                            ...row.map((seat) {
                              return GestureDetector(
                                onTap: () => _toggleSeat(seat),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: _seatColor(seat),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(3),
                                      bottomRight: Radius.circular(3),
                                    ),
                                    border: Border.all(
                                      color: _seatBorderColor(seat),
                                      width: seat.status == SeatStatus.selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${seat.number}',
                                      style: TextStyle(
                                        color: seat.status == SeatStatus.booked
                                            ? Colors.white12
                                            : Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            // Row label (right side)
                            SizedBox(
                              width: 24,
                              child: Text(
                                row.first.row,
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // ─── LEGEND ───
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(Colors.white.withOpacity(0.08), Colors.white24, 'Trống'),
                const SizedBox(width: 16),
                _legendItem(Colors.redAccent, Colors.redAccent, 'Đang chọn'),
                const SizedBox(width: 16),
                _legendItem(Colors.white.withOpacity(0.03), Colors.white10, 'Đã bán'),
                const SizedBox(width: 16),
                _legendItem(Colors.amber.withOpacity(0.15), Colors.amber.withOpacity(0.4), 'VIP'),
              ],
            ),
          ),

          // ─── BOTTOM: SELECTION SUMMARY + CHECKOUT ───
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected seats display
                  if (_selectedSeats.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text('Ghế: ', style: TextStyle(color: Colors.white54, fontSize: 14)),
                        Expanded(
                          child: Text(
                            _selectedSeats.map((s) => s.label).join(', '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Tổng: ', style: TextStyle(color: Colors.white54, fontSize: 14)),
                        Text(
                          _formatPrice(_totalPrice),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedSeats.isEmpty ? Colors.white12 : Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: _selectedSeats.isEmpty
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                '/checkout',
                                arguments: {
                                  'movie': widget.movie,
                                  'showtime': widget.showtime,
                                  'seats': List<Seat>.from(_selectedSeats),
                                  'totalPrice': _totalPrice,
                                },
                              );
                            },
                      child: Text(
                        _selectedSeats.isEmpty
                            ? 'Chọn ghế để tiếp tục'
                            : 'Thanh toán ${_formatPrice(_totalPrice)}',
                        style: TextStyle(
                          color: _selectedSeats.isEmpty ? Colors.white24 : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _seatColor(Seat seat) {
    switch (seat.status) {
      case SeatStatus.selected:
        return Colors.redAccent;
      case SeatStatus.booked:
        return Colors.white.withOpacity(0.03);
      case SeatStatus.available:
        if (seat.isVip) return Colors.amber.withOpacity(0.15);
        return Colors.white.withOpacity(0.08);
    }
  }

  Color _seatBorderColor(Seat seat) {
    switch (seat.status) {
      case SeatStatus.selected:
        return Colors.redAccent;
      case SeatStatus.booked:
        return Colors.white10;
      case SeatStatus.available:
        if (seat.isVip) return Colors.amber.withOpacity(0.4);
        return Colors.white24;
    }
  }

  Widget _legendItem(Color fill, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}