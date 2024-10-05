import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Color de fondo
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Espaciado superior

              // Icono y nombre de usuario
              const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(width: 20),
                  // Nombre de usuario
                  Text(
                    'User name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Botón de "Mis tiendas"
              ListTile(
                leading: const Icon(Icons.store, color: Colors.blue),
                title: const Text(
                  'Mis tiendas',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  // Acción cuando se toca el botón
                },
              ),
              const SizedBox(height: 20),

              // Botón de "Añadir tienda"
              ListTile(
                leading: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                title: const Text(
                  'Añadir tienda',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  // Acción cuando se toca el botón
                },
              ),
            ],
          ),
        ),
      ),
      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white,
        currentIndex: 1, // Perfil está seleccionado
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
