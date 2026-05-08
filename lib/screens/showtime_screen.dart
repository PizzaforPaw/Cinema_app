import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../models/booking_model.dart';
import '../mock_data.dart';

class ShowtimeScreen extends StatefulWidget {
  final Movie movie;
  const ShowtimeScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<ShowtimeScreen> createState() => _ShowtimeScreenState();
}

class _ShowtimeScreenState extends State<ShowtimeScreen> {
  late List<Showtime> _allShowtimes;
  late List<DateTime> _availableDates;
  int _selectedDateIndex = 0;
  String? _selectedCinema;
  String? _selectedScreenType;

  @override
  void initState() {
    super.initState();
    _allShowtimes = generateMockShowtimes(widget.movie.id);
    _availableDates = _getUniqueDates();
  }

  List<DateTime> _getUniqueDates() {
    final dates = <DateTime>{};
    for (var st in _allShowtimes) {
      dates.add(DateTime(st.dateTime.year, st.dateTime.month, st.dateTime.day));
    }
    final sorted = dates.toList()..sort();
    return sorted;
  }

  List<Showtime> get _filteredShowtimes {
    final selectedDate = _availableDates[_selectedDateIndex];
    return _allShowtimes.where((st) {
      final sameDay = st.dateTime.year == selectedDate.year &&
          st.dateTime.month == selectedDate.month &&
          st.dateTime.day == selectedDate.day;
      if (!sameDay) return false;
      if (_selectedCinema != null && st.cinemaName != _selectedCinema) return false;
      if (_selectedScreenType != null && st.screenType != _selectedScreenType) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<String> get _screenTypes {
    final types = <String>{};
    for (var st in _allShowtimes) {
      types.add(st.screenType);
    }
    return types.toList()..sort();
  }

  List<String> get _cinemaNames {
    final names = <String>{};
    for (var st in _allShowtimes) {
      names.add(st.cinemaName);
    }
    return names.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final cardBg = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04);
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    final showtimesByCinema = <String, List<Showtime>>{};
    for (var st in _filteredShowtimes) {
      showtimesByCinema.putIfAbsent(st.cinemaName, () => []).add(st);
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
          widget.movie.title,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── DATE SELECTOR ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('Chọn ngày', style: TextStyle(color: subtextColor, fontSize: 14)),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableDates.length,
              itemBuilder: (context, index) {
                final date = _availableDates[index];
                final isSelected = index == _selectedDateIndex;
                final isToday = _isToday(date);
                final weekday = _weekdayName(date.weekday);
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.redAccent : cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.redAccent : borderColor,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday ? 'Hôm nay' : weekday,
                          style: TextStyle(
                            color: isSelected ? Colors.white : subtextColor,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? (isDark ? Colors.white : Colors.white) : textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Thg ${date.month}',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : subtextColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ─── CINEMA FILTER ───
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('Tất cả', _selectedCinema == null, () {
                  setState(() => _selectedCinema = null);
                }),
                ..._cinemaNames.map((name) {
                  final shortName = name.replaceAll('CGV ', '');
                  return _filterChip(shortName, _selectedCinema == name, () {
                    setState(() => _selectedCinema = name);
                  });
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── SCREEN TYPE FILTER ───
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('Tất cả', _selectedScreenType == null, () {
                  setState(() => _selectedScreenType = null);
                }),
                ..._screenTypes.map((type) {
                  return _filterChip(type, _selectedScreenType == type, () {
                    setState(() => _selectedScreenType = type);
                  });
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── SHOWTIME LIST ───
          Expanded(
            child: showtimesByCinema.isEmpty
                ? Center(
                    child: Text('Không có suất chiếu.', style: TextStyle(color: subtextColor)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: showtimesByCinema.length,
                    itemBuilder: (context, index) {
                      final cinema = showtimesByCinema.keys.elementAt(index);
                      final showtimes = showtimesByCinema[cinema]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cinema name
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  cinema,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Time slots
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: showtimes.map((st) {
                              final timeStr =
                                  '${st.dateTime.hour.toString().padLeft(2, '0')}:${st.dateTime.minute.toString().padLeft(2, '0')}';
                              final isPast = st.dateTime.isBefore(DateTime.now());

                              return GestureDetector(
                                onTap: isPast
                                    ? null
                                    : () {
                                        Navigator.pushNamed(
                                          context,
                                          '/seat-selection',
                                          arguments: {
                                            'movie': widget.movie,
                                            'showtime': st,
                                          },
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isPast
                                        ? isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)
                                        : isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isPast ? borderColor : borderColor,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          color: isPast ? subtextColor : textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        st.screenType,
                                        style: TextStyle(
                                          color: isPast
                                              ? (isDark ? Colors.white12 : Colors.black12)
                                              : (st.screenType == 'IMAX'
                                                  ? Colors.amber
                                                  : st.screenType == '4DX'
                                                      ? Colors.cyanAccent
                                                      : st.screenType == '3D'
                                                          ? Colors.lightBlueAccent
                                                          : subtextColor),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          if (index < showtimesByCinema.length - 1)
                            Divider(color: borderColor, height: 32),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBorder = isDark ? Colors.white12 : Colors.black12;
    final chipText = isDark ? Colors.white54 : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.redAccent : chipBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _weekdayName(int weekday) {
    const names = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return names[weekday];
  }
}