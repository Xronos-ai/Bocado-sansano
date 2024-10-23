import 'package:flutter/material.dart';

class EditingStore extends StatefulWidget {
  final String storeName;
  final IconData iconData;
  final String location;
  final String payments;
  final String time;
  final String contact;
  final List<dynamic> products;

  const EditingStore({
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
  _EditingStoreState createState() => _EditingStoreState();
}

class _EditingStoreState extends State<EditingStore> {
  TextEditingController nameS = TextEditingController(text: '');
  TextEditingController locationS = TextEditingController(text: '');
  TextEditingController paymentsS = TextEditingController(text: '');
  TextEditingController timeS = TextEditingController(text: '');
  TextEditingController contactS = TextEditingController(text: '');
  final List<Widget> _productFormEdit = [];
  final List<Map<String, dynamic>> _productMapsList = [];
  int idWP = 0;

  @override
  void initState() {
    super.initState();
    _initializeProducts(); // Llamamos a la función para obtener las tiendas cuando se inicializa el widget
    print(widget.products);
  }

  void _initializeProducts(){
    for (var item in widget.products){
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      idWP++;
      var pNombre = TextEditingController(text: mapa['nombreP']);
      var pPrecio = TextEditingController(text: mapa['precio'].toString());
      var pDescripcion = TextEditingController(text: mapa['descripcion']);
      _productFormEdit.add(_buildProductForm(idWP, pNombre, pPrecio, pDescripcion));
    }
  }

  void _addProductForm() {
    idWP++;
    setState(() {
      var pNombre = TextEditingController(text: '');
      var pPrecio = TextEditingController(text: '');
      var pDescripcion = TextEditingController(text: '');
      _productFormEdit.add(_buildProductForm(idWP, pNombre, pPrecio, pDescripcion));
    });
  }

  void _removeProductForm(int idKey) {
    setState(() {
      int posicion = _productFormEdit.indexWhere((widget) => (widget.key as ValueKey).value == idKey);
      print('idKey: '+idKey.toString()+', posicion: '+posicion.toString());
      _productFormEdit.removeAt(posicion);
    });
    int posMap = _productMapsList.indexWhere((mapa) => mapa['idM'] == idKey);
    _productMapsList.removeAt(posMap);
  }

  Widget _buildProductForm(idWP, TextEditingController pName, TextEditingController pPrice, TextEditingController pDesc) {
    print('idWP: ' + idWP.toString());
    Map<String, dynamic> productInfo = {
      'idM': idWP,
      'nombreP': '',
      'precio': '',
      'descripcion': '',
    };
    _productMapsList.add(productInfo);
    return Column(
      key: ValueKey(idWP),
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: pName,
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
                controller: pPrice,
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
          controller: pDesc,
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
        // Botón para eliminar producto
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _removeProductForm(idWP);
          }
        ),
        const Divider(
          color: Colors.purple,
          thickness: 2,
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    nameS.text = widget.storeName;
    locationS.text = widget.location;
    paymentsS.text = widget.payments;
    timeS.text = widget.time;
    contactS.text = widget.contact;

    return Scaffold(
      backgroundColor: Colors.black87, // Fondo oscuro
      appBar: AppBar(
        title: Text(
          'Edita tu tienda',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple, // Color de la barra superior
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen y Nombre de la tienda
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey, // Placeholder para imagen
                    child: Icon(Icons.image, size: 50, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: nameS,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la tienda',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purpleAccent),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (String name) {
                        getStoreName(name);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              //-----------------------------------------
              TextFormField(
                controller: locationS,
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  labelStyle: TextStyle(color: Colors.cyanAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (String ubicacion) {
                  getStoreLocation(ubicacion);
                },
              ),
              //-----------------------------------------
              TextFormField(
                controller: paymentsS,
                decoration: InputDecoration(
                  labelText: 'Medios de pago',
                  labelStyle: TextStyle(color: Colors.cyanAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (String pagos) {
                  getStorePayments(pagos);
                },
              ),
              //-----------------------------------------
              TextFormField(
                controller: timeS,
                decoration: InputDecoration(
                  labelText: 'Horario',
                  labelStyle: TextStyle(color: Colors.cyanAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (String horario) {
                  getStoreLocation(horario);
                },
              ),
              //-----------------------------------------
              TextFormField(
                controller: contactS,
                decoration: InputDecoration(
                  labelText: 'Contacto',
                  labelStyle: TextStyle(color: Colors.cyanAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (String contacto) {
                  getStoreContact(contacto);
                },
              ),

              Column(children: _productFormEdit,),

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

              SizedBox(height: 40),

              // Botones para guardar o borrar tienda
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Acción para borrar la tienda
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Color del botón
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Borrar Tienda',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Acción para guardar la tienda
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Color del botón
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Guardar Tienda',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
