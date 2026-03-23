import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/showtime_screen.dart';
import 'screens/seat_selection_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'models/movie_model.dart';
import 'models/booking_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CinemaApp());
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({Key? key}) : super(key: key);

  static const Color primaryRed = Color(0xFFC62828);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color accentGold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: ColorScheme.dark(
          primary: primaryRed,
          secondary: accentGold,
          surface: const Color(0xFF16213E),
        ),
        useMaterial3: true,
      ),

      // Home screen is always the entry — no forced login
      home: const HomeScreen(),

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());

          case '/admin':
            return MaterialPageRoute(builder: (_) => const AdminDashboard());

          case '/movie-detail':
            final movie = settings.arguments as Movie;
            return MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
            );

          case '/showtime':
            final movie = settings.arguments as Movie;
            return MaterialPageRoute(
              builder: (_) => ShowtimeScreen(movie: movie),
            );

          case '/seat-selection':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SeatSelectionScreen(
                movie: args['movie'] as Movie,
                showtime: args['showtime'] as Showtime,
              ),
            );

          case '/checkout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CheckoutScreen(
                movie: args['movie'] as Movie,
                showtime: args['showtime'] as Showtime,
                seats: args['seats'] as List<Seat>,
                totalPrice: args['totalPrice'] as int,
              ),
            );

          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}