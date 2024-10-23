import 'package:bocadito/mainscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_view.dart';

class ProfilePage extends StatefulWidget {
  final String idUsuario;
  const ProfilePage({required this.idUsuario});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController priceProduct = TextEditingController(text: '');
  TextEditingController descriptionProduct = TextEditingController(text: '');
  bool _isFormVisible = false; // Visibilidad del formulario
  bool _storesVisible = false; // Visibilidad de "Mis tiendas"
  final List<Widget> _productForms = []; // Lista para almacenar los formularios de productos
  final List<Map<String, dynamic>> _productMaps = []; // Lista para almacenar los productos para firestore
  List<String> refTiendas = []; // Lista de referencias de las tiendas del usuario
  List<Widget> myStores = [];

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

  //----------------------
  Future<List<Widget>> storesBuilder() async {
    // Esperamos a que se completen las futuras de Firestore
    List<DocumentSnapshot> tiendasDocs = await Future.wait(
      refTiendas.map((id) => FirebaseFirestore.instance.collection('tiendas').doc(id).get()).toList(),
    );

    // Creamos una lista de widgets para almacenar los resultados
    List<Widget> tiendaWidgets = [];

    for (var tiendaDoc in tiendasDocs) {
      var tiendaData = tiendaDoc.data() as Map<String, dynamic>;

      // Agregamos el widget a la lista
      tiendaWidgets.add(
        StoreEdit(
          storeName: tiendaData['nombre'],
          iconData: Icons.restaurant,
          location: tiendaData['ubicacion'],
          payments: tiendaData['pagos'],
          time: tiendaData['horario'],
          contact: tiendaData['contacto'],
          products: tiendaData['productos'],
        ),
      );
    }

    return tiendaWidgets; // Retornamos la lista de widgets
  }

  //----------------------

  int idW = 0;
  // Añadir formulario de producto
  void _addProductForm() {
    setState(() {
      idW++;
      _productForms.add(_buildProductForm(idW));
    });
  }

  // Eliminar formulario de producto
  void _removeProductForm(int idKey) {
    setState(() {
      int posicion = _productForms.indexWhere((widget) => (widget.key as ValueKey).value == idKey);
      print('idKey: '+idKey.toString()+', posicion: '+posicion.toString());
      _productForms.removeAt(posicion);
    });
    int posMap = _productMaps.indexWhere((mapa) => mapa['idM'] == idKey);
    _productMaps.removeAt(posMap);
  }

