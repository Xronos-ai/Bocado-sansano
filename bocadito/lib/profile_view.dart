import 'package:bocadito/mainscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_view.dart';
import 'set_location.dart';
import 'package:provider/provider.dart';
import 'package:bocadito/providers/user_provider.dart';

class ProfilePage extends StatefulWidget {
  final String idUsuario;
  const ProfilePage({required this.idUsuario});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController priceProduct = TextEditingController(text: '');
  TextEditingController descriptionProduct = TextEditingController(text: '');
  bool _isFormVisible = false; // Visibilidad del formulario "Añadir tienda"
  bool _storesVisible = false; // Visibilidad de "Mis tiendas"
  final List<Map<String, dynamic>> _productMaps = []; // Lista para almacenar los productos para firestore
  final Map<String, bool> _paymentsCheck = {
    'Junaeb': false,
    'Tarjeta': false,
    'Efectivo': false,
    'Transferencia': false
    }; //Lista para almacenar medios de pagos aceptados
  List<String> refTiendas = []; // Lista de referencias de las tiendas del usuario
  List<Widget> myStores = [];
  List<ProductForm> _productForms = [];
  bool mapSaved = false;
  final _formKey = GlobalKey<FormState>(); // Clave global para el Formulario

  @override
  void initState() {
    super.initState();
    _initializeStores(); // Llamamos a la función para obtener las tiendas cuando se inicializa el widget
  }

  Future<void> _initializeStores() async {
    refTiendas = await obtenerTiendas();
    myStores = await storesBuilder();
    print('Tiendas obtenidas automáticamente: $refTiendas');
  }

  Future<List<String>> obtenerTiendas() async{
    List<String> misTiendas = [];
    DocumentReference documentReference = FirebaseFirestore.instance.collection('usuarios').doc(widget.idUsuario);
    //-----------------------------
    try {
      // Obtener el documento desde Firestore
      DocumentSnapshot documentSnapshot = await documentReference.get();

      // Verificar si el documento existe
      if (documentSnapshot.exists) {
        // Obtener el campo 'misTiendas', que es una lista de strings
        misTiendas = List<String>.from(documentSnapshot.get('misTiendas'));
      } else {
        print('El documento no existe');
      }
    } catch (e) {
      print('Error al obtener el documento: $e');
    }
    return misTiendas;
    //-----------------------------
  }

  Map<String, bool> _dynamicToBool (Map<String, dynamic> mapaDinamico){
    Map<String, bool> pagosBool = mapaDinamico.map((key, value) {
      return MapEntry(key, value as bool); // Hacemos el casting de 'dynamic' a 'bool'
    });
    return pagosBool;
  }
  
  //--- storesBuilder() retorna una lista con las tiendas del usuario 
  Future<List<Widget>> storesBuilder() async {
    if (refTiendas.isNotEmpty){
      // Listado con todas las tiendas que el usuario tenga registradas
      List<DocumentSnapshot> tiendasDocs = await Future.wait(
        refTiendas.map((id) => FirebaseFirestore.instance.collection('tiendas').doc(id).get()).toList(),
      );

      // Creamos una lista de widgets para almacenar los resultados
      List<Widget> tiendaWidgets = [];
      int indx = 0;

      for (var tiendaDoc in tiendasDocs) {
        var tiendaData = tiendaDoc.data() as Map<String, dynamic>;
        String idTienda = refTiendas[indx];

        // Agregamos el widget a la lista
        tiendaWidgets.add(
          StoreEdit(
            usrID: widget.idUsuario,
            storeID: idTienda,
            storeName: tiendaData['nombre'],
            iconData: Icons.restaurant,
            location: tiendaData['ubicacion'],
            payments: _dynamicToBool(tiendaData['pagos']),
            time: tiendaData['horario'],
            contact: tiendaData['contacto'],
            products: tiendaData['productos'],
            lat: tiendaData['latitud'],
            lon: tiendaData['longitud'],
          ),
        );
        indx++;
      }

      return tiendaWidgets;

    }else{
      return [];
    }
  }

