import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../reservations/reservationCell.dart';

class ReservationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReservationListPage();
  }
}

class _ReservationListPage extends State<ReservationListPage> {
  Future getFirestoreData() async {
    final firestore = Firestore.instance;
    QuerySnapshot itemListDOC =
        await firestore.collection('reservation').getDocuments();
    return itemListDOC.documents;
  }

  navigateToDetail(DocumentSnapshot indexedData) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                reservationCell(passedFirestoreData: indexedData)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        child: FutureBuilder(
            future: getFirestoreData(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text('Loading...'),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) =>
                        customCell(index, snapshot));

              }
            }));
  }

  String lala;
  String getItemName(String id) {
    String res = "";
    DocumentReference itemRef =
        Firestore.instance.collection("items").document(id);
    itemRef.get().then((datasnapshot) {
      //print(datasnapshot.data);
      if (datasnapshot.data.containsKey('name')) {
        print(datasnapshot.data['name']);
        // lala = datasnapshot.data['name'].toString();
        res = datasnapshot.data['name'].toString();
      } else {
        // lala = "null";
        // lala = "null";
        res = "null";
        print("No such item in database!?");
      }
    });
    return res;
  }

  Widget customCell(int index, AsyncSnapshot snapshot) {
    String res = "lalalalala";
    // getItemName(snapshot.data[index].data['item']);
    // print("Got this: " + lala);
    Future<String> getFirestoreItemData() async {
      // final firestoreItem = Firestore.instance;
      DocumentReference itemListDOC = Firestore.instance
          .collection("items")
          .document(snapshot.data[index].data['item']);
      itemListDOC.get().then((datasnapshot) {
        //print(datasnapshot.data);
        if (datasnapshot.data.containsKey('name')) {
          // print(datasnapshot.data['name']);
          return datasnapshot.data['name'].toString();
        } else {
          return "null1";
          print("No such item in database!?");
        }
      });
      return "null3";
      // return res;
    }

    return Material(
      child: InkWell(
        onTap: () => navigateToDetail(snapshot.data[index]),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Card(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    // FutureBuilder(
                    // future: getFirestoreItemData(),
                    // builder: (_, stringItem)
                    // ),
                    Row(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  // getItemName(snapshot.data[index].data['item']),
                                  // res,
                                  // getFirestoreItemData().toString(),
                                  snapshot.data[index].data['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  snapshot.data[index].data['startTime'],
                                  // 'Reservation Cell',
                                  style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Stack(
                          children: <Widget>[
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

