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

  Future initializePersistedState() async {}

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
  double _userLat = -12.0464;
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

  // ── Gyms (catálogo compartido) ──────────────────────────────────
  final List<Map<String, dynamic>> _allGyms = [
    {
      'id': '1',
      'name': "Gold's Gym Miraflores",
      'district': 'Miraflores',
      'address': 'Av. Larco 1234, Miraflores',
      'distance': '0.4 km',
      'rating': 4.8,
      'reviewCount': 312,
      'isOpen': true,
      'priceMin': 120,
      'priceMax': 180,
      'imageUrl': 'https://picsum.photos/seed/gym1/400/220',
      'tags': ['Pesas', 'Cardio', 'Spinning'],
      'phone': '51999888777',
      'lat': -12.1191,
      'lng': -77.0292,
    },
    {
      'id': '2',
      'name': 'SmartFit San Isidro',
      'district': 'San Isidro',
      'address': 'Av. Javier Prado 890, San Isidro',
      'distance': '1.2 km',
      'rating': 4.5,
      'reviewCount': 189,
      'isOpen': true,
      'priceMin': 89,
      'priceMax': 140,
      'imageUrl': 'https://picsum.photos/seed/gym2/400/220',
      'tags': ['24 horas', 'Funcional', 'Yoga'],
      'phone': '51998777666',
      'lat': -12.0966,
      'lng': -77.0353,
    },
    {
      'id': '3',
      'name': 'Bodytech Surco',
      'district': 'Surco',
      'address': 'Av. Primavera 456, Surco',
      'distance': '2.8 km',
      'rating': 4.6,
      'reviewCount': 247,
      'isOpen': false,
      'priceMin': 100,
      'priceMax': 160,
      'imageUrl': 'https://picsum.photos/seed/gym3/400/220',
      'tags': ['Piscina', 'Sauna', 'Crossfit'],
      'phone': '51997666555',
      'lat': -12.1307,
      'lng': -77.0034,
    },
    {
      'id': '4',
      'name': 'Power Gym Barranco',
      'district': 'Barranco',
      'address': 'Av. Grau 321, Barranco',
      'distance': '1.9 km',
      'rating': 4.2,
      'reviewCount': 78,
      'isOpen': true,
      'priceMin': 70,
      'priceMax': 110,
      'imageUrl': 'https://picsum.photos/seed/gym5/400/220',
      'tags': ['Económico', 'Boxeo', 'Pesas'],
      'phone': '51996555444',
      'lat': -12.1451,
      'lng': -77.0215,
    },
    {
      'id': '5',
      'name': 'Mega Gym La Molina',
      'district': 'La Molina',
      'address': 'Av. La Molina 789, La Molina',
      'distance': '4.1 km',
      'rating': 4.3,
      'reviewCount': 94,
      'isOpen': true,
      'priceMin': 60,
      'priceMax': 100,
      'imageUrl': 'https://picsum.photos/seed/gym4/400/220',
      'tags': ['Económico', 'Pesas', 'Cardio'],
      'phone': '51995444333',
      'lat': -12.0839,
      'lng': -76.9324,
    },
    {
      'id': '6',
      'name': 'FitZone San Borja',
      'district': 'San Borja',
      'address': 'Av. San Luis 2020, San Borja',
      'distance': '2.3 km',
      'rating': 4.7,
      'reviewCount': 156,
      'isOpen': true,
      'priceMin': 95,
      'priceMax': 150,
      'imageUrl': 'https://picsum.photos/seed/gym6/400/220',
      'tags': ['Premium', 'Pilates', 'Funcional'],
      'phone': '51994333222',
      'lat': -12.1050,
      'lng': -76.9980,
    },
  ];
  List<Map<String, dynamic>> get allGyms => _allGyms;

  Map<String, dynamic>? gymById(String id) {
    try {
      return _allGyms.firstWhere((g) => g['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // ── Comparación (máx 2) ─────────────────────────────────────────
  final List<String> _compareIds = [];
  List<String> get compareIds => List.unmodifiable(_compareIds);
  List<Map<String, dynamic>> get compareGyms =>
      _compareIds.map(gymById).whereType<Map<String, dynamic>>().toList();

  bool isInCompare(String id) => _compareIds.contains(id);

  /// Agrega gym a comparación. Si ya hay 2, reemplaza el más antiguo.
  void addToCompare(String id) {
    if (_compareIds.contains(id)) return;
    if (_compareIds.length >= 2) {
      _compareIds.removeAt(0);
    }
    _compareIds.add(id);
    notifyListeners();
  }

  void removeFromCompare(String id) {
    _compareIds.remove(id);
    notifyListeners();
  }

  void clearCompare() {
    _compareIds.clear();
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
    _isGuest = false;
    _compareIds.clear();
    notifyListeners();
  }
}
