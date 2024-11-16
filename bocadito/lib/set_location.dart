import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const map_box_key = 'pk.eyJ1IjoieHJvbm9zIiwiYSI6ImNtM2djbGoybTAzMnAycnBwb2JieGwxdDEifQ.NsjB1IYwQr72hemnn1ji_A';

class SetLocation extends StatefulWidget {
  final double lati;
  final double longi;

  const SetLocation({
    Key ? key,
    this.lati = -33.0353043,
    this.longi = -71.5956004,
  });

  @override
  _SetLocationState createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  LatLng? _draggedPosition;
  List<double> latlon = [-33.0353043,-71.5956004];
  bool isTaped = false;

  @override
  void initState() {
    super.initState();
    _draggedPosition = LatLng(widget.lati, widget.longi);
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.lati, widget.longi),
              minZoom: 5,
              maxZoom: 20,
              initialZoom: 18,
              onTap: (tapPosition, LatLng){
                setState(() {
                  _selectedPosition = LatLng;
                  _draggedPosition = _selectedPosition;
                  isTaped = true;
                });
              }
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: const {'accessToken': map_box_key, 'id': 'mapbox/dark-v11'},
              ),
              
              MarkerLayer(
                markers: [
                  Marker(
                    point: _draggedPosition!, 
                    width: 80,
                    height: 80,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.cyanAccent,
                      size: 30,
                    ),
                  )
                ],
              ),
            ],
            ),
            // Texto de ayuda
            Positioned(
              top: 40,
              left: 15,
              right: 15,
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.all(10), // Espaciado dentro del contenedor
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(104, 0, 0, 0), // Color de fondo
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(172, 223, 64, 251), // Borde alrededor del contenedor
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Toca en la pantalla dónde estará ubicada tu tienda. Luego selecciona "Guardar ubicación".',
                        style: TextStyle(
                          color: Colors.white, // Color del texto
                          fontSize: 14,
                        ),
                      ),
                    )

                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 40,
              left: 40,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: GestureDetector(
                      onTap: () {
                        if (isTaped) {
                          latlon[0] = _draggedPosition!.latitude;
                          latlon[1] = _draggedPosition!.longitude;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ubicación guardada.'),
                            ),
                          );
                          Navigator.pop(context, latlon);

                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Toca en el mapa para seleccionar la ubicación.'),
                            ),
                          );
                        }
                      },

                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isTaped ? const Color.fromARGB(207, 83, 240, 240) : Colors.grey,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isTaped ? Colors.black87 : Colors.cyanAccent,
                            width: 4,
                          )
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_location,
                              color: isTaped ? Colors.black87 : Colors.cyanAccent,
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text('Guardar ubicación', 
                            style: TextStyle(
                              fontSize: 20, 
                              color: isTaped ? Colors.black87 : Colors.white,
                            ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
        ],
      ),
    );
  }
}
