import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {
  @override
  State<StorePage> createState() => _StorePageState();
}

/* Función que retorna la Base de Datos */

List<String> BocadoDataBase(int index){

  List shop = <List>[
    ["Sushi nito", "Puerta Placeres", "Junaeb, Tarjetas, Efectivo"],
    ["Tocomples", "Edificio C, Primer Piso", "Transferencias, Efectivo"],
    ["Dulces de La Ligua", "Edificio M, Segundo Piso", "Transferencias, Efectivo"],
    ["Choco-Choco", "Área Piscina", "Efectivo"]
  ];

  return shop[index];
}

class _StorePageState extends State<StorePage> {

  /*
  Aquí hay que sacar los datos de la DataBase, donde se deben crear listas
  individuales con cada uno de los diferentes datos que se van a utilizar
  */

  /*
  var namesList = List.generate(4, (index) => BocadoDataBase(index)[0]);
  var locationList = List.generate(4, (index) => BocadoDataBase(index)[1]);
  var paysMethodList = List.generate(4, (index) => BocadoDataBase(index)[2]);
  */

  List<String> namesList = [
    "Sushi nito",
    "Tocomples",
    "Dulces de La Ligua",
    "Choco-Choco"
  ];

  List<String> locationList = [
    "Puerta Placeres",
    "Edificio C",
    "Edificio M",
    "Área Piscina"
  ];

  List<String> paysMethodList = [
    "Junaeb, Tarjetas, Efectivo",
    "Transferencias, Efectivo",
    "Transferencias, Efectivo",
    "Efectivo"
  ];

  var allItems = List.generate(50, (index) => 'item $index');
  List<String> namesOnScreen = [];
  var searHistory = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    searchController.addListener(queryListener);
  }

  @override
  void dispose(){
    searchController.removeListener(queryListener);
    searchController.dispose();
    super.dispose();
  }

  void queryListener(){
    search(searchController.text);
  }

  void search(String query){
    if (query.isEmpty){
      setState(() {
        namesOnScreen = namesList;
      });
    }
    else {
      setState(() {
        namesOnScreen = namesList.where((e) => e.toLowerCase().contains(query.toLowerCase())).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16.0,),
            SearchBar(
              controller: searchController,
              leading: IconButton(
                  onPressed: (){
                  },
                  icon: const Icon(Icons.search),
              ),
              hintText: "Buscar tienda",
            ),

            Expanded(
                child: ListView.builder(
                    itemCount: namesOnScreen.isEmpty ?  namesList.length : namesOnScreen.length,
                    itemBuilder: (BuildContext context, int index) {
                      final name = namesOnScreen.isEmpty ? namesList[index] : namesOnScreen[index];
                      final location = locationList[index];
                      final pays = paysMethodList[index];
                      return ListTile(
                        title: Text(name, style: TextStyle(color: Colors.white)),
                        subtitle: Text(location),
                        leading: const Icon(Icons.food_bank),
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ShopView(name:name, location:location, paymethod:pays)
                              ));
                        },
                      );
                    },
                ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class ShopView extends StatelessWidget {

  final String name, location, paymethod;

  ShopView({required this.name, required this.location, required this.paymethod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(
          location,
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
