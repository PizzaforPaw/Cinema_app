import 'package:flutter/material.dart';
import '../services/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeProvider themeProvider;

  const SettingsScreen({Key? key, required this.themeProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDark;
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
          'Cài đặt',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── APPEARANCE ───
          _sectionLabel('Giao diện', textColor),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                // Theme toggle
                ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber : Colors.orange,
                  ),
                  title: Text('Chế độ tối', style: TextStyle(color: textColor, fontSize: 15)),
                  subtitle: Text(
                    isDark ? 'Đang bật' : 'Đang tắt',
                    style: TextStyle(color: subtextColor, fontSize: 12),
                  ),
                  trailing: Switch(
                    value: isDark,
                    activeColor: Colors.redAccent,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── GENERAL ───
          _sectionLabel('Chung', textColor),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _settingsTile(
                  icon: Icons.language,
                  iconColor: Colors.blue,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange,
                  title: 'Thông báo',
                  subtitle: 'Bật',
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── ABOUT ───
          _sectionLabel('Thông tin', textColor),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _settingsTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.redAccent,
                  title: 'Về ứng dụng',
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onTap: () => _showAboutDialog(context, isDark),
                ),
                Divider(height: 1, color: borderColor),
                _settingsTile(
                  icon: Icons.description_outlined,
                  iconColor: Colors.teal,
                  title: 'Điều khoản sử dụng',
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                _settingsTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.purple,
                  title: 'Chính sách bảo mật',
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                _settingsTile(
                  icon: Icons.star_outline,
                  iconColor: Colors.amber,
                  title: 'Đánh giá ứng dụng',
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── VERSION ───
          Center(
            child: Text(
              'Cinema App v1.0.0',
              style: TextStyle(color: subtextColor, fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Made with ❤️ in Vietnam',
              style: TextStyle(color: subtextColor, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color.withOpacity(0.6),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: subtextColor, fontSize: 12))
          : null,
      trailing: Icon(Icons.chevron_right, color: subtextColor, size: 20),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    final bgColor = isDark ? const Color(0xFF16213E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.movie_filter, color: Colors.redAccent, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'CINEMA',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(color: subtextColor, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Ứng dụng đặt vé xem phim trực tuyến. '
                'Dễ dàng tìm phim, chọn ghế và thanh toán nhanh chóng.',
                style: TextStyle(color: subtextColor, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '© 2026 Cinema App',
                style: TextStyle(color: subtextColor.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}