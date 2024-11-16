import 'package:bocadito/mainscreen.dart';
import 'package:bocadito/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'utils/auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService();

  //Autenticación del usuario utilizando AuthService
  Future<void> _loginUser(String email, String password) async {
    final result = await _authService.signInEmailAndPassword(email, password);
    if (result is String) {
      print('Usuario autenticado: $result');
    } else if (result == 1) {
      print('Usuario no encontrado.');
    } else if (result == 2) {
      print('Contraseña incorrecta.');
    } else {
      print('Error durante la autenticación.');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(200, 0, 0, 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    // Campo correo electrónico
                    FormBuilderTextField(
                      name: 'email',
                      obscureText: false,
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
                        FormBuilderValidators.required(errorText: 'Este campo es obligatorio'),
                        FormBuilderValidators.email(errorText: 'Ingrese un correo válido'),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    //-------------------------------------

                    // Campo contraseña
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

                          dynamic result = await _authService.signInEmailAndPassword(email, password);
                          
                          if (result == 1) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Error, usuario no encontrado.'),
                            ));
                          } else if (result == 2) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Contraseña incorrecta.'),
                            ));
                          } else if (result != null) {
                            context.read<UserProvider>().changeIDuser(newiDuser: result);
                            context.read<UserProvider>().changeLoged(newloged: 1);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mainscreen(loged: 1, userID: result)
                              ),
                            );
                            print('supuesto id del usuario logeado es: '+result);
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
                        backgroundColor: Colors.purple, 
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
                            builder: (context) => Mainscreen(loged: 2, userID: '')
                          ),
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
    );
  }
}
