import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First connet from Win10Home to Firestore',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users name')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    final String documentID = record.reference.documentID;
    Map<String, dynamic> data2 = {
      "name": "向江 正誤",
      "like": "PHP/JavaScript/Flutter",
    };
    updateData('users', 'mukae', data2);
    //deleteData('users', 'xxx');

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          leading: Text(documentID),
          title: Text(record.name),
          trailing: Text(record.like),
          onTap: () => Firestore.instance.runTransaction((transaction) async {
            final freshSnapshot = await transaction.get(record.reference);
            final fresh = Record.fromSnapshot(freshSnapshot);

            await transaction
                .update(record.reference, {'like': fresh.like.toUpperCase()});
          }),
        ),
      ),
    );
  }
}

class Record {
  final String name;
  final String like;
  final DocumentReference reference;

  Record.fromMap(Map map, {this.reference})
      : assert(map['name'] != null),
        assert(map['like'] != null),
        name = map['name'],
        like = map['like'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$like>";
}

void setData(String collection, String documentId, Map data) {
  Firestore.instance.collection(collection).document(documentId).setData(data);
}

void updateData(String collection, String documentID, Map data) {
  Firestore.instance
      .collection(collection)
      .document(documentID)
      .updateData(data);
}

void deleteData(String collection, String documentId) {
  Firestore.instance.collection(collection).document(documentId).delete();
}