  //----------------------
  void _addProductForm() {
    setState(() {
      final formKey = GlobalKey<_ProductFormState>();
      _productForms.add(
        ProductForm(
          idW: UniqueKey().hashCode, 
          onDelete: (idW) => _removeProductForm(idW),
          formKey: formKey,
        )
      );
    });
  }
  //-----------------------
  void _removeProductForm(int idW) {
    setState(() {
      _productForms.removeWhere((form) => form.idW == idW);
    });
  }
  //------------------------
  void _collectProductInfo() {
    _productMaps.clear(); // Limpiamos la lista antes de llenarla
    for (var productForm in _productForms) {
      final productInfo = productForm.formKey.currentState?.getProductInfo();
      if (productInfo != null) {
        _productMaps.add(productInfo);
      }
    }
  }  

  //------ Espacio para el CRUD y las variables ------
  String storeName = '', storePayments = '', 
  storeHours = '', storeLocation = '', storeContact = '';

  double lat = 1, lon = 1;
  
  // --------- Zona Tiendas ----------- 
  getStoreName(name){
    storeName = name;
  }

  getStorePayments(pagos){
    storePayments = pagos;
  }

  getStoreLocation(ubicacion){
    storeLocation = ubicacion;
  }

  getStoreLatitude(latitud){
    lat = latitud;
  }
  getStoreLongitud(longitud){
    lon = longitud;
  }

  getStoreHours(horario){
    storeHours = horario;
  }

  getStoreContact(contacto){
    storeContact = contacto;
  }

  // --------- Zona Manejo de Data ----------- //
  Future<void> createData() async {
    Map<String, dynamic> stores = {
      'nombre': storeName,
      'pagos': _paymentsCheck,
      'ubicacion': storeLocation,
      'horario': storeHours,
      'contacto': storeContact,
      'productos': _productMaps,
      'latitud': lat,
      'longitud': lon,
    };
    DocumentReference docstore = await FirebaseFirestore.instance.collection('tiendas').add(stores);

    // A refTiendas (lista con los id de las tiendas de este usuario) le añadimos
    // el id de la nueva tienda creada
    refTiendas.add(docstore.id);
    myStores = await storesBuilder();

    // Actualizamos el documento del usuario con el array actualizado
    await FirebaseFirestore.instance.collection('usuarios').doc(widget.idUsuario).set({
      'misTiendas': refTiendas
    });
  }

  bool juna = false;
  bool card = false;
  bool cash = false;
  bool transf = false;

  final TextEditingController _nameStoreController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();

