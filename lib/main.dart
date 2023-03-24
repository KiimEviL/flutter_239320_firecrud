import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController _priceController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {

    if(documentSnapshot != null){
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (BuildContext cntx){
        return Padding(
          padding: EdgeInsets.only(
            top:20,
            left:20,
            right: 20,
            bottom: MediaQuery.of(cntx).viewInsets.bottom + 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),

              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: () async {
                String name = _nameController.text;
                double? price = double.tryParse(_priceController.text);
                if (price != null){
                  await _products.doc(documentSnapshot!.id).update({'name':name,
                  'price':price});
                  _nameController.text = '';
                  _priceController.text = '';
                }
              },
              child: Text('Update')
              ),

            ],
          ),
        );
      });



  }
  Future<void> _delete(String productID) async{
      await _products.doc(productID).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully deleted')));
  }
  
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    
    if(documentSnapshot != null){
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (BuildContext cntx){
        return Padding(
          padding: EdgeInsets.only(
            top:20,
            left:20,
            right: 20,
            bottom: MediaQuery.of(cntx).viewInsets.bottom + 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),

              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: () async {
                String name = _nameController.text;
                double? price = double.tryParse(_priceController.text);
                if (price != null){
                  await _products.add({
                    'name':name,
                    'price':price
                  });
                  _nameController.text = '';
                  _priceController.text = '';
                }
              },
              child: Text('Update')
              ),

            ],
          ),
        );
      });

  }
    
  final CollectionReference _products = FirebaseFirestore.instance.collection('products');
  

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _create();
        },
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder:(context, AsyncSnapshot<QuerySnapshot> streamSnapShot){
          if(streamSnapShot.hasData){
            return ListView.builder(
              itemCount: streamSnapShot.data!.docs.length,
              itemBuilder:(context,index){
                final DocumentSnapshot documentSnapshot = streamSnapShot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price'].toString()),
                    trailing:SizedBox(
                      width: 100,
                      child: Row(
                        children:[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: ()=>_update(documentSnapshot),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: ()=>_delete(documentSnapshot.id),
                          )
                        ]
                      )
                    )
                  )
                );
              }
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      )
    );
  }
}