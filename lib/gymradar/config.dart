import 'secrets.dart';

/// Configuración central de GymRadar.
///
/// La key real vive en `lib/gymradar/secrets.dart` (NO versionado).
/// Para clonar el proyecto: copia `secrets.example.dart` → `secrets.dart`.
///
/// Se puede sobreescribir en build con:
///   flutter run --dart-define=GOOGLE_API_KEY=AIza...
///
/// IMPORTANTE para Places:
///  1. En Google Cloud Console habilita **Places API (New)**.
///  2. Restringe la key (Android package+SHA-1 / iOS bundle, y por API)
///     y configura alertas de presupuesto para evitar abuso.
const String kGoogleApiKey = String.fromEnvironment(
  'GOOGLE_API_KEY',
  defaultValue: kGoogleApiKeySecret,
);
