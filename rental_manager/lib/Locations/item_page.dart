import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../globals.dart' as globals;
// import 'package:intl/intl.dart';
// import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
// import 'package:rental_manager/PlatformWidget/strings.dart';
// import 'package:flutter/services.dart';
import 'detail_page.dart';

class ItemPage extends StatefulWidget {
  String category;
  ItemPage({this.category});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _ItemPageState();
  }
}

// showAlertDialog(BuildContext context) {
//   // set up the buttons
//   Widget remindButton = RaisedButton(
//     child: Text("Reservation have been created"),
//     onPressed: () {
//       // Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
//     },
//   );
// }

class _ItemPageState extends State<ItemPage> {
  // Future getFirestoreData() async {
  //   final firestore = Firestore.instance;
  //   QuerySnapshot arrayOfLocationDocuments = await firestore
  //       .collection('ARC_items')
  //       .where('category', isEqualTo: widget.category)
  //       .getDocuments();
  //   return arrayOfLocationDocuments.documents;
  // }
  navigateToDetail(DocumentSnapshot indexedData) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPage(itemSelected: indexedData)));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Selected: ${widget.category}'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('ARC_items')
              .where('category', isEqualTo: widget.category)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(
                    snapshot.data.documents[index].data['name'].toString()),
                subtitle: Text(
                    'Total amount: ${snapshot.data.documents[index].data['# of items'].toString()}'),
                onTap: () {
                  navigateToDetail(snapshot.data.documents[index]);
                  // testingReservations(
                  //     snapshot.data.documents[index].documentID);
                },
              ),
            );
          }),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: Text('Category Selected: ${widget.category}'),
  //         backgroundColor: Colors.teal,
  //       ),
  //       body: Container(
  //         child: FutureBuilder(
  //           future: getFirestoreData(),
  //           builder: (_, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return Center(
  //                 child: Text('Loading...'),
  //               );
  //             } else {
  //               // print('!!! ${widget.category}');
  //               // print('### ${snapshot.data.toString()}');
  //       return ListView.builder(
  //         itemCount: snapshot.data.length,
  //         itemBuilder: (BuildContext context, int index) => ListTile(
  //           title: Text(snapshot.data[index].data['name'].toString()),
  //           subtitle: Text(
  //               'Total amount: ${snapshot.data[index].data['# of items'].toString()}'),
  //           onTap: () =>
  //               testingReservations(snapshot.data[index].documentID),
  //         ),
  //       );
  //     }
  //   },
  // ),
  //       ));
  // }

//   testingReservations(String itemID) async {
//     print(globals.uid);
//     // final QuerySnapshot result =
//     // await Firestore.instance.collection('items').getDocuments();
//     // final List<DocumentSnapshot> documents = result.documents;
//     // List<String> itemIDs = [];
//     // documents.forEach((data) => itemIDs.add(data.documentID));
//     // print(documents.length);
//     //for(int i = 0; i< snapshot.length;i++){
//     print(itemID);
//     //}
//     var now = new DateTime.now();
//     var time = DateFormat("yyyy-MM-dd hh:mm:ss").format(now);
//     var pickUpBefore = now.add(new Duration(minutes: 10));
//     print("Reservation Created time: " + time);
//     print("Reservation pickup before time: " +
//         DateFormat("yyyy-MM-dd hh:mm:ss").format(pickUpBefore));
//     uploadData(itemID, globals.uid, time);
//   }

//   void uploadData(itemID, uid, dateTime) async {
//     String itemName, imageURL;
//     final databaseReference = Firestore.instance;
//     await Firestore.instance
//         .collection('ARC_items')
//         .document(itemID)
//         .get()
//         .then((DocumentSnapshot ds) {
//       try {
//         itemName = ds["name"];
//         print("Found in ARC_items");
//       } catch (e) {
//         print(e);
//       }
//     });

//     await Firestore.instance
//         .collection('ARC_items')
//         .document(itemID)
//         .get()
//         .then((DocumentSnapshot ds) {
//       try {
//         imageURL = ds["imageURL"];
//         print("Found in ARC_items");
//       } catch (e) {
//         print(e);
//       }
//     });

//     if (itemName == null) {
//       print("UID Not Found");
//       itemName = "UID Not Found";
//     }
//     if (imageURL == null) {
//       print("UID Not Found");
//       imageURL = "www.gooogle.com";
//     }

//     await databaseReference.collection("reservation").document().setData({
//       'imageURL': imageURL,
//       'name': itemName,
//       'uid': uid,
//       'item': itemID,
//       'uid': uid,
//       'amount': "1",
//       'startTime': dateTime,
//       'status': "Picked Up",
//       'endTime': "TBD",
//     });
//     PlatformAlertDialog(
//       title: 'Your item has placed',
//       content:
//           'Your reservation is successful confirmed, please pick it up on time',
//       defaultActionText: Strings.ok,
//     ).show(context);
//     print("success!");
//   }
}
