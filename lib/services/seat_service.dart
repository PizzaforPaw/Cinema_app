import 'package:cloud_firestore/cloud_firestore.dart';

class SeatService {
  static final _ref = FirebaseFirestore.instance.collection('showtime_seats');

  /// Stream booked seats for a showtime (real-time updates)
  static Stream<List<String>> streamBookedSeats(String showtimeId) {
    return _ref.doc(showtimeId).snapshots().map((doc) {
      if (!doc.exists) return <String>[];
      final data = doc.data();
      if (data == null) return <String>[];
      return List<String>.from(data['bookedSeats'] ?? []);
    });
  }

  /// Get booked seats once (for initial load)
  static Future<List<String>> getBookedSeats(String showtimeId) async {
    try {
      final doc = await _ref.doc(showtimeId).get();
      if (!doc.exists) return [];
      return List<String>.from(doc.data()?['bookedSeats'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// Book seats using a transaction to prevent double-booking.
  /// Returns null on success, or an error message on failure.
  static Future<String?> bookSeats({
    required String showtimeId,
    required List<String> seatLabels,
  }) async {
    try {
      final docRef = _ref.doc(showtimeId);

      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        List<String> currentBooked = [];
        if (snapshot.exists) {
          currentBooked = List<String>.from(snapshot.data()?['bookedSeats'] ?? []);
        }

        // Check if any requested seats are already booked
        final conflicts = seatLabels.where((s) => currentBooked.contains(s)).toList();
        if (conflicts.isNotEmpty) {
          return 'Ghế ${conflicts.join(", ")} đã được đặt bởi người khác!';
        }

        // All clear — book the seats
        final updatedSeats = [...currentBooked, ...seatLabels];

        if (snapshot.exists) {
          transaction.update(docRef, {'bookedSeats': updatedSeats});
        } else {
          transaction.set(docRef, {'bookedSeats': updatedSeats});
        }

        return null; // success
      });
    } catch (e) {
      return 'Lỗi đặt ghế: $e';
    }
  }
}