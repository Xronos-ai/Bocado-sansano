import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'signup_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/auth.dart'; // Importamos el archivo auth.dart
import 'profile_view.dart';

// Pantalla de inicio de sesión
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService(); // Instanciamos AuthService

  // Función para autenticar al usuario utilizando AuthService
  Future<void> _loginUser(String email, String password) async {
    final result = await _authService.signInEmailAndPassword(email, password);
    if (result is String) {
      // Usuario autenticado correctamente
      print('Usuario autenticado: $result');
    } else if (result == 1) {
      // Usuario no encontrado
      print('Usuario no encontrado.');
    } else if (result == 2) {
      // Contraseña incorrecta
      print('Contraseña incorrecta.');
    } else {
      print('Error durante la autenticación.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Color de fondo
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono del usuario
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 30),

              // Formulario de inicio de sesión
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de texto para el correo electrónico
                    FormBuilderTextField(
                      name: 'email',
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Colors.blue),
                        hintText: 'Correo electrónico',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: 'Este campo es obligatorio'),
                        FormBuilderValidators.email(
                            errorText: 'Ingrese un correo válido'),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Campo de texto para la contraseña
                    FormBuilderTextField(
                      name: 'password',
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        hintText: 'Contraseña',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: 'Este campo es obligatorio'),
                        FormBuilderValidators.minLength(6,
                            errorText:
                                'La contraseña debe tener al menos 6 caracteres'),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Botón de "Log in"
                    ElevatedButton(
                      onPressed: () async{ 

                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final email = _formKey.currentState?.fields['email']?.value;
                          final password = _formKey.currentState?.fields['password']?.value;

                          // Llamamos al método de autenticación
                          dynamic result = await _authService.signInEmailAndPassword(email, password);
                          
                          if (result == 1) {
                            // Manejar usuario
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Error, usuario no encontrado.'),
                            ));
                          } else if (result == 2) {
                            // Manejar contraseña
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Contraseña incorrecta.'),
                            ));
                          } else if (result != null) {
                            // Login exitoso, puedes redirigir o mostrar un mensaje
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => ProfilePage()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Usuario logeado exitosamente.'),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('An error occurred. Please try again later.'),
                            ));
                          }
                        }

                        //--------------------------
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final email = _formKey.currentState?.value['email'];
                          final password =
                              _formKey.currentState?.value['password'];
                          _loginUser(email, password);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.purple, // Color del botón
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Botón de "No tienes cuenta?"
                    ElevatedButton(
                      onPressed: () {
                        // Navegar a la página de registro
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 59, 59, 59), // Color del botón
                      ),
                      child: const Text(
                        '¿No tienes cuenta?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
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
