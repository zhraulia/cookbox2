import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/delivery_location.dart';

/// Service untuk menangani pencarian lokasi, reverse geocoding via OpenStreetMap Nominatim,
/// serta pengambilan posisi GPS pengguna via Geolocator.
class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const Duration _timeout = Duration(seconds: 10);
  static const Map<String, String> _headers = {
    'User-Agent': 'CookBox-App/1.0 (contact: support@cookbox.app)',
    'Accept': 'application/json',
  };

  /// Mencari tempat berdasarkan [query] menggunakan Nominatim API.
  Future<List<DeliveryLocation>> searchPlaces(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final uri = Uri.parse(
      '$_nominatimBaseUrl/search?q=${Uri.encodeQueryComponent(trimmedQuery)}&format=jsonv2&limit=5&countrycodes=id',
    );

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Gagal mencari tempat. Server mengembalikan kode ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];

      return decoded.map<DeliveryLocation>((item) {
        final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
        final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
        final address = item['display_name']?.toString() ?? 'Lokasi tidak dikenal';
        return DeliveryLocation(
          latitude: lat,
          longitude: lon,
          address: address,
        );
      }).toList();
    } catch (e) {
      if (e is Exception && e.toString().contains('Gagal mencari tempat')) {
        rethrow;
      }
      throw Exception('Gagal mencari tempat. Periksa koneksi internet.');
    }
  }

  /// Mengambil nama alamat dari koordinat [lat] dan [lng] via reverse geocoding Nominatim.
  Future<String> reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse(
      '$_nominatimBaseUrl/reverse?lat=$lat&lon=$lng&format=jsonv2',
    );

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat alamat. Server mengembalikan kode ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('display_name')) {
        return decoded['display_name'].toString();
      }

      return 'Lokasi: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    } catch (e) {
      if (e is Exception && e.toString().contains('Gagal memuat alamat')) {
        rethrow;
      }
      throw Exception('Gagal memuat alamat. Periksa koneksi internet.');
    }
  }

  /// Mengambil posisi GPS saat ini dengan validasi status layanan dan izin akses lokasi.
  /// Melempar [Exception] dengan pesan Bahasa Indonesia yang jelas jika gagal.
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Aktifkan layanan lokasi terlebih dahulu');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak, tidak bisa mengambil alamat otomatis',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      throw Exception('Gagal mendapatkan lokasi GPS: $e');
    }
  }
}
