import 'package:bocadito/mainscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'utils/auth.dart'; // Importamos el archivo auth.dart

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormBuilderState>(); // Llave del formulario
  final AuthService _authService = AuthService(); // Instancia del servicio de autenticación

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Color de fondo
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: FormBuilder(
            key: _formKey,
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

                // Campo de texto para el correo electrónico
                FormBuilderTextField(
                  name: 'email',
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    hintText: 'User name (email)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 20),

                // Campo de texto para la contraseña
                FormBuilderTextField(
                  name: 'password',
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(6),
                  ]),
                ),
                const SizedBox(height: 20),

                // Campo de texto para confirmar la contraseña
                FormBuilderTextField(
                  name: 'confirm_password',
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
                    hintText: 'Confirm password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) {
                    if (val != _formKey.currentState?.fields['password']?.value) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Botón de "Sign up"
                ElevatedButton(
                  onPressed: () async {

                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final email = _formKey.currentState?.fields['email']?.value;
                      final password = _formKey.currentState?.fields['password']?.value;

                      // Llamamos al método de autenticación
                      dynamic result = await _authService.createAcount(email, password);
                      
                      if (result == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Error, contraseña débil. Por favor cambiar contraseña.'),
                        ));
                      } else if (result == 2) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Error, el email ya está en uso.'),
                        ));
                      } else if (result != null) {
                        // Registro exitoso, inicializa el listado de tiendas del nuevo usuario
                        FirebaseFirestore.instance.collection('usuarios').doc(result).set({
                          'misTiendas': []
                        });
                        print('el result id de usuario es: '+result);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Mainscreen(loged: 0, userID: '')
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Registrado exitosamente, ya puedes iniciar sesión.'),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('An error occurred. Please try again later.'),
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.purple, 
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Botón de "Ya tienes cuenta?"
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Mainscreen(loged: 0, userID: '')
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color.fromARGB(255, 59, 59, 59), 
                  ),
                  child: const Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
