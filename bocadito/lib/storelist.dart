import 'package:bocadito/mainscreen.dart';
import 'package:bocadito/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                    border: Border.all(color: const Color.fromARGB(144, 24, 255, 255) , width: 2.0),
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
                          border: Border.all(color: const Color.fromARGB(144, 24, 255, 255) , width: 2.0),
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
                          border: Border.all(color: const Color.fromARGB(144, 24, 255, 255) , width: 2.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              stock ? Icons.circle_outlined : Icons.circle_outlined,
                              color: stock ? Colors.green : Colors.red,
                              size: 18,
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
                border: Border.all(color: const Color.fromARGB(144, 24, 255, 255) , width: 2.0), // Borde cian
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
      if(query.isEmpty){
        tiendasFiltradas = tiendasList;
        searcher = false;
      } else {
        searcher = true;
        tiendasFiltradas = tiendasList.where((store){
          String storename = store.storeName.toLowerCase();
          return storename.contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  
  List<StoreTile> tiendasList = []; 
  List<StoreTile> tiendasFiltradas = []; 
  bool searcher = false;

  //------------------------------

  @override
  Widget build(BuildContext context) {
    String iDuser = context.watch<UserProvider>().iDuser;
    int loged = context.watch<UserProvider>().loged;
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        toolbarHeight: 85,
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
              const SizedBox(height: 40,),
              Icon(Icons.search, size: 30, color: Colors.cyanAccent),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _searchStore(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar Tienda',
                    hintStyle: TextStyle(color: Color.fromARGB(255, 201, 199, 199)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.menu), 
                iconSize: 30, 
                color: Colors.cyanAccent,
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

                tiendasList = snapshot.data!.docs.map<StoreTile>((doc) {
                  var tienda = doc.data();
                  return StoreTile(
                    storeName: tienda['nombre'],
                    iconData: Icons.restaurant,
                    location: tienda['ubicacion'],
                    payments: _dynamicToBool(tienda['pagos']),
                    time: tienda['horario'],
                    contact: tienda['contacto'],
                    products: _listarProductos(tienda['productos']),
                    latitud: tienda['latitud'],
                    longitud: tienda['longitud'],
                    iDuser: iDuser,
                    log: loged,
                  );
                }).toList();

                return searcher ? Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tiendasFiltradas.length,
                    itemBuilder: (context, index) {
                      return tiendasFiltradas[index]; // Mostrar StoreTile desde la lista
                    },
                  ),
                ) : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tiendasList.length,
                    itemBuilder: (context, index) {
                      return tiendasList[index]; // Mostrar StoreTile desde la lista
                    },
                  ),
                );

                /*
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
                      latitud: snapshot.data!.docs[index].data()['latitud'],
                      longitud: snapshot.data!.docs[index].data()['longitud'],
                      iDuser: iDuser,
                      log: loged,
                    );

                  }
                ));
                */
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
  final double latitud;
  final double longitud;
  final String iDuser;
  final int log;

  const StoreTile({
    Key? key,
    required this.storeName,
    required this.iconData,
    required this.location,
    required this.payments,
    required this.time,
    required this.contact,
    required this.products,
    required this.latitud,
    required this.longitud,
    required this.iDuser,
    required this.log,
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
            const Divider(color: Colors.purpleAccent, thickness: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Dirección: ',
                      style: TextStyle(color: Colors.cyanAccent)
                    ),
                    TextSpan(
                      text: widget.location,
                      style: TextStyle(color: Colors.white)
                    ),
                  ]
                ),
                ),
            ),
            
            const SizedBox(height: 10),
            const Divider(color: Colors.purple, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ver ubicación en el mapa', style: TextStyle(color: Colors.cyanAccent),),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.location_on, color: Colors.redAccent,),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Mainscreen(
                            loged: widget.log, 
                            userID: widget.iDuser,
                            initialIndex: 1, 
                            lati: widget.latitud,
                            long: widget.longitud,
                            actvMark: true,
                          ),
                        ),
                      );
                    },
                  )
                )
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

            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Horario: ',
                      style: TextStyle(color: Colors.cyanAccent)
                    ),
                    TextSpan(
                      text: widget.time,
                      style: TextStyle(color: Colors.white)
                    ),
                  ]
                ),
                ),
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
            const Divider(color: Colors.purpleAccent, thickness: 4),

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