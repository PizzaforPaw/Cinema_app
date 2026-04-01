class MovieNews {
  final String id;
  final String title;
  final String summary;
  final String imageUrl; // asset or network
  final String date;
  final String source;
  final String tag; // "Hot", "Review", "Upcoming", etc.

  MovieNews({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.date,
    this.source = '',
    this.tag = '',
  });
}