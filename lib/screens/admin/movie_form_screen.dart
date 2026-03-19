import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie; // null = adding new, not null = editing

  const MovieFormScreen({Key? key, this.movie}) : super(key: key);

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get _isEditing => widget.movie != null;

  // Form controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _posterUrlController;
  late final TextEditingController _bannerUrlController;
  late final TextEditingController _trailerUrlController;
  late final TextEditingController _durationController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _directorController;
  late final TextEditingController _ratingController;
  late final TextEditingController _castController;
  late final TextEditingController _genreController;

  String _selectedAgeRating = 'P';
  String _selectedStatus = 'now_showing';

  final List<String> _ageRatings = ['P', '13', '16', '18', 'C'];
  final Map<String, String> _statusOptions = {
    'now_showing': 'Đang chiếu',
    'coming_soon': 'Sắp chiếu',
    'special': 'Đặc biệt',
  };

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    _titleController = TextEditingController(text: m?.title ?? '');
    _descriptionController = TextEditingController(text: m?.description ?? '');
    _posterUrlController = TextEditingController(text: m?.posterUrl ?? '');
    _bannerUrlController = TextEditingController(text: m?.bannerUrl ?? '');
    _trailerUrlController = TextEditingController(text: m?.trailerUrl ?? '');
    _durationController = TextEditingController(text: m?.duration ?? '');
    _releaseDateController = TextEditingController(text: m?.releaseDate ?? '');
    _directorController = TextEditingController(text: m?.director ?? '');
    _ratingController = TextEditingController(
      text: m != null && m.rating > 0 ? m.rating.toString() : '',
    );
    _castController = TextEditingController(text: m?.cast.join(', ') ?? '');
    _genreController = TextEditingController(text: m?.genre.join(', ') ?? '');

    if (m != null) {
      _selectedAgeRating = m.ageRating;
      _selectedStatus = m.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _posterUrlController.dispose();
    _bannerUrlController.dispose();
    _trailerUrlController.dispose();
    _durationController.dispose();
    _releaseDateController.dispose();
    _directorController.dispose();
    _ratingController.dispose();
    _castController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final movie = Movie(
      id: widget.movie?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      posterUrl: _posterUrlController.text.trim(),
      bannerUrl: _bannerUrlController.text.trim(),
      trailerUrl: _trailerUrlController.text.trim(),
      duration: _durationController.text.trim(),
      releaseDate: _releaseDateController.text.trim(),
      ageRating: _selectedAgeRating,
      director: _directorController.text.trim(),
      rating: double.tryParse(_ratingController.text) ?? 0.0,
      cast: _castController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      genre: _genreController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      status: _selectedStatus,
    );

    String? error;
    if (_isEditing) {
      error = await MovieService.updateMovie(widget.movie!.id, movie);
    } else {
      error = await MovieService.addMovie(movie);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Đã cập nhật phim!' : 'Đã thêm phim mới!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Sửa phim' : 'Thêm phim mới',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── POSTER PREVIEW ───
            if (_posterUrlController.text.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _posterUrlController.text,
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 180,
                      color: Colors.white10,
                      child: const Icon(Icons.broken_image, color: Colors.white24, size: 40),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // ─── BASIC INFO ───
            _sectionLabel('Thông tin cơ bản'),
            const SizedBox(height: 12),
            _buildField(
              controller: _titleController,
              label: 'Tên phim *',
              icon: Icons.movie,
              validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _descriptionController,
              label: 'Mô tả',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Status + Age Rating row
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Trạng thái',
                    value: _selectedStatus,
                    items: _statusOptions.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Giới hạn tuổi',
                    value: _selectedAgeRating,
                    items: _ageRatings
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAgeRating = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Duration + Release Date row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _durationController,
                    label: 'Thời lượng',
                    icon: Icons.access_time,
                    hint: '2 giờ 11 phút',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _releaseDateController,
                    label: 'Ngày chiếu',
                    icon: Icons.calendar_today,
                    hint: '10 Thg 2, 2026',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating + Director row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _ratingController,
                    label: 'Điểm (0-10)',
                    icon: Icons.star,
                    keyboardType: TextInputType.number,
                    hint: '8.5',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _directorController,
                    label: 'Đạo diễn',
                    icon: Icons.person,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── MEDIA ───
            _sectionLabel('Hình ảnh'),
            const SizedBox(height: 12),
            _buildField(
              controller: _posterUrlController,
              label: 'Poster URL *',
              icon: Icons.image,
              hint: 'https://...',
              validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
              onChanged: (_) => setState(() {}), // Refresh preview
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _bannerUrlController,
              label: 'Banner URL',
              icon: Icons.panorama,
              hint: 'https://...',
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _trailerUrlController,
              label: 'Trailer URL',
              icon: Icons.play_circle,
              hint: 'https://youtube.com/...',
            ),

            const SizedBox(height: 24),

            // ─── PEOPLE ───
            _sectionLabel('Diễn viên & Thể loại'),
            const SizedBox(height: 12),
            _buildField(
              controller: _castController,
              label: 'Diễn viên (cách nhau bởi dấu phẩy)',
              icon: Icons.people,
              hint: 'Ngô Thanh Vân, Trấn Thành',
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _genreController,
              label: 'Thể loại (cách nhau bởi dấu phẩy)',
              icon: Icons.category,
              hint: 'Hành động, Hài hước',
            ),

            const SizedBox(height: 32),

            // ─── SAVE BUTTON ───
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Cập nhật' : 'Thêm phim',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── HELPER WIDGETS ───

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        hintStyle: const TextStyle(color: Colors.white12, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white24, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF16213E),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}