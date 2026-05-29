import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Cliente de Google Places API (New) — Nearby Search.
/// Devuelve gimnasios reales mapeados al mismo shape que usa la app.
class PlacesService {
  static const String _endpoint =
      'https://places.googleapis.com/v1/places:searchNearby';

  /// Busca gimnasios alrededor de [lat]/[lng] dentro de [radiusMeters].
  /// Lanza excepción si la API responde error (la home hace fallback).
  static Future<List<Map<String, dynamic>>> nearbyGyms({
    required double lat,
    required double lng,
    required double radiusMeters,
    int maxResults = 20,
  }) async {
    final body = jsonEncode({
      'includedTypes': ['gym', 'fitness_center'],
      'maxResultCount': maxResults,
      'rankPreference': 'DISTANCE',
      'locationRestriction': {
        'circle': {
          'center': {'latitude': lat, 'longitude': lng},
          // La API exige radio 0–50000 m.
          'radius': radiusMeters.clamp(1.0, 50000.0),
        },
      },
      'languageCode': 'es',
    });

    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': kGoogleApiKey,
            'X-Goog-FieldMask': [
              'places.id',
              'places.displayName',
              'places.formattedAddress',
              'places.shortFormattedAddress',
              'places.location',
              'places.rating',
              'places.userRatingCount',
              'places.currentOpeningHours.openNow',
              'places.priceLevel',
              'places.photos',
              'places.nationalPhoneNumber',
              'places.types',
              'places.addressComponents',
            ].join(','),
          },
          body: body,
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw Exception('Places API ${res.statusCode}: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final places = (json['places'] as List?) ?? const [];
    return places
        .map((p) => _mapPlace(p as Map<String, dynamic>))
        .toList(growable: true);
  }

  static Map<String, dynamic> _mapPlace(Map<String, dynamic> p) {
    final loc = (p['location'] as Map<String, dynamic>?) ?? const {};
    final price = _priceRange(p['priceLevel'] as String?);
    final photos = (p['photos'] as List?) ?? const [];
    final photoName =
        photos.isNotEmpty ? (photos.first as Map)['name'] as String? : null;

    return {
      'id': p['id'] as String? ?? '',
      'name': (p['displayName']?['text'] as String?) ?? 'Gimnasio',
      'district': _district(p),
      'address': (p['formattedAddress'] as String?) ??
          (p['shortFormattedAddress'] as String?) ??
          '',
      'distance': '—', // lo recalcula la home según GPS
      'rating': (p['rating'] as num?)?.toDouble() ?? 0.0,
      'reviewCount': (p['userRatingCount'] as num?)?.toInt() ?? 0,
      'isOpen': (p['currentOpeningHours']?['openNow'] as bool?) ?? true,
      'priceMin': price.$1,
      'priceMax': price.$2,
      'imageUrl': _photoUrl(photoName),
      'tags': _tags(p['types']),
      'phone': (p['nationalPhoneNumber'] as String?)?.replaceAll(
              RegExp(r'[^0-9]'), '') ??
          '',
      'lat': (loc['latitude'] as num?)?.toDouble() ?? 0.0,
      'lng': (loc['longitude'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // Locality / sublocality legible para el chip de distrito.
  static String _district(Map<String, dynamic> p) {
    final comps = (p['addressComponents'] as List?) ?? const [];
    String? pick(String type) {
      for (final c in comps) {
        final types = ((c as Map)['types'] as List?)?.cast<String>() ?? const [];
        if (types.contains(type)) return c['longText'] as String?;
      }
      return null;
    }

    return pick('sublocality_level_1') ??
        pick('locality') ??
        pick('administrative_area_level_2') ??
        '';
  }

  // priceLevel (New API) → rango estimado en soles. 0 = desconocido.
  static (int, int) _priceRange(String? level) {
    switch (level) {
      case 'PRICE_LEVEL_INEXPENSIVE':
        return (50, 90);
      case 'PRICE_LEVEL_MODERATE':
        return (90, 150);
      case 'PRICE_LEVEL_EXPENSIVE':
        return (150, 250);
      case 'PRICE_LEVEL_VERY_EXPENSIVE':
        return (250, 400);
      default:
        return (0, 0);
    }
  }

  static const Map<String, String> _typeLabels = {
    'gym': 'Gimnasio',
    'fitness_center': 'Fitness',
    'sports_complex': 'Deportes',
    'yoga_studio': 'Yoga',
    'spa': 'Spa',
    'swimming_pool': 'Piscina',
  };

  static List<String> _tags(dynamic types) {
    final list = (types as List?)?.cast<String>() ?? const [];
    final tags = <String>[];
    for (final t in list) {
      final label = _typeLabels[t];
      if (label != null && !tags.contains(label)) tags.add(label);
      if (tags.length >= 3) break;
    }
    return tags.isEmpty ? ['Gimnasio'] : tags;
  }

  static String _photoUrl(String? name) {
    if (name == null || name.isEmpty) {
      return 'https://picsum.photos/seed/gymradar/400/220';
    }
    return 'https://places.googleapis.com/v1/$name/media'
        '?maxWidthPx=600&key=$kGoogleApiKey';
  }
}
