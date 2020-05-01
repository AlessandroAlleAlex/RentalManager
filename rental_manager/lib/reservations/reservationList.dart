import 'package:rental_manager/language.dart';
import '../CurrentReservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reservations/reservationCell.dart';
import '../globals.dart' as globals;

class ReservationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReservationListPage();
  }
}

class _ReservationListPage extends State<ReservationListPage> {
  navigateToDetail(DocumentSnapshot indexedData) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                reservationCell(passedFirestoreData: indexedData)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(globals.collectionName)
          .where('uid', isEqualTo: globals.uid)
          .where('status', isEqualTo: 'Reserved')
          .snapshots(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(langaugeSetFunc('Loading...')),
          );
        } else {
          // print(snapshot.data.documents[0]['startTime']);
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            // add change here make the itemBuilder return Dismissible type
            itemBuilder: (context, index) {
              // print(snapshot.data[index]['name'].toString());
              return Container(
                // padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 3.0),
                  borderRadius: BorderRadius.all(Radius.circular(
                          40.0) //                 <--- border radius here
                      ),
                ),
                child: ListTile(
                  leading: Icon(Icons.timer, size: 35.0),
                  trailing: Icon(Icons.arrow_forward, size: 28.0),
                  onTap: () async {
                    print(123);
                    navigateToDetail(snapshot.data.documents[index]);
                  },
                  title: Text(
                    snapshot.data.documents[index]['name'],
                    style: TextStyle(fontSize: 20.0),
                  ),
                  subtitle: Text(
                      parseTime(snapshot.data.documents[index]['startTime']) +
                          ' - quantity: ' +
                          snapshot.data.documents[index]['amount']),
                ),
              );
            },
          );
        }
      },
    );
  }
}

// String lala;
// String getItemName(String id) {
//   String res = "";
//   DocumentReference itemRef =
//       Firestore.instance.collection("items").document(id);
//   itemRef.get().then((datasnapshot) {
//     //print(datasnapshot.data);
//     if (datasnapshot.data.containsKey('name')) {
//       print(datasnapshot.data['name']);
//       // lala = datasnapshot.data['name'].toString();
//       res = datasnapshot.data['name'].toString();
//     } else {
//       // lala = "null";
//       // lala = "null";
//       res = "null";
//       print("No such item in database!?");
//     }
//   });
//   return res;
// }
