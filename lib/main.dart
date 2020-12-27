import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

final String title = 'Baby Names';

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'something error',
            textDirection: TextDirection.ltr,
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: title,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: MyHomePage(title: title),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    _buildList(dummySnapshot);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildDocs(context),
    );
  }
}

Widget _buildDocs(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection('baby').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return LinearProgressIndicator();
      return _buildDocsItem(context, snapshot.data.documents);
    },
  );
}

Widget _buildDocsItem(BuildContext context, List<DocumentSnapshot> data) {
  var res = data.map((item) {
    return Card(
      child: ListTile(
        title: Text(item['name']),
        trailing: Text(item['votes'].toString()),
        //check more abt race condition here https://codelabs.developers.google.com/codelabs/flutter-firebase#10
        onTap: () {
          print(item['name']);
          item.reference.updateData({'votes': FieldValue.increment(1)});
        },
      ),
    );
  }).toList();
  res.add(Card(
    child: ListTile(
      leading: FlutterLogo(size: 56.0),
      title: Text('keep for ref'),
      subtitle: Text('A sufficiently long subtitle warrants three lines.'),
      trailing: Icon(Icons.more_vert),
    ),
  ));
  return ListView(
    padding: const EdgeInsets.all(16.0),
    children: res,
  );
}

final dummySnapshot = [
  {"name": "Filip", "votes": 15},
  {"name": "Abraham", "votes": 14},
  {"name": "Richard", "votes": 11},
  {"name": "Ike", "votes": 10},
  {"name": "Justin", "votes": 1},
];

List<Widget> _buildList(List<Map> data) {
  var res = data.map((item) {
    return Card(
      child: ListTile(
        title: Text(item['name']),
        trailing: Text(item['votes'].toString()),
        onTap: () {
          print(item['name']);
        },
      ),
    );
  }).toList();
  res.add(Card(
    child: ListTile(
      leading: FlutterLogo(size: 56.0),
      title: Text('keep for ref'),
      subtitle: Text('A sufficiently long subtitle warrants three lines.'),
      trailing: Icon(Icons.more_vert),
    ),
  ));
  return res;
}
