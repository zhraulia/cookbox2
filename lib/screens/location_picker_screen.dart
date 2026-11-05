import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/location_service.dart';
import '../models/delivery_location.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';

/// Screen untuk memilih lokasi pengantaran menggunakan OpenStreetMap dan geolocator/Nominatim.
class LocationPickerScreen extends StatefulWidget {
  final DeliveryLocation? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Titik cadangan default jika lokasi GPS tidak tersedia (-0.9150, 100.4600)
  static const LatLng _fallbackLocation = LatLng(-0.9150, 100.4600);

  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _currentCenter;
  String _currentAddress = 'Mencari alamat...';
  bool _isFetchingAddress = false;
  bool _isLoadingInitialLocation = true;

  // Search state
  Timer? _searchDebounceTimer;
  Timer? _reverseGeocodeDebounceTimer;
  int _searchRequestId = 0;
  bool _isSearching = false;
  bool _showSearchResults = false;
  List<DeliveryLocation> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _initInitialPosition();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _reverseGeocodeDebounceTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Inisialisasi posisi awal peta berdasarkan initialLocation atau GPS saat ini.
  Future<void> _initInitialPosition() async {
    if (widget.initialLocation != null) {
      _currentCenter = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _currentAddress = widget.initialLocation!.address;
      setState(() => _isLoadingInitialLocation = false);
      return;
    }

    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      _currentCenter = LatLng(position.latitude, position.longitude);
      setState(() => _isLoadingInitialLocation = false);
      _reverseGeocodeCenter(_currentCenter);
    } catch (e) {
      if (!mounted) return;
      _currentCenter = _fallbackLocation;
      setState(() => _isLoadingInitialLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lokasi GPS tidak dapat diakses ($e). Menggunakan lokasi default.',
          ),
        ),
      );
      _reverseGeocodeCenter(_currentCenter);
    }
  }

  /// Memindahkan peta ke posisi GPS pengguna saat ini.
  Future<void> _moveToCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      final target = LatLng(position.latitude, position.longitude);
      _mapController.move(target, 16.0);
      _currentCenter = target;
      _triggerReverseGeocodeDebounced(target);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi GPS: $e')),
      );
    }
  }

  /// Menangani perubahan teks pencarian dengan debounce ~700ms.
  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _showSearchResults = true;
      _isSearching = true;
    });

    final currentId = ++_searchRequestId;
    _searchDebounceTimer = Timer(const Duration(milliseconds: 700), () async {
      try {
        final results = await _locationService.searchPlaces(trimmed);
        if (!mounted || currentId != _searchRequestId) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted || currentId != _searchRequestId) return;
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  /// Menangani pemilihan hasil pencarian.
  void _onSelectSearchResult(DeliveryLocation location) {
    FocusScope.of(context).unfocus();
    final target = LatLng(location.latitude, location.longitude);
    _mapController.move(target, 16.0);

    setState(() {
      _currentCenter = target;
      _currentAddress = location.address;
      _isFetchingAddress = false;
      _showSearchResults = false;
      _searchResults = [];
      _searchController.text = location.address;
    });
  }

  /// Debounce untuk reverse geocode saat peta digeser oleh pengguna.
  void _triggerReverseGeocodeDebounced(LatLng center) {
    _reverseGeocodeDebounceTimer?.cancel();
    setState(() {
      _isFetchingAddress = true;
      _currentAddress = 'Mencari alamat...';
    });

    _reverseGeocodeDebounceTimer = Timer(
      const Duration(milliseconds: 700),
      () => _reverseGeocodeCenter(center),
    );
  }

  /// Mengambil nama alamat dari koordinat tengah peta.
  Future<void> _reverseGeocodeCenter(LatLng center) async {
    try {
      final address = await _locationService.reverseGeocode(
        center.latitude,
        center.longitude,
      );
      if (!mounted) return;
      setState(() {
        _currentAddress = address;
        _isFetchingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Cadangan: jika gagal, tampilkan koordinat dan tetap izinkan lokasi dipilih
      setState(() {
        _currentAddress =
            'Lokasi: ${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}';
        _isFetchingAddress = false;
      });
    }
  }

  /// Konfirmasi pemilihan lokasi dan kembali ke screen checkout.
  void _confirmSelection() {
    final selectedLocation = DeliveryLocation(
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      address: _currentAddress,
    );
    Navigator.pop(context, selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Pengantaran'),
        backgroundColor: AppColors.surface,
      ),
      body: _isLoadingInitialLocation
          ? const Center(child: LoadingView(message: 'Menyiapkan peta...'))
          : Stack(
              children: [
                // 1. Layer Peta OpenStreetMap
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 16.0,
                    onPositionChanged: (camera, hasGesture) {
                      _currentCenter = camera.center;
                      if (hasGesture) {
                        _triggerReverseGeocodeDebounced(camera.center);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.cookbox',
                    ),
                  ],
                ),

                // 2. Pin lokasi tetap di tengah layar (ujung pin berada tepat di tengah)
                Center(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 38),
                      child: Icon(
                        Icons.location_pin,
                        size: 46,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // 3. Kotak Pencarian di bagian atas
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radius),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Cari alamat atau nama tempat...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.page,
                                vertical: AppSpacing.fieldVertical,
                              ),
                            ),
                          ),
                        ),

                        // Daftar Hasil Pencarian
                        if (_showSearchResults)
                          Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(top: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radius),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 220),
                              child: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(AppSpacing.page),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : _searchResults.isEmpty
                                      ? const Padding(
                                          padding:
                                              EdgeInsets.all(AppSpacing.page),
                                          child: EmptyView(
                                            message: 'Tempat tidak ditemukan',
                                            icon: Icons.search_off_rounded,
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemCount: _searchResults.length,
                                          separatorBuilder: (_, _) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final item = _searchResults[index];
                                            return ListTile(
                                              dense: true,
                                              leading: const Icon(
                                                Icons.location_on_outlined,
                                                color: AppColors.primary,
                                              ),
                                              title: Text(
                                                item.address,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.body,
                                              ),
                                              onTap: () =>
                                                  _onSelectSearchResult(item),
                                            );
                                          },
                                        ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 4. Tombol "Lokasi Saya" (FAB di atas kartu bawah)
                Positioned(
                  right: AppSpacing.page,
                  bottom: 160,
                  child: FloatingActionButton.small(
                    heroTag: 'my_location_btn',
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    onPressed: _moveToCurrentLocation,
                    tooltip: 'Lokasi Saya',
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // 5. Kartu Informasi Alamat dan Tombol Konfirmasi di Bagian Bawah
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.section),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Expanded(
                                child: Text(
                                  _isFetchingAddress
                                      ? 'Mencari alamat...'
                                      : _currentAddress,
                                  style: AppTextStyles.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.page),
                          FilledButton(
                            onPressed: _isFetchingAddress
                                ? null
                                : _confirmSelection,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size.fromHeight(
                                AppSpacing.buttonHeight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radius),
                              ),
                            ),
                            child: const Text('Pilih Lokasi Ini'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