  //-------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(200, 0, 0, 0), 
      body: 
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40), 

              // Icono y nombre de usuario
              Row(
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
                  Expanded(
                    child: Text(
                      'Administrador',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    children: [
                      Text('Salir', style: TextStyle(color: Colors.cyanAccent, fontSize: 12),),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.cyanAccent),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          // Acción para cerrar sesión
                          context.read<UserProvider>().changeIDuser(newiDuser: '');
                          context.read<UserProvider>().changeLoged(newloged: 0);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Mainscreen(loged: 0, userID: '')
                            ),
                          );
                        },// Tooltip opcional para accesibilidad
                      ),
                      
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Botón de "Mis tiendas"
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple, // Color del borde
                    width: 2.0,              // Grosor del borde
                  ),
                  borderRadius: BorderRadius.circular(10), // Borde redondeado (opcional)
                ),
                child: ListTile(
                  leading: const Icon(Icons.store, color: Colors.blue),
                  title: const Text(
                    'Mis tiendas',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  trailing: Icon(
                    _storesVisible ? Icons.expand_more : Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onTap: () {
                    setState(() {
                      _storesVisible = !_storesVisible; 
                      _isFormVisible = false;
                    });
                    print('Las refTiendas (Mis Tiendas) son: ' + refTiendas.toString());
                  },
                ),
              ),

              //----------------------------
              if (_storesVisible) ... [
                Column(
                  children: myStores,
                )
              ],

              //----------------------------
              const SizedBox(height: 20),

              // Botón de "Añadir tienda"
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple, 
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10), 
                ),
                child: ListTile(
                  leading: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                  title: const Text(
                    'Añadir tienda',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  trailing: Icon(
                    _isFormVisible ? Icons.expand_more : Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onTap: () {
                    setState(() {
                      _isFormVisible = !_isFormVisible; 
                      _storesVisible = false;
                    });
                  },
                ),
              ),

              // Formulario desplegable
              if (_isFormVisible)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameStoreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre de la tienda*',
                            labelStyle: const TextStyle(color: Colors.cyanAccent),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          onChanged: (String name) {
                            getStoreName(name);
                          },
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        //---------------------------------------
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _directionController,
                          decoration: InputDecoration(
                            labelText: 'Dirección*',
                            labelStyle: const TextStyle(color:  Colors.cyanAccent),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          onChanged: (String ubicacion) {
                            getStoreLocation(ubicacion);
                          },
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        //---------------------------------------
                        const SizedBox(height: 10),
                        //------------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ubicar tienda en el mapa*', style: TextStyle(color: Colors.cyanAccent, fontSize: 16),),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: mapSaved ? Colors.purpleAccent : Colors.red, width: 2),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.location_on, color: mapSaved ? Colors.cyanAccent : Colors.redAccent,),
                                onPressed: () async {
                                  final List<double> resultado = await Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => SetLocation(lati: -33.0353043, longi: -71.5956004,))
                                  );
                                  getStoreLatitude(resultado[0]);
                                  getStoreLongitud(resultado[1]);
                                  setState(() {
                                    mapSaved = true;
                                  });
                                },
                              )
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        const Divider(color: Colors.purple, thickness: 2,),
                        //---------------------------------------
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: 
                              Text(
                                'Medios de pago (al menos uno)', 
                                style: TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 16
                                ),
                              ),
                            ),
                            //----- Junaeb -----
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _paymentsCheck['Junaeb'] = !_paymentsCheck['Junaeb']!;
                                  juna = !juna;
                                });                             
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _paymentsCheck['Junaeb'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                      color: _paymentsCheck['Junaeb'] ?? false ? Colors.green : Colors.grey,
                                      size: 40,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Junaeb', style: TextStyle(fontSize: 20, color: Colors.white),)
                                  ],
                                ),
                              ),
                            ),
                            //----- Tarjeta -----
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _paymentsCheck['Tarjeta'] = !_paymentsCheck['Tarjeta']!;
                                  card = !card;
                                });                             
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _paymentsCheck['Tarjeta'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                      color: _paymentsCheck['Tarjeta'] ?? false ? Colors.green : Colors.grey,
                                      size: 40,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Tarjeta', style: TextStyle(fontSize: 20, color: Colors.white),)
                                  ],
                                ),
                              ),
                            ),
                            //----- Efectivo -----
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _paymentsCheck['Efectivo'] = !_paymentsCheck['Efectivo']!;
                                  cash = !cash;
                                });                             
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _paymentsCheck['Efectivo'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                      color: _paymentsCheck['Efectivo'] ?? false ? Colors.green : Colors.grey,
                                      size: 40,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Efectivo', style: TextStyle(fontSize: 20, color: Colors.white),)
                                  ],
                                ),
                              ),
                            ),
                            //----- Transferencia -----
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _paymentsCheck['Transferencia'] = !_paymentsCheck['Transferencia']!;
                                  transf = !transf;
                                });                             
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _paymentsCheck['Transferencia'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                      color: _paymentsCheck['Transferencia'] ?? false ? Colors.green : Colors.grey,
                                      size: 40,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Transferencia', style: TextStyle(fontSize: 20, color: Colors.white),)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        //---------------------------------------
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _horarioController,
                          decoration: InputDecoration(
                            labelText: 'Horario*',
                            labelStyle: const TextStyle(color:  Colors.cyanAccent),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          onChanged: (String horario) {
                            getStoreHours(horario);
                          },
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        //---------------------------------------
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _contactoController,
                          decoration: InputDecoration(
                            labelText: 'Contacto*',
                            labelStyle: const TextStyle(color:  Colors.cyanAccent),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String contacto) {
                            getStoreContact(contacto);
                          },
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        //---------------------------------------
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Foto de tu tienda (opcional):',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.cyanAccent, 
                                ),
                                textAlign: TextAlign.left, 
                              ),
                            ),
                            SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                print('Aquí puedes añadir una imagen para tu tienda');
                              },
                              child: Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.purple),
                                ),
                                child: Icon(Icons.add_a_photo, size: 30, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        //---------------------------------------
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 30.0), 
                            child: Text(
                              'Productos',
                              style: TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white, 
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        
                        // Formularios de productos
                        Column(children: _productForms),

                        //------ Botón para añadir más productos -----
                        ElevatedButton.icon(
                          onPressed: () {
                            _addProductForm();
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Añadir producto', style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 12, 78, 133),
                          ),
                        ),
                        const SizedBox(height: 20),

                        //------ Botón para registrar la tienda ------
                        ElevatedButton(
                          onPressed: () {
                            if(juna || card || cash || transf){
                              if(_nameStoreController.text.isNotEmpty){
                                if(_directionController.text.isNotEmpty){
                                  if(mapSaved){
                                    if(_horarioController.text.isNotEmpty){
                                      if(_contactoController.text.isNotEmpty){
                                        _collectProductInfo();
                                        createData();
                                        setState(() {
                                          _isFormVisible = !_isFormVisible; 
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('Tienda registrada. Revisa "Mis tiendas".'),
                                        ));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('Debes completar el campo "Contacto".'),
                                        ));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Debes completar el campo "Horario".'),
                                      ));
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Debes ubicar tu tienda en el mapa.'),
                                    ));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Debes completar el campo "Dirección".'),
                                  ));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Debes completar el campo "Nombre de la tienda".'),
                                ));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Elige por lo menos un método de pago.'),
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 123, 21, 141),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          ),
                          child: const Text(
                            'Registrar tienda',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//----------------------------------------------------

class StoreEdit extends StatefulWidget {
  final String usrID;
  final String storeID;
  final String storeName;
  final IconData iconData;
  final String location;
  final Map<String, bool> payments;
  final String time;
  final String contact;
  final List<dynamic> products;
  final double lat;
  final double lon;

  const StoreEdit({
    Key? key,
    required this.usrID,
    required this.storeID,
    required this.storeName,
    required this.iconData,
    required this.location,
    required this.payments,
    required this.time,
    required this.contact,
    required this.products,
    required this.lat,
    required this.lon,
  }) : super(key: key);

  @override
  _StoreEditState createState() => _StoreEditState();
}

class _StoreEditState extends State<StoreEdit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(widget.iconData, color: Colors.white),
            title: Text(
              widget.storeName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
            ),
            trailing: Icon(Icons.edit_square,
              color: Colors.cyanAccent,
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditingStore(
                    idUser: widget.usrID,
                    storeID: widget.storeID,
                    storeName: widget.storeName, 
                    iconData: widget.iconData,
                    location: widget.location,
                    payments: widget.payments,
                    time: widget.time,
                    contact: widget.contact,
                    products: widget.products,
                    latit: widget.lat,
                    longit: widget.lon,
                  )
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//--------------------------------------------------

class ProductForm extends StatefulWidget {
  final int idW;
  final Function onDelete;
  final GlobalKey<_ProductFormState> formKey; 

  ProductForm({required this.idW, required this.onDelete, required this.formKey}) : super(key: formKey);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  bool isToggled = true;
  Map<String, dynamic> productInfo = {};

  @override
  void initState() {
    super.initState();
    productInfo = {
      'idM': widget.idW,
      'nombreP': '',
      'precio': '',
      'descripcion': '',
      'stock': isToggled,
    };
  }

  // Método para obtener la información del producto
  Map<String, dynamic> getProductInfo() {
    return productInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(widget.idW),
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: GestureDetector(
                onTap: () {
                  print('Aquí podrás añadir una foto para tu tienda');
                },
                child: Icon(Icons.add_a_photo, size: 40, color: Colors.cyanAccent),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre producto*',
                      labelStyle: const TextStyle(color: Colors.cyanAccent),
                      border: OutlineInputBorder(),
                      fillColor: Colors.black,
                      filled: true,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (String nameP) {
                      setState(() {
                        productInfo['nombreP'] = nameP;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Precio* \$\$\$',
                      labelStyle: const TextStyle(color: Colors.cyanAccent),
                      border: OutlineInputBorder(),
                      fillColor: Colors.black,
                      filled: true,
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (String precioP) {
                      setState(() {
                        productInfo['precio'] = precioP;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Agregar descripción del producto',
            labelStyle: const TextStyle(color: Colors.cyanAccent),
            border: OutlineInputBorder(),
            fillColor: Colors.black,
            filled: true,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (String descripcionP) {
            setState(() {
              productInfo['descripcion'] = descripcionP;
            });
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isToggled = !isToggled;
                  productInfo['stock'] = isToggled;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      isToggled ? Icons.toggle_on : Icons.toggle_off,
                      color: isToggled ? Colors.green : Colors.grey,
                      size: 40,
                    ),
                    SizedBox(width: 10),
                    Text('Stock', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.red),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  widget.onDelete(widget.idW); 
                },
              ),
            ),
          ],
        ),
        const Divider(
          color: Colors.purple,
          thickness: 2,
        ),
      ],
    );
  }
}
