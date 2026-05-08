import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  static final _bookingsRef = FirebaseFirestore.instance.collection('bookings');

  /// Save a new booking to Firestore
  static Future<String?> saveBooking({
    required String movieTitle,
    required String cinemaName,
    required String hallName,
    required String screenType,
    required DateTime showtime,
    required List<String> seatLabels,
    required int totalPrice,
    required String bookingId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Chưa đăng nhập';

    try {
      await _bookingsRef.doc(bookingId).set({
        'userId': user.uid,
        'movieTitle': movieTitle,
        'cinemaName': cinemaName,
        'hallName': hallName,
        'screenType': screenType,
        'showtime': Timestamp.fromDate(showtime),
        'seatLabels': seatLabels,
        'totalPrice': totalPrice,
        'bookingId': bookingId,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Lỗi lưu vé: $e';
    }
  }

  /// Stream current user's bookings (newest first)
  static Stream<QuerySnapshot> streamMyBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _bookingsRef
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get current user's bookings as a one-time fetch
  static Future<List<Map<String, dynamic>>> getMyBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _bookingsRef
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // If index not built yet, try without orderBy
      try {
        final snapshot = await _bookingsRef
            .where('userId', isEqualTo: user.uid)
            .get();

        final list = snapshot.docs.map((doc) => doc.data()).toList();
        list.sort((a, b) {
          final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          return bTime.compareTo(aTime);
        });
        return list;
      } catch (e2) {
        return [];
      }
    }
  }
}