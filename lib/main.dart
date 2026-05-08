import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/showtime_screen.dart';
import 'screens/seat_selection_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/booking_history_screen.dart';
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

class CinemaApp extends StatefulWidget {
  const CinemaApp({Key? key}) : super(key: key);

  @override
  State<CinemaApp> createState() => _CinemaAppState();
}

class _CinemaAppState extends State<CinemaApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() => setState(() {}));
    _themeProvider.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: _themeProvider.themeMode,

      home: const SplashScreen(),

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());

          case '/settings':
            return MaterialPageRoute(
              builder: (_) => SettingsScreen(themeProvider: _themeProvider),
            );

          case '/admin':
            return MaterialPageRoute(builder: (_) => const AdminDashboard());

          case '/booking-history':
            return MaterialPageRoute(builder: (_) => const BookingHistoryScreen());

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