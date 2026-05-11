import '/flutter_flow/flutter_flow_util.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  // ── Estado ──────────────────────────────────────────────────────
  bool isLoading = true;
  bool showMap = true; // toggle mapa / lista

  // ── Distrito seleccionado ───────────────────────────────────────
  String selectedDistrict = 'Todos';

  final List<String> districts = [
    'Todos',
    'Miraflores',
    'San Isidro',
    'Surco',
    'Barranco',
    'La Molina',
    'San Borja',
    'Lince',
    'Jesús María',
    'Pueblo Libre',
    'Magdalena',
    'San Miguel',
    'Callao',
    'Los Olivos',
    'SJL',
    'Ate',
    'Villa El Salvador',
  ];

  // ── Busqueda ────────────────────────────────────────────────────
  TextEditingController? searchController;
  FocusNode? searchFocusNode;
  String searchQuery = '';

  // ── Gyms ────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> gymsData = [
    {
      'id': '1',
      'name': 'Gold\'s Gym Miraflores',
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

  // ── Filtrado combinado (distrito + búsqueda) ─────────────────────
  List<Map<String, dynamic>> get filteredGyms {
    var list = List<Map<String, dynamic>>.from(gymsData);

    // Filtro por distrito
    if (selectedDistrict != 'Todos') {
      list = list
          .where((g) => g['district'] == selectedDistrict)
          .toList();
    }

    // Filtro por búsqueda
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((g) {
        final name = (g['name'] as String).toLowerCase();
        final addr = (g['address'] as String).toLowerCase();
        final dist = (g['district'] as String).toLowerCase();
        return name.contains(q) || addr.contains(q) || dist.contains(q);
      }).toList();
    }

    return list;
  }

  @override
  void initState(BuildContext context) {
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    searchController?.dispose();
    searchFocusNode?.dispose();
  }
}