  // Widget que genera el formulario para productos
  Widget _buildProductForm(idW) {
    print('idW: ' + idW.toString());
    Map<String, dynamic> productInfo = {
      'idM': idW,
      'nombreP': '',
      'precio': '',
      'descripcion': '',
    };
    _productMaps.add(productInfo);
    return Column(
      key: ValueKey(idW),
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
                onChanged: (String nameP) {
                  productInfo['nombreP'] = nameP;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: '\$Precio',
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
                keyboardType: TextInputType.number,
                onChanged: (String precioP) {
                  productInfo['precio'] = precioP;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.photo_camera, color: Colors.blue),
              onPressed: () {
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Agregar descripción del producto',
            labelStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(),
          ),
          style: TextStyle(
            color: Colors.white,
          ),
          onChanged: (String descripcionP) {
            productInfo['descripcion'] = descripcionP;
          },
        ),
        const SizedBox(height: 10),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _removeProductForm(idW);
          }
        ),
        const Divider(
          color: Colors.purple,
          thickness: 2,
        ),
      ],
    );
  }
  //------------------------
  Widget _buildProductView(String productName, String precio, String descripcion) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              color: Colors.grey, // Placeholder para imagen de producto
              child: Icon(Icons.add_photo_alternate, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //-----------------------------
                  TextFormField(
                    //controller: productName,
                    decoration: InputDecoration(
                      labelText: 'Nombre del producto',
                      labelStyle: TextStyle(color: Colors.cyanAccent),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purpleAccent),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  //-----------------------------
                  TextFormField(
                    //controller: descripcion,
                    decoration: InputDecoration(
                      labelText: 'Descripción del producto',
                      labelStyle: TextStyle(color: Colors.cyanAccent),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purpleAccent),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  //-----------------------------
                ],
              ),
            ),
            TextFormField(
              //controller: precio,
              decoration: InputDecoration(
                labelText: 'Precio',
                labelStyle: TextStyle(color: Colors.cyanAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purpleAccent),
                ),
              ),
             style: TextStyle(color: Colors.white),
            ),
            //-----------------------------
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                // Acción para eliminar producto
              },
            ),
          ],
        ),
      ),
    );
  }


  //-----------------
  List<Widget> _listarProductos (List<dynamic> productsMaps){
    List<Widget> productsView = [];
    for (var item in productsMaps){
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      //TextEditingController nameProduct = TextEditingController(text: mapa['nombreP']);
      productsView.add(_buildProductView(mapa['nombreP'], mapa['precio'], mapa['descripcion']));
    }
    return productsView;
  }

  // Espacio para el CRUD y las variables
  String storeName = '', storePayments = '', 
  storeHours = '', storeLocation = '', 
  storeID = '', storeContact = '';

  // --------- Zona Tiendas ----------- //

  getStoreID(idStore){
    storeID = idStore;
  }

  getStoreName(name){
    storeName = name;
  }

  getStorePayments(pagos){
    storePayments = pagos;
  }

  getStoreLocation(ubicacion){
    storeLocation = ubicacion;
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
      'idTienda': storeID,
      'nombre': storeName,
      'pagos': storePayments,
      'ubicacion': storeLocation,
      'horario': storeHours,
      'contacto': storeContact,
      'productos': _productMaps
    };

    DocumentReference docstore = await FirebaseFirestore.instance.collection('tiendas').add(stores);

    refTiendas.add(docstore.id);
    myStores = await storesBuilder();

    print('El id de referencia de '+storeName+' es: '+docstore.id);
    print(refTiendas);
    print('idUsuario: '+widget.idUsuario);

    // Actualizamos el documento del usuario con el array actualizado
    await FirebaseFirestore.instance.collection('usuarios').doc(widget.idUsuario).set({
      'misTiendas': refTiendas
    });
  }

  //-------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, 
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
                      'User name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.cyanAccent),
                    onPressed: () {
                      // Acción para cerrar sesión
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Mainscreen(loged: 0, userID: '',)
                        ),
                      );
                    },
                    tooltip: 'Cerrar sesión', // Tooltip opcional para accesibilidad
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
                trailing: Icon(
                  _storesVisible ? Icons.expand_more : Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onTap: () {
                  setState(() {
                    _storesVisible = !_storesVisible; 
                  });
                  print('Las refTiendas (Mis Tiendas) son: '+refTiendas.toString());
                },
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
              ListTile(
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
                  print('Las refTiendas (Añadir tienda) son: '+refTiendas.toString());
                  setState(() {
                    _isFormVisible = !_isFormVisible; 
                  });
                },
              ),

              // Formulario desplegable
              if (_isFormVisible)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nombre de la tienda',
                            labelStyle: const TextStyle(color: Color.fromARGB(255, 84, 178, 255)),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.photo_camera, color: Colors.blue),
                              onPressed: () {
                              },
                            ),
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

                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Ubicación',
                            labelStyle: const TextStyle(color: Colors.blue),
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

                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Medios de pago',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          onChanged: (String pagos) {
                            getStorePayments(pagos);
                          },
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),

                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Horario',
                            labelStyle: const TextStyle(color: Colors.blue),
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

                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contacto',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          onChanged: (String contacto) {
                            getStoreContact(contacto);
                          },
                        ),
                        const Divider(
                          color: Colors.purple,
                          thickness: 2,
                        ),
                        
                        // Formularios de productos
                        Column(children: _productForms),

                        // Botón para añadir más productos
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

                        // Botón para registrar la tienda
                        ElevatedButton(
                          onPressed: () {
                            createData();
                            setState(() {
                              _isFormVisible = !_isFormVisible; 
                            });
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Tienda registrada. Revisa "Mis tiendas".'),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 123, 21, 141),
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
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
  final String storeName;
  final IconData iconData;
  final String location;
  final String payments;
  final String time;
  final String contact;
  final List<dynamic> products;

  const StoreEdit({
    Key? key,
    required this.storeName,
    required this.iconData,
    required this.location,
    required this.payments,
    required this.time,
    required this.contact,
    required this.products
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
                    storeName: widget.storeName, 
                    iconData: widget.iconData,
                    location: widget.location,
                    payments: widget.payments,
                    time: widget.time,
                    contact: widget.contact,
                    products: widget.products,
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