import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // ── Usuario actual ──────────────────────────────────────────────
  String _userUid = '';
  String get userUid => _userUid;
  set userUid(String val) {
    _userUid = val;
    notifyListeners();
  }

  String _userEmail = '';
  String get userEmail => _userEmail;
  set userEmail(String val) {
    _userEmail = val;
    notifyListeners();
  }

  String _userName = '';
  String get userName => _userName;
  set userName(String val) {
    _userName = val;
    notifyListeners();
  }

  // ── Ubicación ───────────────────────────────────────────────────
  double _userLat = -12.0464; // Lima, Perú por defecto
  double get userLat => _userLat;
  set userLat(double val) {
    _userLat = val;
    notifyListeners();
  }

  double _userLng = -77.0428;
  double get userLng => _userLng;
  set userLng(double val) {
    _userLng = val;
    notifyListeners();
  }

  String _userDistrict = 'Lima';
  String get userDistrict => _userDistrict;
  set userDistrict(String val) {
    _userDistrict = val;
    notifyListeners();
  }

  // ── Gyms ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _nearbyGyms = [];
  List<Map<String, dynamic>> get nearbyGyms => _nearbyGyms;
  set nearbyGyms(List<Map<String, dynamic>> val) {
    _nearbyGyms = val;
    notifyListeners();
  }

  // ── Filtros ─────────────────────────────────────────────────────
  String _activeFilter = 'Todos';
  String get activeFilter => _activeFilter;
  set activeFilter(String val) {
    _activeFilter = val;
    notifyListeners();
  }

  double _maxDistanceKm = 5.0;
  double get maxDistanceKm => _maxDistanceKm;
  set maxDistanceKm(double val) {
    _maxDistanceKm = val;
    notifyListeners();
  }

  // ── Sesión ──────────────────────────────────────────────────────
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool val) {
    _isLoggedIn = val;
    notifyListeners();
  }

  bool _isGuest = false;
  bool get isGuest => _isGuest;
  set isGuest(bool val) {
    _isGuest = val;
    notifyListeners();
  }

  void logout() {
    _userUid = '';
    _userEmail = '';
    _userName = '';
    _isLoggedIn = false;
    _nearbyGyms = [];
    notifyListeners();
  }
}
