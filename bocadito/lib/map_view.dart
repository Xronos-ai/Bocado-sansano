import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const map_box_key = 'pk.eyJ1IjoieHJvbm9zIiwiYSI6ImNtM2djbGoybTAzMnAycnBwb2JieGwxdDEifQ.NsjB1IYwQr72hemnn1ji_A';

class MapView extends StatefulWidget {
  final double lati;
  final double long;
  final bool actvMark;

  const MapView({
    super.key,
    this.lati = -33.0353043,
    this.long = -71.5956004,
    this.actvMark = false,
  });

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? myPosition;

  @override
  void initState() {
    myPosition = LatLng(widget.lati, widget.long);
    super.initState();
  }

  @override
  void dispose() {
    // Aquí puedes restablecer valores o realizar limpiezas si es necesario.
    myPosition = LatLng(widget.lati, widget.long);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(200, 0, 0, 0),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('tiendas').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No existen tiendas aún'));
                }

                // Crear una lista de marcadores usando los datos de Firestore
                List<Marker> markers = snapshot.data!.docs.map((doc) {
                  final latitud = doc['latitud'] as double;
                  final longitud = doc['longitud'] as double;
                  final nombreTienda = doc['nombre'] as String;

                  return Marker(
                    point: LatLng(latitud, longitud),
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purpleAccent)
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: nombreTienda,
                                    style: TextStyle(color: Colors.cyanAccent, fontSize: 8)
                                  ),
                                ]
                              ),
                              ),
                          ),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 30,
                        ),
                      ],
                    ),
                  );
                }).toList();

                // Añadir el marcador de la posición actual del usuario
                widget.actvMark ? 
                markers.insert(0,
                  Marker(
                    point: myPosition!,
                    child: Icon(
                      Icons.pin_drop,
                      color: Colors.cyanAccent,
                      size: 20,
                    ),
                  ),
                ) : null;
                //--------------------------

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: myPosition!,
                    minZoom: 5,
                    maxZoom: 20,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                      additionalOptions: const {
                        'accessToken': map_box_key,
                        'id': 'mapbox/dark-v11',
                      },
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
    );
  }
}
