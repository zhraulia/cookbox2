/// Model data lokasi pengantaran yang dipilih oleh pengguna melalui peta atau GPS.
class DeliveryLocation {
  final double latitude;
  final double longitude;
  final String address;

  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  String toString() => 'DeliveryLocation(lat: $latitude, lng: $longitude, address: $address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          address == other.address;

  @override
  int get hashCode => Object.hash(latitude, longitude, address);
}
