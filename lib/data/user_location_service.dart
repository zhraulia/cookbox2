import 'package:geolocator/geolocator.dart';

/// Posisi pengguna lewat GPS dan jarak ke sebuah titik, khusus untuk M4.
class UserLocationService {
  /// Melempar Exception berisi pesan yang aman ditampilkan jika gagal.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi mati. Aktifkan lokasi lalu coba lagi.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak. Izinkan lokasi untuk melihat jarak.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Ubah izin di pengaturan perangkat.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Jarak lurus antara dua titik dalam meter.
  double distanceInMeters(
    double fromLatitude,
    double fromLongitude,
    double toLatitude,
    double toLongitude,
  ) {
    return Geolocator.distanceBetween(
      fromLatitude,
      fromLongitude,
      toLatitude,
      toLongitude,
    );
  }
}

