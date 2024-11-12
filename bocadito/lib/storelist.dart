import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreListPage extends StatefulWidget {
  @override
  _StoreListPageState createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
 
  // Widget para construir la carta de un producto
  Widget _buildProductView(String productName, String precio, String descripcion, bool stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //--- Nombre ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(1), 
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8.0), 
                border: Border.all(color: Colors.cyanAccent, width: 2),// Bordes redondeados
              ),
              child: Center(
                child: Text(
                  productName,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icono
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.cyanAccent, width: 2.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image, 
                      size: 40.0,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 20,),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //--- Precio ---
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.cyanAccent, width: 2.0),
                        ),
                        child: Text(
                          '\$$precio',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 10.0),

                      //--- Stock ---
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.cyanAccent, width: 2.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              stock ? Icons.circle : Icons.circle_outlined,
                              color: stock ? Colors.green : Colors.red,
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              stock ? 'Disponible' : 'Sin stock',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.0),

            //--- Descripción ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.0), // Espaciado interno para que el texto no toque el borde
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.cyanAccent, width: 2.0), // Borde cian
                borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
              ),
              child: Text(
                'Descripción: \n'+descripcion,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  //---------------------------------

  List<Widget> _listarProductos (List<dynamic> productsMaps){
    List<Widget> productsView = [];
    for (var item in productsMaps){
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      productsView.add(_buildProductView(mapa['nombreP'], mapa['precio'], mapa['descripcion'], mapa['stock']));
    }
    return productsView;
  }

  // función que transforma un mapa <String, dynamic> a uno <String, bool>
  Map<String, bool> _dynamicToBool (Map<String, dynamic> mapaDinamico){
    Map<String, bool> pagosBool = mapaDinamico.map((key, value) {
      return MapEntry(key, value as bool); // Hacemos el casting de 'dynamic' a 'bool'
    });
    return pagosBool;
  }

  void _searchStore(String query) {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.black87,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 109, 108, 108),
            borderRadius: BorderRadius.circular(30),
          ),
          
          child: Row(
            children: [
              const Divider(color: Colors.black87,),
              const SizedBox(height: 40,),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _searchStore(value); 
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Color.fromARGB(255, 201, 199, 199)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.cyanAccent),
                onPressed: () {
                },
              ),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder(
              future: FirebaseFirestore.instance.collection('tiendas').get(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData){
                  return Text('No existe data aún');
                }
                return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index){

                    return StoreTile(
                      storeName: snapshot.data!.docs[index].data()['nombre'],
                      iconData: Icons.restaurant,
                      location: snapshot.data!.docs[index].data()['ubicacion'],
                      payments: _dynamicToBool(snapshot.data!.docs[index].data()['pagos']),
                      time: snapshot.data!.docs[index].data()['horario'],
                      contact: snapshot.data!.docs[index].data()['contacto'],
                      products: _listarProductos(snapshot.data!.docs[index].data()['productos']),
                    );

                  }
                  )
                );
              }
            )
          ],
        ),
      )
    );
  }
}

class StoreTile extends StatefulWidget {
  final String storeName;
  final IconData iconData;
  final String location;
  final Map<String, bool> payments;
  final String time;
  final String contact;
  final List<Widget> products;

  const StoreTile({
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
  _StoreTileState createState() => _StoreTileState();
}

class _StoreTileState extends State<StoreTile> {
  bool forminfo = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purpleAccent, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.cyanAccent),
              ),
              child: Icon(Icons.restaurant, size: 30, color: Colors.white,) //Aquí va la foto de la tienda
            ),
            
            title: Text(
              widget.storeName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
            ),
            trailing: Icon(
              forminfo ? Icons.arrow_drop_up : Icons.arrow_drop_down, 
              color: Colors.cyanAccent,
            ),
            onTap: (){
              setState(() {
                forminfo = !forminfo; 
              });
            },
          ),
          if (forminfo) ...[
            const Divider(color: Colors.white, thickness: 3),

            Row(
              children: [
                Text(
                  'Ubicación: ',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
                Text(
                  widget.location,
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.purple, thickness: 2),

            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: 
                  Text(
                    'Medios de pago aceptados', 
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 15
                    ),
                  ),
                ),
                //----- Junaeb -----
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.payments['Junaeb'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                        color: widget.payments['Junaeb'] ?? false ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Junaeb', style: TextStyle(fontSize: 15, color: Colors.white),)
                    ],
                  ),
                ),
                //----- Tarjeta -----
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.payments['Tarjeta'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                        color: widget.payments['Tarjeta'] ?? false ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Tarjeta', style: TextStyle(fontSize: 15, color: Colors.white),)
                    ],
                  ),
                ),
                //----- Efectivo -----
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.payments['Efectivo'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                        color: widget.payments['Efectivo'] ?? false ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Efectivo', style: TextStyle(fontSize: 15, color: Colors.white),)
                    ],
                  ),
                ),
                //----- Transferencia -----
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.payments['Transferencia'] ?? false ? Icons.toggle_on : Icons.toggle_off,
                        color: widget.payments['Transferencia'] ?? false ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Transferencia', style: TextStyle(fontSize: 15, color: Colors.white),)
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.purple, thickness: 2),

            Row(
              children: [
                Text(
                  'Horaio: ',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
                Text(
                  widget.time,
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.purple, thickness: 2),

            Row(
              children: [
                Text(
                  'Contacto: ',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
                Text(
                  widget.contact,
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white, thickness: 4),

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

            Column(children: widget.products,)
          ]
        ],
      ),
    );
  }
}

//-----------------------------------------------

class ProductForm extends StatefulWidget {
  final String pName;
  final String pPrice; 
  final String pDesc;
  final bool stck;
  final GlobalKey<_ProductFormState> formKey;

  ProductForm({
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.cyanAccent, width: 2.0),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //--- Nombre ---
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.pName,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icono
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.cyanAccent, width: 2.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image, 
                      size: 40.0,
                      color: Colors.black,
                    ),
                  ),
                ),

                Column(
                  children: [
                    //--- Precio ---
                    Text(
                      '\$'+widget.pPrice,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    //--- Stock ---
                    Row(
                      children: [
                        Icon(
                          widget.stck ? Icons.circle : Icons.circle_outlined,
                          color: widget.stck ? Colors.green : Colors.red,
                          size: 30.0,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          widget.stck ? 'Disponible' : 'Sin stock',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20.0),

            //--- Descripción ---
            Text(
              widget.pDesc,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
