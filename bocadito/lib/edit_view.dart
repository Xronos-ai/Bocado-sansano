import 'package:bocadito/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditingStore extends StatefulWidget {
  final String idUser;
  final String storeID;
  final String storeName;
  final IconData iconData;
  final String location;
  final Map<String,bool> payments;
  final String time;
  final String contact;
  final List<dynamic> products;

  const EditingStore({
    Key? key,
    required this.idUser,
    required this.storeID,
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
  final List<ProductForm> _productFormEdit = [];
  final List<Map<String, dynamic>> _productMapsList = [];
  final Map<String, bool> _paysCheck = {
    'Junaeb': false,
    'Tarjeta': false,
    'Efectivo': false,
    'Transferencia': false,
  };
  int idWP = 0;

  @override
  void initState() {
    super.initState();
    _initializeProducts(); 
    getStoreName(widget.storeName);
    _paysCheck['Junaeb'] = widget.payments['Junaeb'] ?? false;
    _paysCheck['Tarjeta'] = widget.payments['Tarjeta'] ?? false;
    _paysCheck['Efectivo'] = widget.payments['Efectivo'] ?? false;
    _paysCheck['Transferencia'] = widget.payments['Transferencia'] ?? false;
    getStoreLocation(widget.location);
    getStoreHours(widget.time);
    getStoreContact(widget.contact);
  }

  void _initializeProducts(){
    for (var item in widget.products){
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      var pNombre = TextEditingController(text: mapa['nombreP']);
      var pPrecio = TextEditingController(text: mapa['precio'].toString());
      var pDescripcion = TextEditingController(text: mapa['descripcion']);
      final formKey = GlobalKey<_ProductFormState>();
      bool stocK = mapa['stock'];
      _productFormEdit.add(ProductForm(
        idWP: mapa['idM'],
        onDelete: (idWP) => _removeProductForm(idWP),
        pName: pNombre,
        pPrice:  pPrecio,
        pDesc:  pDescripcion,
        stck:  stocK,
        formKey: formKey,
      ));
    }
  }

  void _addProductForm() {
    setState(() {
      var pNombre = TextEditingController(text: '');
      var pPrecio = TextEditingController(text: '');
      var pDescripcion = TextEditingController(text: '');
      final formKey = GlobalKey<_ProductFormState>();
      _productFormEdit.add(
        ProductForm(
          idWP: UniqueKey().hashCode, 
          onDelete: (idW) => _removeProductForm(idW),
          pName: pNombre,
          pPrice: pPrecio,
          pDesc: pDescripcion,
          stck: true,
          formKey: formKey,
        )
      );
    });
  }

  void _removeProductForm(int idKey) {
    setState(() {
      _productFormEdit.removeWhere((form) => form.idWP == idKey);
    });
  }

  void _collectProductInfo() {
    _productMapsList.clear(); // Limpiamos la lista antes de llenarla
    for (var productForm in _productFormEdit) {
      final productInfo = productForm.formKey.currentState?.getProductInfo();
      if (productInfo != null) {
        _productMapsList.add(productInfo);
      }
    }
  }

  // Espacio para el CRUD y las variables
  String storeName = '',   storeHours = '', 
  storeLocation = '', storeContact = '';

  // --------- Zona Tiendas ----------- //
  getStoreName(name){
    storeName = name;
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

  // Función para updateData()
  Future<void> updateData() async {
    Map<String, dynamic> storeUp = {
      'nombre': storeName,
      'pagos': _paysCheck,
      'ubicacion': storeLocation,
      'horario': storeHours,
      'contacto': storeContact,
      'productos': _productMapsList
    };

    await FirebaseFirestore.instance.collection('tiendas').doc(widget.storeID).set(storeUp);
  }

  @override
  Widget build(BuildContext context) {
    nameS.text = widget.storeName;
    locationS.text = widget.location;
    timeS.text = widget.time;
    contactS.text = widget.contact;

    return Scaffold(
      backgroundColor: Colors.black87, 
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text(
          'Edita tu tienda',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            ),
        ),
        backgroundColor: Colors.black87, 
        centerTitle: true,
      ),
      body: 
      Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/wallp_fondo.jpg',
              fit: BoxFit.cover, 
              color: Colors.black.withOpacity(0.7), 
              colorBlendMode: BlendMode.darken, 
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30.0), 
                      child: Text(
                        'Información',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white, 
                        ),
                        textAlign: TextAlign.center, 
                      ),
                    ),
                  ),
                  //-----------------------------------------
                  TextFormField(
                    controller: nameS,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la tienda:',
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
                    controller: locationS,
                    decoration: InputDecoration(
                      labelText: 'Ubicación:',
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
                            _paysCheck['Junaeb'] = !_paysCheck['Junaeb']!;
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
                                _paysCheck['Junaeb'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                color: _paysCheck['Junaeb'] ?? false ? Colors.green : Colors.grey,
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
                            _paysCheck['Tarjeta'] = !_paysCheck['Tarjeta']!;
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
                                _paysCheck['Tarjeta'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                color: _paysCheck['Tarjeta'] ?? false ? Colors.green : Colors.grey,
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
                            _paysCheck['Efectivo'] = !_paysCheck['Efectivo']!;
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
                                _paysCheck['Efectivo'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                color: _paysCheck['Efectivo'] ?? false ? Colors.green : Colors.grey,
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
                            _paysCheck['Transferencia'] = !_paysCheck['Transferencia']!;
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
                                _paysCheck['Transferencia'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                                color: _paysCheck['Transferencia'] ?? false ? Colors.green : Colors.grey,
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
                  //-----------------------------------------                  
                  TextFormField(
                    controller: timeS,
                    decoration: InputDecoration(
                      labelText: 'Horario:',
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
                      labelText: 'Contacto:',
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
                  //-----------------------------------------
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Foto de tu tienda (opcional):',
                          style: TextStyle(
                            fontSize: 17, // Tamaño del texto
                            color: Colors.cyanAccent, // Color del texto
                          ),
                          textAlign: TextAlign.left, // Centrar el texto
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          // Acción al presionar el container (actúa como un botón)
                          print('Aquí puedes añadir una imagen para tu tienda');
                        },
                        child: Container(
                          width: 80,
                          height: 80,
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
                    thickness: 1,
                  ),
                  //-----------------------------------------
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 30.0), 
                      child: Text(
                        'Productos',
                        style: TextStyle(
                          fontSize: 24, // Tamaño del texto
                          fontWeight: FontWeight.bold, // Texto en negrita
                          color: Colors.white, // Color del texto
                        ),
                        textAlign: TextAlign.center, // Centrar el texto
                      ),
                    ),
                  ),
          
                  Column(children: _productFormEdit,),
          
                  // Botón para añadir más productos
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _addProductForm();
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Añadir producto', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 12, 78, 133),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //-----------------------------------------          
                  SizedBox(height: 20),          
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
                        onPressed: () async {
                          _collectProductInfo();
                          // Acción para guardar la tienda
                          await updateData();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Mainscreen(loged: 1, userID: widget.idUser,)
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple, // Color del botón
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'Guardar cambios',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//------------------------------------------

class ProductForm extends StatefulWidget {
  final int idWP;
  final Function onDelete;
  final TextEditingController pName;
  final TextEditingController pPrice; 
  final TextEditingController pDesc;
  final bool stck;
  final GlobalKey<_ProductFormState> formKey;

  ProductForm({
    required this.idWP, 
    required this.onDelete,
    required this.pName,
    required this.pPrice,
    required this.pDesc,
    required this.stck,
    required this.formKey
  }) : super(key: formKey);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  bool isToggled = true;
  Map<String, dynamic> productInfo = {};

  @override
  void initState() {
    super.initState();
    isToggled = widget.stck;
    productInfo = {
      'idM': widget.idWP,
      'nombreP': widget.pName.text,
      'precio': widget.pPrice.text,
      'descripcion': widget.pDesc.text,
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
      key: ValueKey(widget.idWP),
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
                    controller: widget.pName,
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
                    controller: widget.pPrice,
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
          controller: widget.pDesc,
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
                  widget.onDelete(widget.idWP); // Llamamos la función de eliminación
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
