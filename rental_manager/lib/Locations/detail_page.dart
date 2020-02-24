import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:flutter/services.dart';

class DetailPage extends StatefulWidget {
  var itemSelected;
  DetailPage({this.itemSelected});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailPage();
  }
}

class _DetailPage extends State<DetailPage> {
  Container getImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.network(
        widget.itemSelected.data['imageURL'],
        fit: BoxFit.cover,
        height: 300.0,
      ),
      // constraints: BoxConstraints.expand(height: 300.0),
    );
  }

  Container getDescription() {
    return Container(
      alignment: Alignment.center,
      // alignment: Alignment.topCenter,
      child: Text('some item description information...'),
    );
  }

  Container getButton() {
    return Container(
      alignment: Alignment.center,
      child: RaisedButton(
        onPressed: () {
          print('button pressed! (reserve)');
          testingReservations(widget.itemSelected.documentID);
        },
        child: Text('Reserve Now', style: TextStyle(color: Colors.white)),
        color: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Details of: ${widget.itemSelected.data['name']}'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.blueGrey,
      // body: Image.network(
      //   widget.itemSelected.data['imageURL'],
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getImage(),
          getDescription(),
          getButton(),
        ],
      ),

      // constraints: BoxConstraints.expand(),
      // color: Colors.blueGrey,
      // child: Stack(children: <Widget>[
      //   getImage(),
      //   getDescription(),
      // ]),
    );
  }
// }

  testingReservations(String itemID) async {
    print(globals.uid);
    // final QuerySnapshot result =
    // await Firestore.instance.collection('items').getDocuments();
    // final List<DocumentSnapshot> documents = result.documents;
    // List<String> itemIDs = [];
    // documents.forEach((data) => itemIDs.add(data.documentID));
    // print(documents.length);
    //for(int i = 0; i< snapshot.length;i++){
    print(itemID);
    //}
    var now = new DateTime.now();
    var time = DateFormat("yyyy-MM-dd hh:mm:ss").format(now);
    var pickUpBefore = now.add(new Duration(minutes: 10));
    print("Reservation Created time: " + time);
    print("Reservation pickup before time: " +
        DateFormat("yyyy-MM-dd hh:mm:ss").format(pickUpBefore));
    uploadData(itemID, globals.uid, time);
  }

  void uploadData(itemID, uid, dateTime) async {
    String itemName, imageURL;
    final databaseReference = Firestore.instance;
    await Firestore.instance
        .collection('ARC_items')
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        itemName = ds["name"];
        print("Found in ARC_items");
      } catch (e) {
        print(e);
      }
    });

    await Firestore.instance
        .collection('ARC_items')
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        imageURL = ds["imageURL"];
        print("Found in ARC_items");
      } catch (e) {
        print(e);
      }
    });

    if (itemName == null) {
      print("UID Not Found");
      itemName = "UID Not Found";
    }
    if (imageURL == null) {
      print("UID Not Found");
      imageURL = "www.gooogle.com";
    }

    await databaseReference.collection("reservation").document().setData({
      'imageURL': imageURL,
      'name': itemName,
      'uid': uid,
      'item': itemID,
      'uid': uid,
      'amount': "1",
      'startTime': dateTime,
      'status': "Picked Up",
      'endTime': "TBD",
    });
    PlatformAlertDialog(
      title: 'Your item has placed',
      content:
          'Your reservation is successful confirmed, please pick it up on time',
      defaultActionText: Strings.ok,
    ).show(context);
    print("success!");
  }
}
