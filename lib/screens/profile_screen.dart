import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dIsDark = Theme.of(ctx).brightness == Brightness.dark;
        final dTextColor = dIsDark ? Colors.white : const Color(0xFF1A1A2E);
        final dSubColor = dIsDark ? Colors.white70 : Colors.black54;
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Đăng xuất', style: TextStyle(color: dTextColor)),
          content: Text(
            'Bạn có chắc muốn đăng xuất?',
            style: TextStyle(color: dSubColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Hủy', style: TextStyle(color: dSubColor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AuthService.logout();
      // StreamBuilder in main.dart will handle navigation back to login
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tài khoản',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white24))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ─── AVATAR + NAME ───
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                        child: Text(
                          (_profile?['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _profile?['name'] ?? 'Người dùng',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(color: subtextColor, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_profile?['role'] == 'admin')
                              ? Colors.amber.withOpacity(0.15)
                              : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (_profile?['role'] == 'admin') ? 'Admin' : 'Thành viên',
                          style: TextStyle(
                            color: (_profile?['role'] == 'admin')
                                ? Colors.amber
                                : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ─── MENU ITEMS ───
                _menuItem(
                  icon: Icons.history,
                  title: 'Lịch sử đặt vé',
                  subtitle: 'Xem các vé đã đặt',
                  onTap: () {
                    Navigator.pushNamed(context, '/booking-history');
                  },
                ),
                _menuItem(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt',
                  subtitle: 'Giao diện, thông tin ứng dụng',
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),

                // Admin-only menu
                if (_profile?['role'] == 'admin')
                  _menuItem(
                    icon: Icons.admin_panel_settings,
                    title: 'Admin Dashboard',
                    subtitle: 'Quản lý phim và suất chiếu',
                    iconColor: Colors.amber,
                    onTap: () {
                      Navigator.pushNamed(context, '/admin');
                    },
                  ),

                const SizedBox(height: 16),

                // ─── LOGOUT ───
                _menuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  subtitle: '',
                  iconColor: Colors.redAccent,
                  titleColor: Colors.redAccent,
                  onTap: _handleLogout,
                ),
              ],
            ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = iconColor ?? (isDark ? Colors.white54 : Colors.black54);
    final defaultTitleColor = titleColor ?? (isDark ? Colors.white : const Color(0xFF1A1A2E));
    final subtitleColor = isDark ? Colors.white30 : Colors.black38;
    final trailingColor = isDark ? Colors.white24 : Colors.black26;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: defaultIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: defaultIconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(color: defaultTitleColor, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12))
            : null,
        trailing: Icon(Icons.chevron_right, color: trailingColor, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}