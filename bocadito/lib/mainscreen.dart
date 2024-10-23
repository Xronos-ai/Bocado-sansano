import 'package:flutter/material.dart';
import 'profile_view.dart';
import 'signup_view.dart';
import 'login_view.dart';
import 'gonza.dart';
import 'storelist.dart';

class Mainscreen extends StatefulWidget {
  final int loged;
  final String userID;
  const Mainscreen({super.key, required this.loged, required this.userID});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int indexseleccionado = 1; 

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
    
    final screens = [StoreListPage(), userScreen];
    
    return Scaffold(
      backgroundColor: Colors.black87,
      body: 
      IndexedStack(
        index: indexseleccionado,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white,
        currentIndex: indexseleccionado,
        onTap: (neoindex){
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
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      );
  }
}
