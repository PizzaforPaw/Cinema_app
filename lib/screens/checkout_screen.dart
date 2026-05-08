import 'package:flutter/material.dart';
import 'dart:math';
import '../models/movie_model.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/seat_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;
  final List<Seat> seats;
  final int totalPrice;

  const CheckoutScreen({
    Key? key,
    required this.movie,
    required this.showtime,
    required this.seats,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;
  bool _isConfirmed = false;
  String _bookingId = '';

  String _formatPrice(int price) {
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

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m · ${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);

    final seatLabels = widget.seats.map((s) => s.label).toList();

    // Step 1: Reserve seats in Firestore (with conflict check)
    final seatError = await SeatService.bookSeats(
      showtimeId: widget.showtime.id,
      seatLabels: seatLabels,
    );

    if (seatError != null) {
      // Someone booked the same seat — show error
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(seatError),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Step 2: Save booking record
    final id = 'BK${Random().nextInt(999999).toString().padLeft(6, '0')}';

    await BookingService.saveBooking(
      movieTitle: widget.movie.title,
      cinemaName: widget.showtime.cinemaName,
      hallName: widget.showtime.hallName,
      screenType: widget.showtime.screenType,
      showtime: widget.showtime.dateTime,
      seatLabels: seatLabels,
      totalPrice: widget.totalPrice,
      bookingId: id,
    );

    // Simulate payment processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isConfirmed = true;
        _bookingId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.08);

    if (_isConfirmed) {
      return _buildConfirmationScreen(context, isDark, textColor, subtextColor, cardColor, borderColor);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thanh toán',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── BOOKING SUMMARY CARD ───
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie title
                Text(
                  widget.movie.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Details
                _infoRow(Icons.location_on, widget.showtime.cinemaName, subtextColor),
                const SizedBox(height: 10),
                _infoRow(Icons.meeting_room, '${widget.showtime.hallName} · ${widget.showtime.screenType}', subtextColor),
                const SizedBox(height: 10),
                _infoRow(Icons.access_time, _formatDateTime(widget.showtime.dateTime), subtextColor),
                const SizedBox(height: 10),
                _infoRow(Icons.event_seat, widget.seats.map((s) => s.label).join(', '), subtextColor),

                Divider(color: borderColor, height: 32),

                // Price breakdown
                ...widget.seats.map((seat) {
                  final price = seat.isVip
                      ? (widget.showtime.price * 1.3).round()
                      : widget.showtime.price;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ghế ${seat.label} ${seat.isVip ? "(VIP)" : ""}',
                          style: TextStyle(color: subtextColor, fontSize: 14),
                        ),
                        Text(
                          _formatPrice(price),
                          style: TextStyle(color: subtextColor, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }),

                Divider(color: borderColor, height: 24),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatPrice(widget.totalPrice),
                      style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── PAYMENT METHOD ───
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phương thức thanh toán',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // QR Code placeholder
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // QR placeholder
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 80, color: Colors.grey.shade800),
                            const SizedBox(height: 8),
                            Text(
                              'QR Thanh toán',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Quét mã QR bằng ứng dụng ngân hàng',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(widget.totalPrice),
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bank info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _bankInfoRow('Ngân hàng', 'Vietcombank', textColor, subtextColor),
                      const SizedBox(height: 8),
                      _bankInfoRow('Số TK', '1234 5678 9012', textColor, subtextColor),
                      const SizedBox(height: 8),
                      _bankInfoRow('Chủ TK', 'CONG TY CINEMA APP', textColor, subtextColor),
                      const SizedBox(height: 8),
                      _bankInfoRow('Nội dung CK', 'CINEMA ${widget.seats.map((s) => s.label).join('')}', textColor, subtextColor),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Timer warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ghế sẽ được giữ trong 10 phút. Vui lòng thanh toán trước khi hết thời gian.',
                    style: TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _isProcessing ? null : _confirmPayment,
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Xác nhận đã chuyển khoản',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── CONFIRMATION SCREEN ───
  Widget _buildConfirmationScreen(BuildContext context, bool isDark, Color textColor, Color subtextColor, Color cardColor, Color borderColor) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                'Đặt vé thành công!',
                style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã đặt vé: $_bookingId',
                style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.movie.title,
                      style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _ticketRow('Rạp', widget.showtime.cinemaName, textColor, subtextColor),
                    _ticketRow('Phòng', '${widget.showtime.hallName} · ${widget.showtime.screenType}', textColor, subtextColor),
                    _ticketRow('Suất', _formatDateTime(widget.showtime.dateTime), textColor, subtextColor),
                    _ticketRow('Ghế', widget.seats.map((s) => s.label).join(', '), textColor, subtextColor),
                    _ticketRow('Tổng', _formatPrice(widget.totalPrice), textColor, subtextColor),

                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(30, (i) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            height: 1,
                            color: i % 2 == 0 ? (isDark ? Colors.white24 : Colors.black12) : Colors.transparent,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đưa mã này tại quầy vé',
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Về trang chủ',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HELPERS ───

  Widget _infoRow(IconData icon, String text, Color subtextColor) {
    return Row(
      children: [
        Icon(icon, color: subtextColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: subtextColor, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _bankInfoRow(String label, String value, Color textColor, Color subtextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: subtextColor, fontSize: 13)),
        Text(value, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _ticketRow(String label, String value, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: TextStyle(color: subtextColor, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textColor, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}