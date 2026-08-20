import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarOption {
  final String id;
  final String emoji;
  final List<Color> gradient;

  const AvatarOption({required this.id, required this.emoji, required this.gradient});
}

class AvatarService extends ChangeNotifier {
  static const _prefKey = 'avatar_type';
  static const _customPathKey = 'avatar_custom_path';

  static const List<AvatarOption> defaults = [
    AvatarOption(id: 'rocket', emoji: '🚀', gradient: [Color(0xFF007AFF), Color(0xFF5856D6)]),
    AvatarOption(id: 'star', emoji: '⭐', gradient: [Color(0xFFFF9500), Color(0xFFFF2D55)]),
    AvatarOption(id: 'fire', emoji: '🔥', gradient: [Color(0xFFFF3B30), Color(0xFFFF9500)]),
    AvatarOption(id: 'diamond', emoji: '💎', gradient: [Color(0xFF5AC8FA), Color(0xFF007AFF)]),
    AvatarOption(id: 'crown', emoji: '👑', gradient: [Color(0xFFFFD60A), Color(0xFFFF9500)]),
    AvatarOption(id: 'heart', emoji: '❤️', gradient: [Color(0xFFFF2D55), Color(0xFFAF52DE)]),
    AvatarOption(id: 'brain', emoji: '🧠', gradient: [Color(0xFFAF52DE), Color(0xFF5856D6)]),
    AvatarOption(id: 'money', emoji: '💰', gradient: [Color(0xFF34C759), Color(0xFF00C7BE)]),
    AvatarOption(id: 'chart', emoji: '📊', gradient: [Color(0xFF00C7BE), Color(0xFF5AC8FA)]),
    AvatarOption(id: 'gem', emoji: '✨', gradient: [Color(0xFF5856D6), Color(0xFFAF52DE)]),
    AvatarOption(id: 'sun', emoji: '☀️', gradient: [Color(0xFFFFD60A), Color(0xFFFF9500)]),
    AvatarOption(id: 'wave', emoji: '🌊', gradient: [Color(0xFF007AFF), Color(0xFF00C7BE)]),
  ];

  String _selectedId = 'rocket';
  String? _customPath;

  String _previewSelectedId = 'rocket';
  String? _previewCustomPath;

  String get selectedId => _selectedId;
  File? get customAvatar => _customPath != null ? File(_customPath!) : null;
  bool get isCustom => _customPath != null;

  String get previewSelectedId => _previewSelectedId;
  bool get isPreviewCustom => _previewCustomPath != null;

  bool get hasUnsavedChanges => _previewSelectedId != _selectedId || _previewCustomPath != _customPath;

  AvatarOption get selectedDefault => defaults.firstWhere((a) => a.id == _selectedId, orElse: () => defaults.first);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedId = prefs.getString(_prefKey) ?? 'rocket';
    _customPath = prefs.getString(_customPathKey);
    if (_customPath != null && !File(_customPath!).existsSync()) {
      _customPath = null;
      await prefs.remove(_customPathKey);
    }
    _previewSelectedId = _selectedId;
    _previewCustomPath = _customPath;
    notifyListeners();
  }

  void previewDefault(String id) {
    _previewSelectedId = id;
    _previewCustomPath = null;
    notifyListeners();
  }

  void previewCustomImage(String path) {
    _previewCustomPath = path;
    notifyListeners();
  }

  void discardPreview() {
    _previewSelectedId = _selectedId;
    _previewCustomPath = _customPath;
    notifyListeners();
  }

  Future<void> confirmChanges() async {
    _selectedId = _previewSelectedId;
    _customPath = _previewCustomPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _selectedId);
    if (_customPath != null) {
      await prefs.setString(_customPathKey, _customPath!);
    } else {
      await prefs.remove(_customPathKey);
    }
    notifyListeners();
  }

  Future<void> selectDefault(String id) async {
    _selectedId = id;
    _customPath = null;
    _previewSelectedId = id;
    _previewCustomPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, id);
    await prefs.remove(_customPathKey);
    notifyListeners();
  }

  Widget buildAvatar({double radius = 22, required bool isDark}) {
    if (_customPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        backgroundImage: FileImage(File(_customPath!)),
      );
    }
    final opt = selectedDefault;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: opt.gradient,
          ),
          boxShadow: [
            BoxShadow(color: opt.gradient.first.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(child: Text(opt.emoji, style: TextStyle(fontSize: radius * 0.8))),
      ),
    );
  }

  Widget buildPreviewAvatar({double radius = 22, required bool isDark}) {
    if (_previewCustomPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        backgroundImage: FileImage(File(_previewCustomPath!)),
      );
    }
    final opt = defaults.firstWhere((a) => a.id == _previewSelectedId, orElse: () => defaults.first);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: opt.gradient,
          ),
          boxShadow: [
            BoxShadow(color: opt.gradient.first.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(child: Text(opt.emoji, style: TextStyle(fontSize: radius * 0.8))),
      ),
    );
  }
}
