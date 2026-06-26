import 'package:geolocator/geolocator.dart';

import '../errors/exceptions.dart';

/// Coordenada geográfica simple (sin acoplar la UI a la clase `Position`).
class Coordenada {
  const Coordenada({required this.latitud, required this.longitud});
  final double latitud;
  final double longitud;
}

/// Servicio de geolocalización (GPS) centralizado en `core/services`.
///
/// Gestiona el permiso de ubicación y obtiene la posición actual. Lanza
/// [AppException] con un mensaje en español cuando no se puede obtener (GPS
/// apagado, permiso denegado), para que la UI lo muestre.
class LocationService {
  const LocationService();

  Future<Coordenada> ubicacionActual() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      throw const AppException(
        'Activa la ubicación (GPS) de tu dispositivo para continuar.',
      );
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw const AppException(
        'Necesitamos tu ubicación para registrar el siniestro.',
      );
    }
    if (permiso == LocationPermission.deniedForever) {
      throw const AppException(
        'El permiso de ubicación está bloqueado. Actívalo en los ajustes del sistema.',
      );
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return Coordenada(latitud: pos.latitude, longitud: pos.longitude);
  }
}
