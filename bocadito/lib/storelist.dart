import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreListPage extends StatefulWidget {
  @override
  _StoreListPageState createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
 
  // Widget para construir la carta de un producto
  Widget _buildProductView(String productName, String precio, String descripcion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Añadir espaciado entre productos
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de producto (puedes cambiar a otro si es necesario)
              const Icon(
                Icons.lunch_dining, 
                color: Colors.white, 
                size: 40, // Ajustar tamaño del icono
              ),
              const SizedBox(width: 10), // Espacio entre el icono y el texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primera fila con el nombre del producto y el precio alineado a la derecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nombre del producto
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Precio del producto
                        Text(
                          '\$$precio',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5), // Espacio entre el nombre y la descripción
                    // Descripción del producto
                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Espacio antes del divisor
          // Divider púrpura entre productos
          const Divider(
            color: Colors.purple,
            thickness: 2,
          ),
        ],
      ),
    );
  }


  //---------------------------------

  List<Widget> _listarProductos (List<dynamic> productsMaps){
    List<Widget> productsView = [];
    for (var item in productsMaps){
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      productsView.add(_buildProductView(mapa['nombreP'], mapa['precio'], mapa['descripcion']));
    }
    return productsView;
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
        backgroundColor: Colors.black87,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[800],
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
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.purple),
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
                      payments: snapshot.data!.docs[index].data()['pagos'],
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
  final String payments;
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
            const Divider(color: Colors.purple, thickness: 2),

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

            Row(
              children: [
                Text(
                  'Medios de pago: ',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
                Text(
                  widget.payments,
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
            const Divider(color: Colors.purple, thickness: 2),

            Column(children: widget.products,)
          ]
        ],
      ),
    );
  }
}
