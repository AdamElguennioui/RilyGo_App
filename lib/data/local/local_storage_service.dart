import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/mission.dart';
import '../../models/user.dart';

/// Single source of truth for local persistence.
/// All writes are fire-and-forget; reads return null if nothing is stored.
/// Replace internals with an API client when the backend is ready.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  // Storage keys
  static const _kUser      = 'rily_user';
  static const _kMissions  = 'rily_missions';
  static const _kSettings  = 'rily_settings';

  /// Must be called once before any read/write — typically in main().
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get _ready => _prefs != null;

  // ── User ─────────────────────────────────────────────────────────────────

  Future<void> saveUser(User? user) async {
    if (!_ready) return;
    if (user == null) {
      await _prefs!.remove(_kUser);
    } else {
      await _prefs!.setString(_kUser, jsonEncode(user.toJson()));
    }
  }

  User? loadUser() {
    if (!_ready) return null;
    final raw = _prefs!.getString(_kUser);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Missions ─────────────────────────────────────────────────────────────

  Future<void> saveMissions(List<Mission> missions) async {
    if (!_ready) return;
    await _prefs!.setString(
      _kMissions,
      jsonEncode(missions.map((m) => m.toJson()).toList()),
    );
  }

  List<Mission>? loadMissions() {
    if (!_ready) return null;
    final raw = _prefs!.getString(_kMissions);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Mission.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Settings ─────────────────────────────────────────────────────────────

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    if (!_ready) return;
    await _prefs!.setString(_kSettings, jsonEncode(settings));
  }

  Map<String, dynamic>? loadSettings() {
    if (!_ready) return null;
    final raw = _prefs!.getString(_kSettings);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  /// Removes only the authenticated session (user token).
  Future<void> clearSession() async {
    if (!_ready) return;
    await _prefs!.remove(_kUser);
  }

  /// Wipes all stored data (logout + reset).
  Future<void> clearAll() async {
    if (!_ready) return;
    await _prefs!.clear();
  }
}
