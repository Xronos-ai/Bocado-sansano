import 'package:flutter/material.dart';
import 'profile_view.dart';
import 'signup_view.dart';
import 'login_view.dart';
import 'storelist.dart';
import 'map_view.dart';

class Mainscreen extends StatefulWidget {
  final int loged;
  final String userID;
  final int initialIndex;
  final double lati;
  final double long;
  final bool actvMark;

  const Mainscreen({
    super.key, 
    required this.loged, 
    required this.userID,
    this.initialIndex = 2,
    this.lati = -33.0353043,
    this.long = -71.5956004,
    this.actvMark = false,
  });

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  late int indexseleccionado; 

  @override
  void initState() {
    super.initState();
    indexseleccionado = widget.initialIndex; // Inicializar con el valor recibido
  }

  @override
  Widget build(BuildContext context) {
    Widget userScreen;
    if (widget.loged == 0){
      userScreen = LoginPage();
    }
    else if (widget.loged == 1){
      userScreen = ProfilePage(idUsuario: widget.userID);
    }
    else if (widget.loged == 2){
      userScreen = SignUpPage();
    }
    else {
      userScreen = LoginPage();
    }

    final screens = [StoreListPage(), MapView(lati: widget.lati, long: widget.long, actvMark: widget.actvMark,), userScreen];

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/wallp_fondo.jpg',
              fit: BoxFit.cover, // Ajusta la imagen al tamaño de la pantalla
              color: Colors.transparent, // Ajusta la opacidad
              colorBlendMode: BlendMode.luminosity, // Mezcla el color para oscurecer la imagen
            ),
          ),
          // Contenido de la app
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: indexseleccionado,
                  children: screens,
                ),
              ),
              BottomNavigationBar(
                backgroundColor: Colors.black,
                selectedItemColor: Colors.cyanAccent,
                unselectedItemColor: Colors.white,
                currentIndex: indexseleccionado,
                onTap: (neoindex) {
                  setState(() {
                    indexseleccionado = neoindex; 
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store),
                    label: 'Tiendas', 
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_outlined),
                    label: 'Mapa', 
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
