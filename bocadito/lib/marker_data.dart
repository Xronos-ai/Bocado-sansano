import 'package:latlong2/latlong.dart';

class MarkerData {
  LatLng position = LatLng(-33.0353043, -71.5956004);
  String title = '';
  String description = '';

  MarkerData(
    {
    required this.position,
    required this.title,
    required this.description}
  );

}