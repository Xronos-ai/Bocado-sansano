import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {

  // Generar instancias
  static late SharedPreferences _prefs;

  // Inicializar preferencias
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get ultimaPagina {
    return _prefs.getString('ultimaPagina') ?? '';
  }

  set ultimaPagina(String value){
    _prefs.setString('ultimaPagina', value);
  }
}