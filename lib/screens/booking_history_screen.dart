import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/booking_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookings = await BookingService.getMyBookings();
    if (mounted) {
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    }
  }

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

  String _formatDateTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m · ${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF16213E) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.08);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử đặt vé',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? Colors.white24 : Colors.black26))
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.confirmation_number_outlined,
                          color: isDark ? Colors.white24 : Colors.black26, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có vé nào.',
                        style: TextStyle(color: subtextColor, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đặt vé xem phim ngay!',
                        style: TextStyle(color: subtextColor.withOpacity(0.6), fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final isPast = _isShowtimePast(booking['showtime'] as Timestamp?);

                    return GestureDetector(
                      onTap: () => _showTicketQR(context, booking, isDark, textColor, subtextColor, cardColor, borderColor),
                      child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          // Header with status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isPast
                                  ? (isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.08))
                                  : Colors.redAccent.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  booking['bookingId'] ?? '',
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isPast ? Colors.grey.withOpacity(0.2) : Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isPast ? 'Đã xem' : 'Sắp chiếu',
                                    style: TextStyle(
                                      color: isPast ? Colors.grey : Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Booking details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['movieTitle'] ?? '',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _infoRow(Icons.location_on, booking['cinemaName'] ?? '', textColor, subtextColor),
                                const SizedBox(height: 6),
                                _infoRow(
                                  Icons.meeting_room,
                                  '${booking['hallName'] ?? ''} · ${booking['screenType'] ?? ''}',
                                  textColor,
                                  subtextColor,
                                ),
                                const SizedBox(height: 6),
                                _infoRow(
                                  Icons.access_time,
                                  _formatDateTime(booking['showtime'] as Timestamp?),
                                  textColor,
                                  subtextColor,
                                ),
                                const SizedBox(height: 6),
                                _infoRow(
                                  Icons.event_seat,
                                  (booking['seatLabels'] as List<dynamic>?)?.join(', ') ?? '',
                                  textColor,
                                  subtextColor,
                                ),
                                const SizedBox(height: 12),

                                // Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tổng', style: TextStyle(color: subtextColor, fontSize: 14)),
                                    Text(
                                      _formatPrice(booking['totalPrice'] ?? 0),
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.qr_code_2, color: subtextColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text('Nhấn để xem mã QR', style: TextStyle(color: subtextColor, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    );
                  },
                ),
    );
  }

  bool _isShowtimePast(Timestamp? ts) {
    if (ts == null) return false;
    return ts.toDate().isBefore(DateTime.now());
  }

  Widget _infoRow(IconData icon, String text, Color textColor, Color subtextColor) {
    return Row(
      children: [
        Icon(icon, color: subtextColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: subtextColor, fontSize: 13)),
        ),
      ],
    );
  }

  void _showTicketQR(
    BuildContext context,
    Map<String, dynamic> booking,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color cardColor,
    Color borderColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Movie title
                Text(
                  booking['movieTitle'] ?? '',
                  style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  booking['bookingId'] ?? '',
                  style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Booking details
                _ticketDetailRow(Icons.location_on, booking['cinemaName'] ?? '', textColor, subtextColor),
                const SizedBox(height: 8),
                _ticketDetailRow(
                  Icons.meeting_room,
                  '${booking['hallName'] ?? ''} · ${booking['screenType'] ?? ''}',
                  textColor,
                  subtextColor,
                ),
                const SizedBox(height: 8),
                _ticketDetailRow(
                  Icons.access_time,
                  _formatShowtime(booking['showtime'] as Timestamp?),
                  textColor,
                  subtextColor,
                ),
                const SizedBox(height: 8),
                _ticketDetailRow(
                  Icons.event_seat,
                  (booking['seatLabels'] as List<dynamic>?)?.join(', ') ?? '',
                  textColor,
                  subtextColor,
                ),
                const SizedBox(height: 8),
                _ticketDetailRow(
                  Icons.payment,
                  _formatPrice(booking['totalPrice'] ?? 0),
                  textColor,
                  subtextColor,
                ),

                const SizedBox(height: 20),

                // Dashed divider
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
                const SizedBox(height: 20),

                // QR Code
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.qr_code_2, size: 120, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đưa mã này tại quầy vé',
                  style: TextStyle(color: subtextColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  booking['bookingId'] ?? '',
                  style: TextStyle(color: subtextColor.withOpacity(0.6), fontSize: 11),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatShowtime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m · ${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _ticketDetailRow(IconData icon, String text, Color textColor, Color subtextColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent.withOpacity(0.7), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: textColor, fontSize: 14)),
        ),
      ],
    );
  }
}